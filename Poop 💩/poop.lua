-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Basic Info
local CurrentName = "unknown Hub"
local CurrentGame = "Poop 💩 [Early Access Release]"
local DefaultVersion = "v1.0"
local VersionFile = "unknown_Version.txt"

-- Persistent Version Storage
local function LoadVersion()
	if isfile(VersionFile) then
		return readfile(VersionFile):match("^%s*(.-)%s*$") or DefaultVersion
	else
		return DefaultVersion
	end
end
local function SaveVersion(version)
	writefile(VersionFile, version)
end
local CurrentVersion = LoadVersion()

-- Create Main Window
local Window = Rayfield:CreateWindow({
	Name = string.format("%s | %s | %s", CurrentName, CurrentGame, CurrentVersion),
	LoadingTitle = "Loading Unknown Hub...",
	LoadingSubtitle = "By Unknown Team",
	ShowText = "Show",
	Icon = "hammer",
	Theme = "Dark",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "Poop",
		FileName = "unknown hub"
	},
	Discord = {
		Enabled = true,
		Invite = "noinvitelink",
		RememberJoins = true
	}
})

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Teleport Positions
local bestSpotPos = Vector3.new(100, -5.75, 3.693)
local spawnPos = Vector3.new(0.795, 4.75, -7.693)

-- Best Spot Marker
local marker = Instance.new("Part")
marker.Name = "BestSpotMarker"
marker.Size = Vector3.new(5, 2, 5)
marker.Position = bestSpotPos
marker.Anchored = true
marker.Transparency = 0.5
marker.BrickColor = BrickColor.new("Bright orange")
marker.Parent = workspace

-- Main Tab
local MainTab = Window:CreateTab("Main", "home")
MainTab:CreateParagraph({
	Title = "Information 📚",
	Content = "will your experience to enjoy and easy 🍫."
})
MainTab:CreateButton({
	Name = "ℹ️ About",
	Callback = function()
		Rayfield:Notify({
			Title = "About",
			Content = CurrentName.." for "..CurrentGame.." — easy to use and easy to get and will your experience to be easy 🎉.",
			Duration = 5
		})
	end
})
MainTab:CreateButton({
	Name = "📋 Copy Discord Link",
	Callback = function()
		setclipboard("https://discord.gg/yourlinkhere")
		Rayfield:Notify({
			Title = "Copied",
			Content = "Discord link copied.",
			Duration = 4
		})
	end
})
MainTab:CreateParagraph({
	Title = "⚠️ Disclaimer",
	Content = "Use this at your own risk. We are not responsible for bans."
})

-- Farming Tab
local AutoFarmTab = Window:CreateTab("Farming", "bubbles")
local autoFarmEnabled, autoFarmSpeed = false, 1
local autoSellEnabled, autoSellSpeed = false, 1
local autoRotate = false

AutoFarmTab:CreateToggle({
	Name = "Enable AutoFarm",
	CurrentValue = false,
	Callback = function(val)
		autoFarmEnabled = val
		Rayfield:Notify({
			Title = "AutoFarm",
			Content = val and "Enabled" or "Disabled",
			Duration = 2
		})
	end
})
AutoFarmTab:CreateSlider({
	Name = "AutoFarm Speed",
	Range = {0.1, 5},
	Increment = 0.1,
	CurrentValue = 1,
	Callback = function(val)
		autoFarmSpeed = val
	end
})
task.spawn(function()
	while true do
		task.wait(autoFarmSpeed)
		if autoFarmEnabled then
			ReplicatedStorage:WaitForChild("PoopChargeStart"):FireServer()
			ReplicatedStorage:WaitForChild("PoopEvent"):FireServer(1)
		end
	end
end)

AutoFarmTab:CreateToggle({
	Name = "Enable AutoSell",
	CurrentValue = false,
	Callback = function(val)
		autoSellEnabled = val
		Rayfield:Notify({
			Title = "AutoSell",
			Content = val and "Enabled" or "Disabled",
			Duration = 2
		})
	end
})
AutoFarmTab:CreateSlider({
	Name = "AutoSell Speed",
	Range = {0.1, 5},
	Increment = 0.1,
	CurrentValue = 1,
	Callback = function(val)
		autoSellSpeed = val
	end
})
task.spawn(function()
	while true do
		task.wait(autoSellSpeed)
		if autoSellEnabled then
			ReplicatedStorage:WaitForChild("PoopResponseChosen"):FireServer("2. [I want to sell my inventory.]")
		end
	end
end)

