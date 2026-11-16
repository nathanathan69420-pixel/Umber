local Games = {
    [4342047058] = "https://raw.githubusercontent.com/nathanathan69420-pixel/Umber/refs/heads/main/gnb.lua"
}
local function Notify(title, text, duration)
    local ok = pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", { Title = title, Text = text, Duration = duration or 5 })
    end)
    if not ok then
        task.delay(2, function()
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", { Title = title, Text = text, Duration = duration or 5 })
            end)
        end)
    end
end
local ScriptUrl = Games[game.GameId]
if not ScriptUrl then
    return
end
task.spawn(function()
    local Success, Source = pcall(function()
        return game:HttpGet(ScriptUrl .. "?v=" .. tostring(tick()))
    end)
    local _sc_s1 = not Success or type(Source) ~= "string"
    if _sc_s1 or #Source == 0 then
        Notify("Umber", "Failed to download script for this game.", 6)
        return
    end
    local Chunk, ErrorMessage = loadstring(Source)
    if not Chunk then
        Notify("Umber", "Script compile error: " .. tostring(ErrorMessage), 8)
        return
    end
    Chunk()
end)
