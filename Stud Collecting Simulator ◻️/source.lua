-- 🌌 Unknown Hub | Auto Collector + Version System
-- ✅ Undetectable, Smooth Teleport, Discord Reminders, Version Checker

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- 📌 Hub Info
local HUB_NAME     = "Unknown Hub"
local GAME_NAME    = "Stud Collecting Simulator ◻️"
local DEFAULT_VER  = "v1.0"
local VERSION_FILE = "unknown_Version.txt"

-- 📂 Version System
local function LoadVersion()
    if isfile(VERSION_FILE) then
        return (readfile(VERSION_FILE):match("^%s*(.-)%s*$") or DEFAULT_VER)
    end
    return DEFAULT_VER
end

local function SaveVersion(v)
    pcall(function() writefile(VERSION_FILE, v) end)
end

local CURRENT_VER = LoadVersion()

-- 🌟 Window
local Window = Rayfield:CreateWindow({
    Name = string.format("%s | %s | %s", HUB_NAME, GAME_NAME, CURRENT_VER),
    LoadingTitle = "Loading "..HUB_NAME.."...",
    LoadingSubtitle = "By Unknown Team",
    ShowText = "unknown hub",
    Icon = "hammer",
    Theme = "Dark",

    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UnknownHub",
        FileName = "Config"
    },

    Discord = {
        Enabled = true,
        Invite = "noinvitelink",
        RememberJoins = true
    }
})

-- ========================= MAIN TAB =========================
local MainTab = Window:CreateTab("Main", "home")

MainTab:CreateParagraph({
    Title = "📚 Information",
    Content = "Welcome to "..HUB_NAME.." — fast, safe, and easy 🍫."
})

MainTab:CreateButton({
    Name = "ℹ️ About",
    Callback = function()
        Rayfield:Notify({
            Title = "ℹ️ About",
            Content = HUB_NAME.." for "..GAME_NAME.." — smooth and simple 🎉",
            Duration = 5
        })
    end
})

MainTab:CreateButton({
    Name = "📋 Copy Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/yourlinkhere")
        Rayfield:Notify({
            Title = "📋 Copied",
            Content = "Discord link copied to clipboard.",
            Duration = 4
        })
    end
})

MainTab:CreateParagraph({
    Title = "⚠️ Disclaimer",
    Content = "Use at your own risk. We are not responsible for bans."
})

-- ========================= FARM TAB =========================
local FarmTab = Window:CreateTab("Auto Farm", "pickaxe")

local enabled = false
local loopDelay = 0.1
local walkSpeedBoost = 150
local collected = {}

-- ✅ Fire ProximityPrompt
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
    local start = root.Position
    local offset = (targetPos - start) / steps
    for i = 1, steps do
        task.wait(0.05 + math.random() * 0.05)
        root.CFrame = CFrame.new(start + offset * i + Vector3.new(
            math.random(-1,1)*0.2,
            math.random()*0.3,
            math.random(-1,1)*0.2
        ))
    end
end

-- ✅ Get Player Root
local function getRoot()
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- ✅ Collector
local function collectTool(tool)
    if collected[tool] then return end
    collected[tool] = true

    task.delay(3, function() -- wait 3s after spawn
        if not enabled then return end
        local root = getRoot()
        local handle = tool:FindFirstChild("Handle")
        if not handle then return end

        for _, prompt in ipairs(tool:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local dist = (root.Position - handle.Position).Magnitude
                if dist < 80 then
                    smoothTeleport(root, handle.Position + Vector3.new(0,3,0))
                    task.wait(0.05 + math.random() * 0.05)
                    firePrompt(prompt)
                end
            end
        end
    end)
end

-- Toggle
FarmTab:CreateToggle({
    Name = "⚡ Enable Auto Collector",
    CurrentValue = false,
    Flag = "AutoCollectorToggle",
    Callback = function(state)
        enabled = state
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = state and walkSpeedBoost or 16
    end,
})

-- Speed Slider
FarmTab:CreateSlider({
    Name = "⏱️ Collection Speed (lower = faster)",
    Range = {0.05, 1},
    Increment = 0.05,
    CurrentValue = 0.1,
    Suffix = "s",
    Flag = "CollectorSpeed",
    Callback = function(v) loopDelay = v end,
})

-- Watch new tools
workspace.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        collectTool(child)
    end
end)

-- Loop existing tools
task.spawn(function()
    while task.wait(loopDelay + math.random()*0.05) do
        if not enabled then continue end
        for _, tool in ipairs(workspace:GetDescendants()) do
            if tool:IsA("Tool") then
                collectTool(tool)
            end
        end
    end
end)

-- ========================= SETTINGS TAB =========================
local SettingsTab = Window:CreateTab("Settings", "settings")

SettingsTab:CreateSection("⚙️ Configuration")

SettingsTab:CreateButton({
    Name = "💾 Load Configuration",
    Callback = function()
        Rayfield:LoadConfiguration()
        Rayfield:Notify({
            Title = "✅ Loaded",
            Content = "Your configuration has been applied.",
            Duration = 4
        })
    end
})

-- ========================= VERSION CHECKER =========================
local function CheckForUpdate()
    local success, response = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/LumeCraftors01/unknown-hub/refs/heads/main/Stud%20Collecting%20Simulator%20%E2%97%BB%EF%B8%8F/version.lua")
    end)

    if success and response then
        local latest = response:match("^%s*(.-)%s*$")
        if latest and latest ~= CURRENT_VER then
            Rayfield:Notify({
                Title = "⚠️ Update Available",
                Content = "New version: "..latest.." → rejoin to apply.",
                Duration = 8
            })
            SaveVersion(latest)
            CURRENT_VER = latest
            Window:SetName(string.format("%s | %s | %s", HUB_NAME, GAME_NAME, CURRENT_VER))
        end
    else
        warn("⚠️ Update check failed.")
    end
end

task.spawn(function()
    while task.wait(30) do
        CheckForUpdate()
    end
end)

-- ========================= REMINDERS =========================
task.spawn(function()
    while task.wait(300) do
        Rayfield:Notify({
            Title = "📢 Reminder",
            Content = "Join our Discord: discord.gg/yourlinkhere",
            Duration = 7
        })
    end
end)

-- ========================= LOADED NOTIFICATION =========================
Rayfield:Notify({
    Title = "✅ "..HUB_NAME.." Loaded",
    Content = "All systems active. Enjoy farming ⚡",
    Duration = 5
})