-- Sell Tab
local SellTab = Window:CreateTab("Money Up", "circle-dollar-sign")
SellTab:CreateButton({
	Name = "🪙 Sell All Inventory",
	Callback = function()
		ReplicatedStorage:WaitForChild("PoopResponseChosen"):FireServer("2. [I want to sell my inventory.]")
		Rayfield:Notify({
			Title = "Sold!",
			Content = "Your inventory has been sold.",
			Duration = 2
		})
	end
})

-- Teleport Tab
local TeleportTab = Window:CreateTab("Teleport", "map")
local function teleportTo(pos, name)
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")
	hrp.CFrame = CFrame.new(pos)
	Rayfield:Notify({
		Title = "Teleported!",
		Content = "You arrived at: " .. name,
		Duration = 2
	})
end
TeleportTab:CreateButton({
	Name = "🚀 Teleport to Best Spot",
	Callback = function()
		teleportTo(bestSpotPos, "Best Spot")
	end
})
TeleportTab:CreateButton({
	Name = "🏠 Teleport to Spawn",
	Callback = function()
		teleportTo(spawnPos, "Spawn")
	end
})

-- Hide UI Tab
local HideTab = Window:CreateTab("Hide UI", "eye-off")
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
	Name = "Hide Overhead UI",
	Callback = HideOverhead,
})

HideTab:CreateButton({
	Name = "Hide Money UI",
	Callback = HideMoneyUI,
})

HideTab:CreateButton({
	Name = "Set Leaderstats to 999",
	Callback = HideLeaderstats,
})

-- Settings Tab
local SettingsTab = Window:CreateTab("Setting", "settings")
SettingsTab:CreateToggle({
	Name = "📱 Auto-Rotate UI on Mobile",
	CurrentValue = false,
	Callback = function(val)
		autoRotate = val
	end
})
SettingsTab:CreateSection("⚙️ Configuration")
SettingsTab:CreateParagraph({
	Title = "📢 Info",
	Content = "This configuration area saves/loads your hub settings ⛏️."
})
SettingsTab:CreateButton({
	Name = "💾 Load Configuration",
	Callback = function()
		Rayfield:LoadConfiguration()
		Rayfield:Notify({
			Title = "✅ Loaded",
			Content = "Configuration loaded successfully.",
			Duration = 4
		})
	end
})

-- Auto-Rotate UI on Mobile
if UserInputService.TouchEnabled then
	RunService.RenderStepped:Connect(function()
		if autoRotate then
			local orientation = UserInputService:GetDeviceOrientation()
			local rotation = 0
			if orientation == Enum.DeviceOrientation.Portrait or orientation == Enum.DeviceOrientation.PortraitUpsideDown then
				rotation = 90
			end
			for _, screenGui in pairs(PlayerGui:GetChildren()) do
				if screenGui:IsA("ScreenGui") then
					screenGui.Rotation = rotation
				end
			end
		end
	end)
end

-- Version Checker
local function CheckForUpdate()
	local success, response = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/LumeCraftors01/unknown-hub/refs/heads/main/Poop%20%F0%9F%92%A9/Version.lua")
	end)
	if success and response then
		local LatestVersion = response:match("^%s*(.-)%s*$")
		if LatestVersion and LatestVersion ~= CurrentVersion then
			Rayfield:Notify({
				Title = "⚠️ UPDATE DETECTED!",
				Content = "New version: "..LatestVersion..". Please rejoin.",
				Duration = 10
			})
			SaveVersion(LatestVersion)
			CurrentVersion = LatestVersion
			Window:SetName(string.format("%s | %s | %s", CurrentName, CurrentGame, CurrentVersion))
		end
	else
		warn("⚠️ Failed to check for updates.")
	end
end
task.spawn(function()
	while true do
		CheckForUpdate()
		task.wait(30)
	end
end)

-- Discord Reminder
task.spawn(function()
	while true do
		task.wait(300)
		Rayfield:Notify({
			Title = "📢 Reminder",
			Content = "Join our Discord: discord.gg/yourlinkhere",
			Duration = 7
		})
	end
end)

-- Ready Notification
Rayfield:Notify({
	Title = "✅ "..CurrentName.." Loaded",
	Content = "All systems active and ready.",
	Duration = 5
})
