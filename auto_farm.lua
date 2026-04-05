
local AutoFarm = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local farmEnabled = false
local autoClickEnable = false
local selectedEnemy = nil
local selectedWorld = nil

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
    local world = workspace:FindFirstChild(worldName)
    if not world then return list end
    local ef = world:FindFirstChild("Enemy")
    if not ef then return list end
    for _, e in pairs(ef:GetChildren()) do
        if not seen[e.Name] then
            seen[e.Name] = true
            table.insert(list, e.Name)
        end
    end
    return list
end

local function findAliveEnemy(worldName, enemyName)
    local world = workspace:FindFirstChild(worldName)
    if not world then return end
    local ef = world:FindFirstChild("Enemy")
    if not ef then return end
    for _, e in pairs(ef:GetChildren()) do
        if e.Name == enemyName then
            local hp = e:GetAttribute("CurrentHP")
            if hp then
                local current = tonumber(tostring(hp):split(";")[2])
                if current and current > 0 then
                    return e
                end
            end
        end
    end
end

function AutoFarm.BuildUI(tab)
    tab:AddDropdown("Chọn World", getWorldList(), function(v)
        selectedWorld = v
        selectedEnemy = nil
        local list = getEnemyList(v)
        warn("[AutoFarm] Enemy trong " .. v .. ": " .. table.concat(list, ", "))
    end)

    tab:AddDropdown("Chọn Enemy", getEnemyList(getWorldList()[1] or "World1"), function(v)
        selectedEnemy = v
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

    tab:AddToggle("Auto Farm", function(state)
        farmEnabled = state
        if not state then return end
        task.spawn(function()
            while farmEnabled do
                if selectedWorld and selectedEnemy then
                    local enemy = findAliveEnemy(selectedWorld, selectedEnemy)
                    if enemy then
                        local root = enemy:FindFirstChild("HumanoidRootPart")
                        if root and LocalPlayer.Character then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = root.CFrame
                        end
                    end
                end
                task.wait()
            end
        end)
    end)
end

return AutoFarm
