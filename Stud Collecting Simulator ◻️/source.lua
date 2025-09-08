-- ⚙️ Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 📚 Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- 📝 Basic Info
local CurrentName = "unknown Hub"
local CurrentGame = "Stud Collecting Simulator ◻️"
local DefaultVersion = "v1.0"
local VersionFile = "unknown_Version.txt"

-- 📁 Version Storage
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

-- 🪟 Main Window
local Window = Rayfield:CreateWindow({
	Name = string.format("%s | %s | %s", CurrentName, CurrentGame, CurrentVersion),
	LoadingTitle = "Loading Unknown Hub...",
	LoadingSubtitle = "By Unknown Team",
	ShowText = "Show",
	Icon = "hammer",
	Theme = "Dark",

	ConfigurationSaving = {
		Enabled = true,
		FolderName = "StudCollection",
		FileName = "unknown hub"
	},

	Discord = {
		Enabled = true,
		Invite = "noinvitelink",
		RememberJoins = true
	}
})

-- // Tool List
local Tools = {
    {"Wooden Grabber", 100},
    {"Stone Grabber", 1000},
    {"Copper Grabber", 5000},
    {"Steel Grabber", 10000},
    {"Brass Grabber", 23000},
    {"Frozen Grabber", 23000},
    {"Gold Grabber", 30000},
    {"Diamond Grabber", 50000},
    {"Oceanheart Grabber", 85000},
    {"Crystal Grabber", 130000},
    {"Arcane Grabber", 120000},
    {"Celestial Grabber", 500000},
    {"Phoenix Grabber", 850000},
    {"Lovehearts Grabber", 1000000},
    {"Plasma Grabber", 1800000},
    {"Starlight Grabber", 3000000},
    {"Infernal Grabber", 5000000},
    {"Galactic Grabber", 7500000},
}

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

-- 📌 Main Tab
local FarmTab = Window:CreateTab("Farm", "Pickaxe")

local enabled = false
local loopDelay = 0.1 -- default speed
local walkSpeedBoost = 150

-- Toggle
FarmTab:CreateToggle({
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

            Rayfield:Notify({
                Title = "✅ Farming " .. (state and "Enabled" or "Disabled"),
                Content = "The Greatest farmers!",
                Duration = 6.5,
                Image = "activity",
            })
        else
            hum.WalkSpeed = 16 -- reset to default
            Rayfield:Notify({
                Title = "⛔ Farming Disabled",
                Content = "Back to default speed",
                Duration = 6.5,
                Image = "activity",
            })
        end
    end,
})

-- Speed Slider
FarmTab:CreateSlider({
    Name = "Collection Speed (lower = faster)",
    Range = {0.05, 1}, -- delay between loops
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = loopDelay,
    Flag = "CollectorSpeed",
    Callback = function(val)
        loopDelay = val

        Rayfield:Notify({
            Title = "⚡ Farming Speed: " .. string.format("%.2f", val) .. "s",
            Content = "The farming is fastest way!",
            Duration = 6.5,
            Image = "activity",
        })
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


-- // Short Number Formatter (1k, 1m, 1b)
local function formatNumber(n)
    if n >= 1e9 then
        return string.format("%.1fb", n/1e9)
    elseif n >= 1e6 then
        return string.format("%.1fm", n/1e6)
    elseif n >= 1e3 then
        return string.format("%.1fk", n/1e3)
    else
        return tostring(n)
    end
end

-- // Market Tab 
local MarketTab = Window:CreateTab("Market", "shopping-cart")

-- // Loop all tools
for _, tool in ipairs(Tools) do
    local toolName, toolPrice = tool[1], tool[2]

    MarketTab:CreateButton({
        Name = toolName .. " - $" .. formatNumber(toolPrice),
        Callback = function()
            local args = {toolName, toolPrice}
            local success, err = pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("BuyTool2"):FireServer(unpack(args))
            end)

            if success then
                Rayfield:Notify({
                    Title = "✅ Purchase Successful",
                    Content = "You bought " .. toolName .. " for $" .. formatNumber(toolPrice),
                    Duration = 4
                })
            else
                Rayfield:Notify({
                    Title = "❌ Purchase Failed",
                    Content = "Error buying " .. toolName,
                    Duration = 4
                })
            end
        end,
    })
end

-- ⚙️ Settings Tab (with Auto-Rotate)
local SettingsTab = Window:CreateTab("Settings", "settings")

-- 🧩 Configuration Loader
SettingsTab:CreateSection("⚙️ Configuration")
SettingsTab:CreateParagraph({
	Title = "📢 Info",
	Content = "This configuration area saves/loads all your hub settings ⛏️."
})
SettingsTab:CreateButton({
	Name = "💾 Load Configuration",
	Callback = function()
		Rayfield:LoadConfiguration()
		Rayfield:Notify({
			Title = "✅ Loaded the configuration",
			Content = "Your configuration has been loaded successfully.",
			Duration = 4
		})
	end
})

-- 🔁 Version Checker
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

-- 🔔 Discord Reminder
task.spawn(function()
	while true do
		task.wait(300)
		Rayfield:Notify({
			Title = "📢 Reminder",
			Content = "Join our Discord server: discord.gg/yourlinkhere",
			Duration = 7
		})
	end
end)

-- ✅ Final Load Notice
Rayfield:Notify({
	Title = "✅ "..CurrentName.." Loaded",
	Content = "All systems active and ready.",
	Duration = 5
})
