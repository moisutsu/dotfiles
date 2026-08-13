#!/usr/bin/env bash
# herdr tab picker — tmux の choose-window 相当。
# tab だけを一覧し、j/k で移動、選択中 tab の画面内容をプレビュー、Enter でジャンプする。
# プレビューは herdr pane layout の矩形をそのまま縮小して合成するので、
# 縦横に split された tab はプレビューでも同じ split で表示される。
#
# config.toml:
#   [[keys.command]]
#   key = "prefix+w"
#   type = "pane"
#   command = "~/.config/herdr/tab-picker.sh"
#
# 注意: herdr tab list は pane_id を持たないので、herdr pane list を tab_id で
# 突き合わせて各 tab の pane を自前で解決している。

set -uo pipefail

self=${BASH_SOURCE[0]}
[[ $self == /* ]] || self=$PWD/$self

die() {
  printf '\033[31merror:\033[0m %s\n' "$*" >&2
  # type="pane" の一時 pane は即座に閉じるのでメッセージが読めない。ここで止める。
  printf '\nEnter を押すと閉じます... ' >&2
  read -r _ || true
  exit 1
}

# ---------------------------------------------------------------- preview mode
# fzf の --preview から自分自身を呼び出す。$1 = --preview, $2 = pane_id のカンマ区切り
if [[ ${1:-} == --preview ]]; then
  panes=${2:-}
  [[ -n $panes ]] || { echo '(no pane)'; exit 0; }

  if command -v python3 >/dev/null 2>&1; then
    # レイアウト再現版。失敗したら下の素朴版にフォールバックする。
    python3 -c '
import json, os, re, subprocess, sys, unicodedata

CSI = re.compile(r"\x1b\[[0-9;?:]*[ -/]*[@-~]")
OSC = re.compile(r"\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)")
DIM = "\x1b[38;5;8m"
RESET = "\x1b[0m"

pane_ids = [p for p in sys.argv[1].split(",") if p]
W = max(int(os.environ.get("FZF_PREVIEW_COLUMNS") or 80), 8)
H = max(int(os.environ.get("FZF_PREVIEW_LINES") or 24), 4)
self_pane = os.environ.get("HERDR_PANE_ID", "")


def herdr(*args):
    r = subprocess.run(["herdr", *args], capture_output=True, text=True)
    if r.returncode != 0:
        raise RuntimeError(" ".join(args) + ": " + (r.stderr.strip() or "failed"))
    return r.stdout


def clip(s, width):
    """ANSI エスケープを保ったまま表示幅 width ちょうどに切り詰め / 空白埋めする。"""
    out, vis, i, n = [], 0, 0, len(s)
    while i < n and vis < width:
        ch = s[i]
        if ch == "\x1b":
            m = CSI.match(s, i) or OSC.match(s, i)
            if m:
                out.append(m.group())
                i = m.end()
            else:
                i += 2
            continue
        if unicodedata.combining(ch):
            out.append(ch)
            i += 1
            continue
        w = 2 if unicodedata.east_asian_width(ch) in ("W", "F") else 1
        if vis + w > width:
            break
        out.append(ch)
        vis += w
        i += 1
    if vis < width:
        out.append(" " * (width - vis))
    return "".join(out)


def plain(s):
    return OSC.sub("", CSI.sub("", s))


def read_pane(pid, rows, cols):
    """pane の可視領域を rows x cols に収める。末尾の空行は捨てて下側を優先。"""
    try:
        lines = herdr("pane", "read", pid, "--source", "visible", "--format", "ansi").split("\n")
    except RuntimeError:
        lines = ["(unavailable)"]
    lines = [l.rstrip("\r") for l in lines]
    while lines and not plain(lines[-1]).strip():
        lines.pop()
    lines = lines[-rows:]
    lines += [""] * (rows - len(lines))
    return [clip(l, cols) for l in lines]


def contains(outer, inner):
    return (outer["x"] <= inner["x"] and outer["y"] <= inner["y"]
            and outer["x"] + outer["width"] >= inner["x"] + inner["width"]
            and outer["y"] + outer["height"] >= inner["y"] + inner["height"])


def sibling_rect(parent, child):
    """split の親矩形から child を取り除いた残り（= 兄弟部分木の矩形）。"""
    px, py, pw, ph = parent["x"], parent["y"], parent["width"], parent["height"]
    cx, cy, cw, ch = child["x"], child["y"], child["width"], child["height"]
    if cy == py and ch == ph and cw < pw:          # 左右分割
        if cx == px:
            return {"x": px + cw, "y": py, "width": pw - cw, "height": ph}
        if cx + cw == px + pw:
            return {"x": px, "y": py, "width": pw - cw, "height": ph}
    if cx == px and cw == pw and ch < ph:          # 上下分割
        if cy == py:
            return {"x": px, "y": py + ch, "width": pw, "height": ph - ch}
        if cy + ch == py + ph:
            return {"x": px, "y": py, "width": pw, "height": ph - ch}
    return None


def collapse_self(layout, self_rect, panes):
    """ピッカーの一時 pane が split で割り込んだ分を取り消し、
    兄弟部分木を親 split の矩形いっぱいまで引き伸ばして元の比率に戻す。"""
    parents = [s["rect"] for s in layout.get("splits", []) if contains(s["rect"], self_rect)]
    if not parents:
        return panes
    parent = min(parents, key=lambda r: r["width"] * r["height"])
    sib = sibling_rect(parent, self_rect)
    if not sib or sib["width"] <= 0 or sib["height"] <= 0:
        return panes

    def remap(r):
        if not contains(sib, r):
            return r
        def ax(v):
            return parent["x"] + (v - sib["x"]) * parent["width"] / sib["width"]
        def ay(v):
            return parent["y"] + (v - sib["y"]) * parent["height"] / sib["height"]
        x, y = ax(r["x"]), ay(r["y"])
        return {"x": x, "y": y,
                "width": ax(r["x"] + r["width"]) - x,
                "height": ay(r["y"] + r["height"]) - y}

    return [{**p, "rect": remap(p["rect"])} for p in panes]


layout = json.loads(herdr("pane", "layout", "--pane", pane_ids[0]))["result"]["layout"]
self_rect = next((p["rect"] for p in layout["panes"] if p["pane_id"] == self_pane), None)
panes = [p for p in layout["panes"] if p["pane_id"] != self_pane] or layout["panes"]
if self_rect and len(panes) < len(layout["panes"]):
    panes = collapse_self(layout, self_rect, panes)

# zoom 中の tab は実際にも 1 pane しか見えていないのでそれに合わせる
if layout.get("zoomed"):
    zoomed = [p for p in panes if p["pane_id"] == layout.get("focused_pane_id")]
    if zoomed:
        panes = zoomed

# ピッカー自身の一時 pane を除いた矩形の外接矩形を基準にする。
# これで「ピッカーが tab を split して入り込んだ」場合でも元の見た目に戻る。
x0 = min(p["rect"]["x"] for p in panes)
y0 = min(p["rect"]["y"] for p in panes)
aw = max(p["rect"]["x"] + p["rect"]["width"] for p in panes) - x0
ah = max(p["rect"]["y"] + p["rect"]["height"] for p in panes) - y0
if aw <= 0 or ah <= 0:
    raise SystemExit(1)

# 行ごとの (開始列, 表示幅, 文字列) を集めて最後に組み立てる。
rows = [[] for _ in range(H)]

for p in panes:
    r = p["rect"]
    px = round((r["x"] - x0) * W / aw)
    py = round((r["y"] - y0) * H / ah)
    pw = round((r["x"] + r["width"] - x0) * W / aw) - px
    ph = round((r["y"] + r["height"] - y0) * H / ah) - py
    if pw <= 0 or ph <= 0:
        continue

    # 左 / 上が領域の端でなければ 1 セルを罫線に使う。
    cx, cw = (px + 1, pw - 1) if px > 0 else (px, pw)
    cy, ch_ = (py + 1, ph - 1) if py > 0 else (py, ph)
    if cw <= 0 or ch_ <= 0:
        continue

    if py > 0:
        rows[py].append((px, pw, DIM + "─" * pw + RESET))
    if px > 0:
        for y in range(cy, cy + ch_):
            if y < H:
                rows[y].append((px, 1, DIM + "│" + RESET))

    for y, line in enumerate(read_pane(p["pane_id"], ch_, cw)):
        if cy + y < H:
            rows[cy + y].append((cx, cw, line))

out = []
for items in rows:
    items.sort(key=lambda it: it[0])
    line, col = [], 0
    for start, width, text in items:
        if start < col:
            continue
        if start > col:
            line.append(" " * (start - col))
        line.append(text)
        line.append(RESET)
        col = start + width
    out.append("".join(line).rstrip())
sys.stdout.write("\n".join(out) + "\n")
' "$panes" 2>/dev/null && exit 0
  fi

  # フォールバック: pane を上から順に並べるだけ
  IFS=, read -r -a pane_ids <<<"$panes"
  for i in "${!pane_ids[@]}"; do
    p=${pane_ids[$i]}
    [[ -n $p ]] || continue
    if (( ${#pane_ids[@]} > 1 )); then
      (( i > 0 )) && echo
      printf '\033[7m %s \033[0m\n' "$p"
    fi
    herdr pane read "$p" --source visible --format ansi 2>&1 | tr -d '\r'
  done
  exit 0
fi

# ------------------------------------------------------------------- main mode
command -v jq >/dev/null 2>&1 || die 'jq が見つかりません'
command -v fzf >/dev/null 2>&1 || die 'fzf が見つかりません'

# HERDR_ACTIVE_* はキーバインドから起動されたときに herdr が渡す。
# HERDR_PANE_ID はこのスクリプトが動いている一時 pane 自身の id。
ws=${HERDR_ACTIVE_WORKSPACE_ID:-${HERDR_WORKSPACE_ID:-}}
if [[ -z $ws ]]; then
  ws=$(herdr workspace list 2>/dev/null |
    jq -r 'first(.result.workspaces[] | select(.focused) | .workspace_id) // empty')
fi
[[ -n $ws ]] || die 'workspace id を解決できませんでした'

self_pane=${HERDR_PANE_ID:-}
active_pane=${HERDR_ACTIVE_PANE_ID:-}

tabs_json=$(herdr tab list --workspace "$ws") || die "herdr tab list --workspace $ws に失敗しました"
panes_json=$(herdr pane list --workspace "$ws") || die "herdr pane list --workspace $ws に失敗しました"

# 現在の tab。環境変数が無ければ tab list の focused から拾う。
active_tab=${HERDR_ACTIVE_TAB_ID:-}
if [[ -z $active_tab ]]; then
  active_tab=$(jq -r 'first(.result.tabs[] | select(.focused) | .tab_id) // empty' <<<"$tabs_json")
fi

# 出力: <tab_id> TAB <表示ラベル> TAB <pane_id,pane_id,...>
# pane の並び順は 起動前にフォーカスしていた pane > focused > 残り。
# ピッカー自身の一時 pane は必ず除外する（自分自身をプレビューしてしまうため）。
rows=$(
  jq -n -r \
    --argjson tabs "$tabs_json" \
    --argjson panes "$panes_json" \
    --arg self "$self_pane" \
    --arg active "$active_pane" '
    ($panes.result.panes // []) | map(select(.pane_id != $self)) as $pl
    | ($tabs.result.tabs // [])[]
    | . as $t
    | ($pl | map(select(.tab_id == $t.tab_id))) as $tp
    | (
        ($tp | map(select(.pane_id == $active)))
        + ($tp | map(select(.pane_id != $active and .focused)))
        + ($tp | map(select(.pane_id != $active and (.focused | not))))
      ) as $tp
    | (($t.number // 0) | tostring) as $n
    # herdr が自動採番したラベル（数字だけ）は番号と重複するので出さない
    | (($t.label // "") | if test("^[0-9]*$") then "" else ": " + . end) as $label
    | (if ($tp | length) > 1 then "  [\($tp | length) panes]" else "" end) as $panes_hint
    | (if ($t.agent_status // "unknown") == "unknown" then "" else "  <\($t.agent_status)>" end) as $agent
    | [
        $t.tab_id,
        $n + $label + $panes_hint + $agent,
        ($tp | map(.pane_id) | join(","))
      ]
    | @tsv
  '
) || die 'tab / pane の突き合わせ (jq) に失敗しました'

[[ -n $rows ]] || die "workspace $ws に tab が見つかりませんでした"

# 起動時のカーソルを現在の tab に合わせる。fzf の pos() は 1 始まり。
start_pos=1
if [[ -n $active_tab ]]; then
  n=$(printf '%s\n' "$rows" | grep -n -m1 -F "$active_tab"$'\t' | cut -d: -f1)
  [[ -n ${n:-} ]] && start_pos=$n
fi

# tab 一覧側は tab 名が収まる最小幅だけ取り、残りは全部プレビューに回す。
# awk の length は UTF-8 で多めに数えるが、広くなる方向なので実害はない。
list_w=$(printf '%s\n' "$rows" | cut -f2 | awk '{ if (length($0) > m) m = length($0) } END { print m + 4 }')
[[ $list_w =~ ^[0-9]+$ ]] || list_w=20
(( list_w < 17 )) && list_w=17   # ヘッダ "j/k  Enter  Esc" が収まる幅
(( list_w > 40 )) && list_w=40
term_w=$(stty size 2>/dev/null </dev/tty | cut -d' ' -f2)
if ! [[ ${term_w:-} =~ ^[0-9]+$ ]] && [[ -n $self_pane ]]; then
  # /dev/tty が使えない場合は herdr に自分の pane の幅を聞く
  term_w=$(herdr pane layout --pane "$self_pane" 2>/dev/null |
    jq -r --arg p "$self_pane" \
      'first(.result.layout.panes[] | select(.pane_id == $p) | .rect.width) // empty')
fi
if [[ ${term_w:-} =~ ^[0-9]+$ ]] && (( term_w > list_w + 20 )); then
  preview_win="right,$((term_w - list_w)),border-left,nowrap"
else
  preview_win='right,85%,border-left,nowrap'
fi

selected=$(
  printf '%s\n' "$rows" | fzf \
    --delimiter=$'\t' \
    --with-nth=2 \
    --disabled \
    --cycle \
    --layout=reverse \
    --info=hidden \
    --prompt='tab> ' \
    --header='j/k  Enter  Esc' \
    --bind='j:down,k:up,ctrl-n:down,ctrl-p:up,g:first,G:last' \
    --bind='ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up' \
    --bind="load:pos($start_pos)" \
    --preview="$(printf '%q' "$self") --preview {3}" \
    --preview-window="$preview_win"
) || exit 0

tab_id=${selected%%$'\t'*}
[[ -n $tab_id ]] || exit 0
herdr tab focus "$tab_id" >/dev/null || die "herdr tab focus $tab_id に失敗しました"
