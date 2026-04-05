local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/torudz/Toruz/refs/heads/main/main.lua"))()

local RAW = "https://raw.githubusercontent.com/torudz/Anime_leveling/main/"

local function loadModule(file)
    local src = game:HttpGet(RAW .. file)
    local fn, err = loadstring(src)
    if not fn then warn("[Loader] Lỗi load " .. file .. ": " .. tostring(err)) return {} end
    return fn()
end

--// SERVICES
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// WINDOW
local Window = Library:CreateWindow("Toru Hub | Anime Leveling", LocalPlayer.Name)

--// TABS
local Tabs = {
    AutoFarm = Window:AddTab("Auto Farm", "⚔"),
    Gacha    = Window:AddTab("Gacha",     "★"),
    Upgrade  = Window:AddTab("Upgrade",   "↑"),
    Misc     = Window:AddTab("Misc",      "🔧"),
}

--// LOAD & BUILD UI TỪNG MODULE
local AutoFarm = loadModule("AutoFarm.lua")
local Gacha    = loadModule("Gacha.lua")
local Upgrade  = loadModule("Upgrade.lua")
local Misc     = loadModule("Misc.lua")

if AutoFarm.BuildUI then AutoFarm.BuildUI(Tabs.AutoFarm) end
if Gacha.BuildUI    then Gacha.BuildUI(Tabs.Gacha)       end
if Upgrade.BuildUI  then Upgrade.BuildUI(Tabs.Upgrade)   end
if Misc.BuildUI     then Misc.BuildUI(Tabs.Misc)         end

-- Notify load xong
-- Toruz không có built-in notify nên dùng game notify hoặc tự làm
warn("[Toru Hub] Loaded! Anime Finals v2")