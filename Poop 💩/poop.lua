--// Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--// Metadata
local CurrentName = "unknown Hub"
local CurrentGame = "Poop 💩 [Early Access Release]"
local DefaultVersion = "v1.0"
local VersionFile = "unknown_Version.txt"

--// Version Handling
local function LoadVersion()
    if isfile(VersionFile) then
        return readfile(VersionFile):match("^%s*(.-)%s*$") or DefaultVersion
    end
    return DefaultVersion
end
local function SaveVersion(version)
    writefile(VersionFile, version)
end
local CurrentVersion = LoadVersion()

--// Create Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = string.format("%s | %s | %s", CurrentName, CurrentGame, CurrentVersion),
    LoadingTitle = "Loading "..CurrentName,
    LoadingSubtitle = "By Unknown Team",
    Icon = "gavel",
    Theme = "Dark",
    ShowText = "Show",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PoopHub",
        FileName = CurrentGame:gsub("%s+", "_").."_config"
    },
    Discord = {
        Enabled = true,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false
})

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// Remote References
local PoopChargeStart = ReplicatedStorage:WaitForChild("PoopChargeStart")
local PoopEvent = ReplicatedStorage:WaitForChild("PoopEvent")
local PoopResponseChosen = ReplicatedStorage:WaitForChild("PoopResponseChosen")

--// Settings
local autoFarmEnabled, autoSellEnabled, autoRotate = false, false, false
local autoFarmSpeed, autoSellSpeed = 1, 1
local bestSpotPos = Vector3.new(100, -5.75, 3.693)
local spawnPos = Vector3.new(0.795, 4.75, -7.693)

--// Create Best Spot Marker
if not workspace:FindFirstChild("BestSpotMarker") then
    local marker = Instance.new("Part")
    marker.Name = "BestSpotMarker"
    marker.Size = Vector3.new(5, 2, 5)
    marker.Position = bestSpotPos
    marker.Anchored = true
    marker.Transparency = 0.5
    marker.BrickColor = BrickColor.new("Bright orange")
    marker.Parent = workspace
end

--// Teleport Utility
local function teleportTo(pos, name)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(pos)
    Rayfield:Notify({ Title = "Teleported", Content = "Arrived at: "..name, Duration = 2 })
end

--// MAIN TAB
local MainTab = Window:CreateTab("Main", "info")
MainTab:CreateParagraph({ Title = "Information 📚", Content = "Easy and enjoyable experience 🍫." })
MainTab:CreateButton({
    Name = "ℹ️ About",
    Icon = "info",
    Callback = function()
        Rayfield:Notify({ Title = "About", Content = CurrentName.." for "..CurrentGame, Duration = 5 })
    end
})
MainTab:CreateButton({
    Name = "📋 Copy Discord Link",
    Icon = "clipboard",
    Callback = function()
        setclipboard("https://discord.gg/yourlinkhere")
        Rayfield:Notify({ Title = "Copied", Content = "Discord link copied!", Duration = 4 })
    end
})
MainTab:CreateParagraph({ Title = "⚠️ Disclaimer", Content = "Use at your own risk. We are not responsible for bans." })

--// FARMING TAB
local FarmTab = Window:CreateTab("Farming", "leaf")
FarmTab:CreateSection("AutoFarm Controls")

FarmTab:CreateToggle({
    Name = "Enable AutoFarm",
    Icon = "cpu",
    CurrentValue = false,
    Callback = function(val)
        autoFarmEnabled = val
        Rayfield:Notify({ Title = "AutoFarm", Content = val and "Enabled" or "Disabled", Duration = 2 })
        task.spawn(function()
            while autoFarmEnabled do
                task.wait(autoFarmSpeed)
                PoopChargeStart:FireServer()
                PoopEvent:FireServer(1)
            end
        end)
    end
})

FarmTab:CreateSlider({
    Name = "AutoFarm Speed",
    Icon = "gauge",
    Range = {0.1, 5},
    Increment = 0.1,
    CurrentValue = autoFarmSpeed,
    Callback = function(val)
        autoFarmSpeed = val
        Rayfield:Notify({ Title = "Speed Updated", Content = "AutoFarm speed set to "..val, Duration = 2 })
    end
})

FarmTab:CreateToggle({
    Name = "Enable AutoSell",
    Icon = "repeat",
    CurrentValue = false,
    Callback = function(val)
        autoSellEnabled = val
        Rayfield:Notify({ Title = "AutoSell", Content = val and "Enabled" or "Disabled", Duration = 2 })
        task.spawn(function()
            while autoSellEnabled do
                task.wait(autoSellSpeed)
                PoopResponseChosen:FireServer("2. [I want to sell my inventory.]")
            end
        end)
    end
})

FarmTab:CreateSlider({
    Name = "AutoSell Speed",
    Icon = "clock",
    Range = {0.1, 5},
    Increment = 0.1,
    CurrentValue = autoSellSpeed,
    Callback = function(val)
        autoSellSpeed = val
        Rayfield:Notify({ Title = "Speed Updated", Content = "AutoSell speed set to "..val, Duration = 2 })
    end
})

