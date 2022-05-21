hs.hotkey.bind({"ctrl"}, "t", function()
    local kitty = hs.application.get("kitty")
    if kitty == nil then
        hs.application.launchOrFocus("/Applications/kitty.app")
    elseif kitty:isFrontmost() then
        kitty:hide()
    else
        local space = hs.spaces.focusedSpace()
        local win = kitty:focusedWindow()
        win = win:toggleFullScreen()
        win = win:toggleFullScreen()
        kitty:hide()
        hs.spaces.moveWindowToSpace(win, space)
        win:focus()
    end
end)
