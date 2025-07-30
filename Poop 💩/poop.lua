-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Basic Info
local CurrentName = "unknown Hub"
local CurrentGame = "Poop 💩 [Early Access Release]"
local DefaultVersion = "v1.0"
local VersionFile = "unknown_Version.txt"

-- Version Storage
local function LoadVersion()
    if isfile(VersionFile) then
        return readfile(VersionFile):match("^%s*(.-)%s*$") or DefaultVersion
    else
        return DefaultVersion
    end
end
local function SaveVersion(ver)
    writefile(VersionFile, ver)
end
local CurrentVersion = LoadVersion()

-- Window
local Window = Rayfield:CreateWindow({
    Name = string.format("%s | %s | %s", CurrentName, CurrentGame, CurrentVersion),
    LoadingTitle = "Loading " .. CurrentName,
    LoadingSubtitle = "By Unknown Team",
    ShowText = "Show",
    Icon = "hammer", -- Lucide icon
    Theme = "Dark",
    ConfigurationSaving = { Enabled = true, FolderName = "PoopHub", FileName = "config" },
    Discord = { Enabled = true, Invite = "noinvitelink", RememberJoins = true },
    KeySystem = false
})

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Teleport positions
local bestSpotPos = Vector3.new(100, -5.75, 3.693)
local spawnPos = Vector3.new(0.795, 4.75, -7.693)

-- Create BestSpot marker
if not workspace:FindFirstChild("BestSpotMarker") then
    local marker = Instance.new("Part", workspace)
    marker.Name = "BestSpotMarker"
    marker.Size = Vector3.new(5, 2, 5)
    marker.Position = bestSpotPos
    marker.Anchored = true
    marker.Transparency = 0.5
    marker.BrickColor = BrickColor.new("Bright orange")
end

-- BOOLEAN FLAG STORAGE
local autoFarmEnabled, autoSellEnabled, autoRotate = false, false, false
local autoFarmSpeed, autoSellSpeed = 1, 1

-- Function: Teleport helper
local function teleportTo(pos, name)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(pos)
    Rayfield:Notify({ Title = "Teleported!", Content = "You arrived at: " .. name, Duration = 2 })
end

-- MAIN TAB
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

-- FARMING TAB
local FarmTab = Window:CreateTab("Farming", "leaf")
FarmTab:CreateToggle({
    Name = "Enable AutoFarm",
    Icon = "cpu",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(val)
        autoFarmEnabled = val
        Rayfield:Notify({ Title = "AutoFarm", Content = val and "Enabled" or "Disabled", Duration = 2 })
        task.spawn(function()
            while autoFarmEnabled do
                task.wait(autoFarmSpeed)
                ReplicatedStorage:WaitForChild("PoopChargeStart"):FireServer()
                ReplicatedStorage:WaitForChild("PoopEvent"):FireServer(1)
            end
        end)
    end
})
FarmTab:CreateSlider({
    Name = "AutoFarm Speed",
    Icon = "gauge",
    Range = {0.1, 5}, Increment = 0.1,
    CurrentValue = autoFarmSpeed,
    Flag = "FarmSpeed",
    Callback = function(val) autoFarmSpeed = val end
})
FarmTab:CreateToggle({
    Name = "Enable AutoSell",
    Icon = "repeat",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(val)
        autoSellEnabled = val
        Rayfield:Notify({ Title = "AutoSell", Content = val and "Enabled" or "Disabled", Duration = 2 })
        task.spawn(function()
            while autoSellEnabled do
                task.wait(autoSellSpeed)
                ReplicatedStorage:WaitForChild("PoopResponseChosen"):FireServer("2. [I want to sell my inventory.]")
            end
        end)
    end
})
FarmTab:CreateSlider({
    Name = "AutoSell Speed",
    Icon = "clock",
    Range = {0.1, 5}, Increment = 0.1,
    CurrentValue = autoSellSpeed,
    Flag = "SellSpeed",
    Callback = function(val) autoSellSpeed = val end
})

-- SELL TAB
local SellTab = Window:CreateTab("Money Up", "dollar-sign")
SellTab:CreateButton({
    Name = "🪙 Sell All Inventory",
    Icon = "coin",
    Callback = function()
        ReplicatedStorage:WaitForChild("PoopResponseChosen"):FireServer("2. [I want to sell my inventory.]")
        Rayfield:Notify({ Title = "Sold!", Content = "Inventory sold.", Duration = 2 })
    end
})

