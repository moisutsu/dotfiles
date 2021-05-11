hs.hotkey.bind({"ctrl"}, "t", function()
    local alacritty = hs.application.get("Alacritty")
    if alacritty == nil then
        hs.application.launchOrFocus("/Applications/Alacritty.app")
    elseif alacritty:isFrontmost() then
        alacritty:hide()
    else
        hs.application.launchOrFocus("/Applications/Alacritty.app")
    end
end)
