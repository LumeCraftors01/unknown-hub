-- // Rayfield Loader
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "unknown hub | Stud Collecting Simulator",
    LoadingTitle = "stud collecting simulator",
    LoadingSubtitle = "by unknown hub",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "AutoCollector",
       FileName = "CollectorCFG"
    }
})

local MainTab = Window:CreateTab("Main", 4483362458)

local enabled = false
local loopDelay = 0.1 -- default speed
local walkSpeedBoost = 150

-- Toggle
MainTab:CreateToggle({
    Name = "Enable Auto Collector",
    CurrentValue = false,
    Flag = "AutoCollectorToggle",
    Callback = function(state)
        enabled = state

        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")

        if enabled then
            hum.WalkSpeed = walkSpeedBoost
        else
            hum.WalkSpeed = 16 -- default reset
        end
    end,
})

-- Speed Slider
MainTab:CreateSlider({
    Name = "Collection Speed (lower = faster)",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = 0.1,
    Flag = "CollectorSpeed",
    Callback = function(val)
        loopDelay = val
    end,
})

-- ✅ Fire Prompt
local function firePrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        pcall(function()
            prompt.HoldDuration = 0
            prompt.MaxActivationDistance = 1000
            fireproximityprompt(prompt)
            print("✅ Collected:", prompt:GetFullName())
        end)
    end
end

-- ✅ Smooth Teleport
local function smoothTeleport(root, targetPos)
    local steps = math.random(3, 6)
    local start = root.CFrame.Position
    local offset = (targetPos - start) / steps
    for i = 1, steps do
        task.wait(0.05 + math.random() * 0.05)
        root.CFrame = CFrame.new(start + offset * i + Vector3.new(
            math.random(-1, 1) * 0.2,
            math.random() * 0.3,
            math.random(-1, 1) * 0.2
        ))
    end
end

-- ✅ Get Player Root
local function getRoot()
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- ✅ Collector for one tool
local function collectTool(tool)
    task.delay(3, function() -- wait 3s after spawn
        if not enabled then return end
        local root = getRoot()
        local handle = tool:FindFirstChild("Handle")
        if handle then
            for _, prompt in ipairs(tool:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    local dist = (root.Position - handle.Position).Magnitude
                    if dist < 80 then
                        smoothTeleport(root, handle.Position + Vector3.new(0, 3, 0))
                        task.wait(0.05 + math.random() * 0.05)
                        firePrompt(prompt)
                    end
                end
            end
        end
    end)
end

-- ✅ Watch for new Tools
workspace.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        collectTool(child)
    end
end)

-- ✅ Existing Tools loop (for ones already in workspace)
task.spawn(function()
    while task.wait(loopDelay + math.random() * 0.05) do
        if not enabled then continue end
        for _, tool in ipairs(workspace:GetDescendants()) do
            if tool:IsA("Tool") then
                collectTool(tool)
            end
        end
    end
end)