-- TELEPORT TAB
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

-- HIDE UI TAB
local HideTab = Window:CreateTab("Hide UI", "eye-off")

-- Function to hide Overhead UI (PlayerNameTag)
local function HideOverhead()
	local gui = LocalPlayer:FindFirstChild("PlayerGui")
	if not gui then return end
	local tag = gui:FindFirstChild("PlayerNameTag")
	if tag then
		local name = tag:FindFirstChild("PlayerNameLabel")
		local level = tag:FindFirstChild("LevelNameLabel")
		if name then name.Text = "???" end
		if level then level.Text = "???" end
	end
end

-- Function to hide Money UI
local function HideMoneyUI()
	local gui = LocalPlayer:FindFirstChild("PlayerGui")
	if not gui then return end
	local moneyUI = gui:FindFirstChild("Money/LevelUI")
	if moneyUI then
		local display = moneyUI:FindFirstChild("LevelDisplayUI")
		if display then
			local money = display:FindFirstChild("MoneyLabel")
			if money and money:IsA("TextLabel") then
				money.Text = "$999999"
			end
		end
	end
end

-- Function to set all leaderstats to 999
local function HideLeaderstats()
	local stats = LocalPlayer:FindFirstChild("leaderstats")
	if not stats then return end
	for _, v in pairs({"BiggestPoop", "🔥", "Money"}) do
		local stat = stats:FindFirstChild(v)
		if stat and (stat:IsA("IntValue") or stat:IsA("NumberValue")) then
			stat.Value = 999
		end
	end
end

-- 🟦 Create Buttons
HideTab:CreateButton({
	Name = "🙈 Hide Overhead UI",
	Icon = "eye-off",
	Callback = function()
		HideOverhead()
		Rayfield:Notify({
			Title = "Overhead Hidden",
			Content = "Player name and level tags hidden.",
			Duration = 4,
			Image = "eye-off"
		})
	end
})

HideTab:CreateButton({
	Name = "💸 Hide Money UI",
	Icon = "dollar-sign",
	Callback = function()
		HideMoneyUI()
		Rayfield:Notify({
			Title = "Money UI Hidden",
			Content = "Money display has been hidden.",
			Duration = 4,
			Image = "dollar-sign"
		})
	end
})

HideTab:CreateButton({
	Name = "📊 Set Leaderstats to 999",
	Icon = "trending-up",
	Callback = function()
		HideLeaderstats()
		Rayfield:Notify({
			Title = "Leaderstats Updated",
			Content = "Set all stat values to 999 (visual only).",
			Duration = 4,
			Image = "list"
		})
	end
})

-- SETTINGS TAB
local SettingsTab = Window:CreateTab("Settings", "settings")
SettingsTab:CreateToggle({
    Name = "📱 Auto‑Rotate UI (Mobile)",
    Icon = "rotate-cw",
    CurrentValue = false,
    Flag = "AutoRotate",
    Callback = function(val)
        autoRotate = val
        Rayfield:Notify({ Title = "AutoRotate", Content = val and "Enabled" or "Disabled", Duration = 2 })
    end
})

if UserInputService.TouchEnabled then
    RunService.RenderStepped:Connect(function()
        if autoRotate then
            local orientation = UserInputService:GetDeviceOrientation()
            local rotation = (orientation == Enum.DeviceOrientation.Portrait or orientation == Enum.DeviceOrientation.PortraitUpsideDown) and 90 or 0
            for _, gui in pairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") then gui.Rotation = rotation end
            end
        end
    end)
end

-- Version Checker
local function CheckForUpdate()
    local ok, res = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/LumeCraftors01/unknown-hub/main/Version.lua")
    end)
    if ok and res then
        local lv = res:match("%S+")
        if lv and lv ~= CurrentVersion then
            Rayfield:Notify({ Title = "⚠️ UPDATE DETECTED!", Content = "New version: "..lv, Duration = 6, Image = "alert-circle" })
            SaveVersion(lv)
            CurrentVersion = lv
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

-- Discord Reminder
task.spawn(function()
    while true do
        task.wait(300)
        Rayfield:Notify({ Title = "📢 Reminder", Content = "Join our Discord: discord.gg/yourlinkhere", Duration = 7, Image = "bell" })
    end
end)

-- Loaded Notification
Rayfield:Notify({ Title = "✅ "..CurrentName.." Loaded", Content = "All systems active!", Duration = 5, Image = "check-circle" })
