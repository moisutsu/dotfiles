hs.hotkey.bind({"ctrl"}, "t", function()
    local kitty = hs.application.get("kitty")
    if kitty == nil then
        hs.application.launchOrFocus("/Applications/kitty.app")
    elseif kitty:isFrontmost() then
        kitty:hide()
    else
        local win = kitty:mainWindow()
        local space = hs.spaces.focusedSpace()
        hs.spaces.moveWindowToSpace(win, space)
        kitty:setFrontmost()
    end
end)
