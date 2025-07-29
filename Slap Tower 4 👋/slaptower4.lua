-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Basic Info
local CurrentName = "unknown Hub"
local CurrentGame = "Slap Tower 4 👋"
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
      FolderName = Slaptower4, 
      FileName = "unknown hub"
   },

   Discord = {
      Enabled = true, 
      Invite = "noinvitelink", 
      RememberJoins = true 
   }
})

-- 📌 Main Tab
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

local finished = Window:CreateTab("Finished", "BookmarkCheck")

finished:CreateButton({
	Name = "Finish Game",
	Callback = function()
		local player = game.Players.LocalPlayer
		local character = player.Character or player.CharacterAdded:Wait()
		local hrp = character:WaitForChild("HumanoidRootPart", 5)

		if hrp then
			hrp.CFrame = CFrame.new(2.363492250442505, 596.9686279296875, 160.6118927001953)
		end
	end,
})

-----------------------
-- ⚙️ Settings Tab (Device Auto-Rotate)
-----------------------
local SettingsTab = Window:CreateTab("Settings", "Settings")
local autoRotate = false

SettingsTab:CreateToggle({
	Name = "📱 Auto-Rotate UI on Mobile",
	CurrentValue = false,
	Callback = function(val)
		autoRotate = val
		Rayfield:Notify({
			Title = "Device Rotation",
			Content = val and "Auto-Rotate enabled" or "Disabled",
			Duration = 2
		})
	end
})

-- Handle Auto-Rotation
if UserInputService.TouchEnabled then
	local function onOrientationChange()
		if autoRotate then
			local gui = LocalPlayer:FindFirstChild("PlayerGui")
			if gui then
				for _, screenGui in pairs(gui:GetChildren()) do
					if screenGui:IsA("ScreenGui") then
						screenGui.ResetOnSpawn = false
						screenGui.IgnoreGuiInset = true
						screenGui.Rotation = (UserInputService:GetDeviceOrientation() == Enum.DeviceOrientation.LandscapeLeft) and 0 or 90
					end
				end
			end
		end
	end

	RunService.RenderStepped:Connect(onOrientationChange)
end

local SettingsTab = Window:CreateTab("Settings", "settings")
SettingsTab:CreateSection("⚙️ Configuration")
SettingsTab:CreateParagraph({
    Title = "📢 info",
    Content = "this configuration area to save/Load your all doing in this hub ⛏️."
})

SettingsTab:CreateButton({
    Name = "💾 Load Configuration",
    Callback = function()
        Rayfield:LoadConfiguration()
        Rayfield:Notify({
            Title = "✅ Loaded the configuration",
            Content = "Your configuration has been Loaded successfully.",
            Duration = 4
        })
    end
})

-- 📌 Version Check
local function CheckForUpdate()
    local success, response = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/LumeCraftors01/unknown-hub/refs/heads/main/Slap%20Tower%204%20%F0%9F%91%8B/Version.lua")
    end)
    if success and response then
        local LatestVersion = response:match("^%s*(.-)%s*$")
        if LatestVersion and LatestVersion ~= CurrentVersion then
            Rayfield:Notify({
                Title = "⚠️ UPDATE DETECTED!",
                Content = "New version available: "..LatestVersion..". Please rejoin.",
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

-- 📢 Discord Join Reminder every 5 minutes
task.spawn(function()
    while true do
        task.wait(300) -- 300 seconds = 5 minutes
        Rayfield:Notify({
            Title = "📢 Reminder",
            Content = "Join our Discord server: discord.gg/yourlinkhere",
            Duration = 7
        })
    end
end)

-- ✅ Loaded Notification
Rayfield:Notify({
    Title = "✅ "..CurrentName.." Loaded",
    Content = "All systems active and ready.",
    Duration = 5
})
