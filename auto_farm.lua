local M = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local farmEnabled = false
local selectedEnemy = nil
local selectedWorld = nil
local farmDelay = 0

local function getWorldList()
    local list = {}
    for _, world in pairs(workspace:GetChildren()) do
        if world.Name:match("^World") then
            table.insert(list, world.Name)
        end
    end
    return list
end

local function getEnemyList(worldName)
    local seen = {}
    local list = {}
    local worlds = worldName and {workspace:FindFirstChild(worldName)} or workspace:GetChildren()
    for _, world in pairs(worlds) do
        if world and world.Name:match("^World") then
            local ef = world:FindFirstChild("Enemy")
            if ef then
                for _, e in pairs(ef:GetChildren()) do
                    if not seen[e.Name] then
                        seen[e.Name] = true
                        table.insert(list, e.Name)
                    end
                end
            end
        end
    end
    return list
end

local function findEnemy(worldName, enemyName)
    local world = workspace:FindFirstChild(worldName)
    if not world then return end
    local ef = world:FindFirstChild("Enemy")
    if not ef then return end
    return ef:FindFirstChild(enemyName)
end

function M.BuildUI(tab)
    tab:AddButton("🔍 Scan World & Enemy", function()
        warn("[AutoFarm] Đang scan, chờ 5s...")
        task.delay(5, function()
            local worlds = getWorldList()
            warn("[AutoFarm] Worlds: " .. table.concat(worlds, ", "))
            local enemies = getEnemyList(selectedWorld)
            warn("[AutoFarm] Enemies: " .. table.concat(enemies, ", "))
        end)
    end)

    tab:AddDropdown("Chọn World", getWorldList(), function(v)
        selectedWorld = v
        selectedEnemy = nil
        warn("[AutoFarm] World: " .. v)
    end)

    tab:AddDropdown("Chọn Enemy", {}, function(v)
        selectedEnemy = v
        warn("[AutoFarm] Enemy: " .. v)
    end)

    tab:AddButton("🔄 Load Enemy của World", function()
        if not selectedWorld then
            warn("[AutoFarm] Chọn world trước!") return
        end
        local list = getEnemyList(selectedWorld)
        if #list == 0 then
            warn("[AutoFarm] Không có enemy trong " .. selectedWorld) return
        end
        warn("[AutoFarm] Enemy trong " .. selectedWorld .. ": " .. table.concat(list, ", "))
    end)

    tab:AddSlider("Delay (s)", 0, 5, 0, function(v)
        farmDelay = v
    end)

    tab:AddToggle("Auto Click", function(state)
        autoClickEnable = state
        if not state then return end
        task.spawn(function()
            while autoClickEnable do
                game:GetService("ReplicatedStorage").Remotes.Clicked:FireServer()

            task.wait()
        end
    end)
end)
end

    tab:AddToggle("Auto Farm", function(state)
        farmEnabled = state
        if not state then return end

        task.spawn(function()
            while farmEnabled do
                if selectedWorld and selectedEnemy then
                    local enemy = findEnemy(selectedWorld, selectedEnemy)
                    if enemy then
                        local root = enemy:FindFirstChild("HumanoidRootPart")
                        if root and LocalPlayer.Character then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = root.CFrame
                        end

                    end
                end
                task.wait(farmDelay)
            end
        end)
    end)
end

return M