--// SELL TAB
local SellTab = Window:CreateTab("Money Up", "dollar-sign")
SellTab:CreateButton({
    Name = "🪙 Sell All Inventory",
    Icon = "coin",
    Callback = function()
        PoopResponseChosen:FireServer("2. [I want to sell my inventory.]")
        Rayfield:Notify({ Title = "Sold!", Content = "Inventory sold.", Duration = 2 })
    end
})

--// TELEPORT TAB
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
TeleportTab:CreateButton({
    Name = "🚀 Teleport to Best Spot",
    Icon = "navigation",
    Callback = function() teleportTo(bestSpotPos, "Best Spot") end
})
TeleportTab:CreateButton({
    Name = "🏠 Teleport to Spawn",
    Icon = "home",
    Callback = function() teleportTo(spawnPos, "Spawn") end
})

--// HIDE UI TAB
local HideTab = Window:CreateTab("Hide UI", "eye-off")
HideTab:CreateButton({
    Name = "🙈 Hide Overhead UI",
    Icon = "eye-off",
    Callback = function()
        local tag = PlayerGui:FindFirstChild("PlayerNameTag")
        if tag then
            for _, lbl in pairs({"PlayerNameLabel", "LevelNameLabel"}) do
                local el = tag:FindFirstChild(lbl)
                if el then el.Text = "???" end
            end
        end
        Rayfield:Notify({ Title = "Overhead Hidden", Content = "Name and level tags hidden.", Duration = 4 })
    end
})
HideTab:CreateButton({
    Name = "💸 Hide Money UI",
    Icon = "dollar-sign",
    Callback = function()
        local ui = PlayerGui:FindFirstChild("Money/LevelUI")
        if ui then
            local label = ui:FindFirstChild("LevelDisplayUI") and ui.LevelDisplayUI:FindFirstChild("MoneyLabel")
            if label then label.Text = "$999999" end
        end
        Rayfield:Notify({ Title = "Money UI Hidden", Content = "Money display changed.", Duration = 4 })
    end
})
HideTab:CreateButton({
    Name = "📊 Set Leaderstats to 999",
    Icon = "trending-up",
    Callback = function()
        local stats = LocalPlayer:FindFirstChild("leaderstats")
        if stats then
            for _, statName in pairs({"BiggestPoop", "🔥", "Money"}) do
                local stat = stats:FindFirstChild(statName)
                if stat then stat.Value = 999 end
            end
        end
        Rayfield:Notify({ Title = "Leaderstats Changed", Content = "Set to 999 (client only).", Duration = 4 })
    end
})

--// SETTINGS TAB
local SettingsTab = Window:CreateTab("Settings", "settings")
SettingsTab:CreateToggle({
    Name = "📱 Auto‑Rotate UI (Mobile)",
    Icon = "rotate-cw",
    CurrentValue = false,
    Callback = function(val)
        autoRotate = val
        Rayfield:Notify({ Title = "AutoRotate", Content = val and "Enabled" or "Disabled", Duration = 2 })
    end
})

--// Mobile Auto-Rotate Handler
if UserInputService.TouchEnabled then
    RunService.RenderStepped:Connect(function()
        if autoRotate then
            local orientation = UserInputService:GetDeviceOrientation()
            local rot = (orientation == Enum.DeviceOrientation.Portrait or orientation == Enum.DeviceOrientation.PortraitUpsideDown) and 90 or 0
            for _, gui in ipairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    gui.Rotation = rot
                end
            end
        end
    end)
end

--// VERSION CHECKER
local function CheckForUpdate()
    local success, response = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/LumeCraftors01/unknown-hub/refs/heads/main/Poop%20%F0%9F%92%A9/Version.lua")
    end)
    if success and response then
        local newVersion = response:match("%S+")
        if newVersion and newVersion ~= CurrentVersion then
            Rayfield:Notify({
                Title = "⚠️ Update Detected",
                Content = "New version: "..newVersion,
                Duration = 6,
                Image = "alert-circle"
            })
            SaveVersion(newVersion)
            CurrentVersion = newVersion
            Window:SetName(string.format("%s | %s | %s", CurrentName, CurrentGame, CurrentVersion))
        end
    end
end

task.spawn(function()
    while true do
        task.wait(30)
        CheckForUpdate()
    end
end)

--// Discord Reminder
task.spawn(function()
    while true do
        task.wait(300)
        Rayfield:Notify({
            Title = "📢 Reminder",
            Content = "Join our Discord: discord.gg/yourlinkhere",
            Duration = 7,
            Image = "bell"
        })
    end
end)

--// Final Notification
Rayfield:Notify({
    Title = "✅ "..CurrentName.." Loaded",
    Content = "All systems active!",
    Duration = 5,
    Image = "check-circle"
})
