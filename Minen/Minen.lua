-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Basic Info
local CurrentName = "unknown Hub"
local CurrentGame = "Minen update v1 ⛏️"
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
    ShowText = "unknown hub",
    Icon = "hammer",
    Theme = "Dark",
    
    ConfigurationSaving = {
      Enabled = true,
      FolderName = minen, 
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
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Functions, Events = Remotes.Functions, Remotes.Events
local BuyItem = Functions.BuyItem
local TryCastPile = Functions.TryCastPile
local MiningRemote = Events.MiningRemote
local DialogueProgress = Events.DialogueProgress
local player = game.Players.LocalPlayer

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

-- 📌 Farm Tab
local FarmTab = Window:CreateTab("Farm", "pickaxe")
local autoFarm, autoSell, sellSpeed, digSpeed = false, false, 1, 0.3
local statusLabel = FarmTab:CreateLabel("Status: Idle")

FarmTab:CreateSection("Farming 🧺")

FarmTab:CreateParagraph({
    Title = "Recommended Speed 💰",
    Content = "0.15 is the best speed for grinding."
})

FarmTab:CreateSlider({
    Name = "Dig Speed (s)", Range = {0.1, 2}, Increment = 0.05, CurrentValue = digSpeed,
    Flag = "autofarmsr",
    Callback = function(v) digSpeed = v end
})

FarmTab:CreateToggle({
    Name = "🔥 AutoFarm",
    CurrentValue = false,
    Flag = "autofarms",
    Callback = function(state)
        autoFarm = state
        statusLabel:Set(state and "Status: AutoFarm Running" or "Status: Idle")
        if state then
            task.spawn(function()
                while autoFarm do
                    pcall(function()
                        TryCastPile:InvokeServer("Cast")
                        task.wait(digSpeed)
                        MiningRemote:FireServer("PlayRaritySound")
                        for _, p in ipairs({2, 59.66, 100}) do
                            MiningRemote:FireServer("OnPileProgress", {Progress=p, TargetMinigame=true})
                            task.wait(digSpeed)
                        end
                        for _=1,3 do
                            MiningRemote:FireServer("OnBullseyeProgress",{BullseyeProgress=23.5})
                            task.wait(digSpeed)
                        end
                        MiningRemote:FireServer("CatchResult",{Success=true})
                        task.wait(digSpeed)
                    end)
                end
                statusLabel:Set("Status: Idle")
            end)
        end
    end
})

FarmTab:CreateSection("Sell/auto 🪙")
FarmTab:CreateParagraph({
    Title = "📢 recommended speed",
    Content = "recommended speed is 0.6 faster and good experience no lag and erros. 🔥"
})

FarmTab:CreateSlider({
    Name = "🕒 AutoSell Speed (s)",
    Range = {0.1, 5},
    Increment = 0.1,
    CurrentValue = sellSpeed,
    Flag = "sellallsr",
    Callback = function(value)
        sellSpeed = value
    end
})

FarmTab:CreateParagraph({
    Title = "📦 Important Thing to Know",
    Content = "✅ Make sure you close to the Sell NPC and keep open the sell dont close that and open the autofarm/autosell that will working and if you dont do this the auto sell not working "
})
FarmTab:CreateToggle({
    Name="💰 AutoSell",CurrentValue=false,
    Flag = "sellalls",
    Callback=function(state)
        autoSell=state
        Rayfield:Notify({
            Title=state and "AutoSell Enabled" or "AutoSell Disabled",
            Content=state and "Selling ores every "..sellSpeed.."s." or "Auto selling stopped.",
            Duration=3
        })
        if state then
            task.spawn(function()
                while autoSell do
                    for _,npc in ipairs({"Joe Gravel","Mike","Zombie Gravel","Dave Gravel","Aurora","Walter Silverpalm","Brock","Barak"}) do
                        DialogueProgress:FireServer(npc,"SellAll")
                    end
                    task.wait(sellSpeed)
                end
            end)
        end
    end
})

-- 📌 Farm Tab
local teleportTab = Window:CreateTab("Teleport", "Map")

-- 🗺️ Teleport Locations
local teleportLocations = {
    ["Oreville"] = Vector3.new(1218.24, -2.38, 1036.68),
    ["Glow Forest"] = Vector3.new(2840.52, 30.45, 743.44),
    ["Cragpire"] = Vector3.new(4082.79, 6.79, 475.83),
    ["Frostshard"] = Vector3.new(2582.50, 42.33, 3415.08),
    ["Glimmergrove"] = Vector3.new(4194.71, 49.58, 1870.27),
    ["Ashenreach"] = Vector3.new(-533.55, 2.67, -330.58),
    ["Rustmere"] = Vector3.new(1382.81, 85.88, -1001.60),
    ["Boat Station"] = Vector3.new(1547.21, 16.36, 1308.58),
    ["Lighthouse"] = Vector3.new(20.06, 3.64, 1651.04),
    ["Mini Atlantis"] = Vector3.new(4528.42, -2.24, 4176.88),
}

-- 🔘 Create a button for each teleport location
for name, position in pairs(teleportLocations) do
    teleportTab:CreateButton({
        Name = "Teleport to " .. name,
        Callback = function()
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart", 5)

            if hrp then
                hrp.CFrame = CFrame.new(position)
                print("✅ Teleported to", name)

                -- ✅ Notification after teleport
                Rayfield:Notify({
                    Title = "Teleport Success",
                    Content = "You teleported to " .. name,
                    Duration = 4, -- seconds
                    Image = 4483362458, -- optional image ID
                })
            else
                warn("❌ Could not find HumanoidRootPart!")
                Rayfield:Notify({
                    Title = "Teleport Failed",
                    Content = "Couldn't find HumanoidRootPart",
                    Duration = 4,
                    Image = 0
                })
            end
        end
    })
end

-- 📌 Market Tab
local MarketTab = Window:CreateTab("Market", "shopping-bag")

MarketTab:CreateParagraph({
    Title = "📌 Important",
    Content = "✅ Make sure you have enough Money and meet the required Level before buying Pickaxes or other items."
})

-- Pickaxe Market
MarketTab:CreateSection("Pickaxe Market")
local PickaxeList = {
    "Stone Pickaxe","Copper Pickaxe","Palm Tree Pickaxe","Lucky Pickaxe","Iron Pickaxe","Sword Pickaxe",
    "Soil Pickaxe","Golden Pickaxe","Voxel Pickaxe","Climber Pickaxe","Twisted Pickaxe","Futuristic Pickaxe",
    "Jester Pickaxe","Lighthouse Pickaxe","Magma Pickaxe","Frozen Pickaxe","Overseer Pickaxe","Traffic Pickaxe",
    "Trident Pickaxe","Shark Pickaxe"
}
for _, pickaxe in ipairs(PickaxeList) do
    MarketTab:CreateButton({
        Name = "🛒 Buy "..pickaxe,
        Callback = function()
            BuyItem:InvokeServer("Pickaxe", pickaxe)
        end
    })
end
MarketTab:CreateButton({
    Name = "💸 Buy All Pickaxes",
    Callback = function()
        for _, p in ipairs(PickaxeList) do
            BuyItem:InvokeServer("Pickaxe", p)
            task.wait(0.2)
        end
    end
})

-- Backpack Market
MarketTab:CreateSection("Backpack Market")
local BackpackList = {
    "Bucket","Bag","Lunchbox","Ruby Pouch","Pirate Backpack","Duffel's Bag","Mini Vault",
    "Climber Backpack","Chest","Adventurous Backpack","Toxic Backpack","Fusion Backpack","Amethyst Eye"
}
for _, bag in ipairs(BackpackList) do
    MarketTab:CreateButton({
        Name = "🎒 Buy "..bag,
        Callback = function()
            BuyItem:InvokeServer("Backpack", bag)
        end
    })
end
MarketTab:CreateButton({
    Name = "💸 Buy All Backpacks",
    Callback = function()
        for _, b in ipairs(BackpackList) do
            BuyItem:InvokeServer("Backpack", b)
            task.wait(0.2)
        end
    end
})

-- Vehicle Market
MarketTab:CreateSection("🚗 Vehicles Market beta")
local VehicleList = {
    "Camper Van","Small Truck","Buggy","Pickup","Police Cruiser",
    "Sports Car","Super Car","Monster Truck","Tank"
}
for _, vehicle in ipairs(VehicleList) do
    MarketTab:CreateButton({
        Name = "🚗 Buy "..vehicle,
        Callback = function()
            BuyItem:InvokeServer("Vehicles", vehicle)
        end
    })
end
MarketTab:CreateButton({
    Name = "💸 Buy All Vehicles beta",
    Callback = function()
        for _, v in ipairs(VehicleList) do
            BuyItem:InvokeServer("Vehicles", v)
            task.wait(0.2)
        end
    end
})

-- 📌 Misc Tab
local MiscTab = Window:CreateTab("Misc", "book")
MiscTab:CreateSection("Enchanting")
MiscTab:CreateParagraph({
    Title = "📢 important",
    Content = "Make sure you in enchanting tower and you have Lightning Rune item and night time ⛏️."
})

local function getNil(name, class)
    for _, v in next, getnilinstances() do
        if v.ClassName == class and v.Name == name then
            return v
        end
    end
end

MiscTab:CreateButton({
    Name = "⚡ Teleport to Enchanting Tower",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart", 5)

        local targetPosition = Vector3.new(2742.54, -230.86, 756.54)

        if hrp then
            hrp.CFrame = CFrame.new(targetPosition)
            Rayfield:Notify({
                Title = "Teleported",
                Content = "You have been teleported to Enchanting Tower!",
                Duration = 3,
                Image = 4483362458 -- optional
            })
        else
            Rayfield:Notify({
                Title = "Teleport Failed",
                Content = "HumanoidRootPart not found!",
                Duration = 3,
                Image = 0
            })
        end
    end
})

MiscTab:CreateButton({
    Name = "🛒 Buy Lightning Rune",
    Callback = function()
        local success, result = pcall(function()
            return BuyItem:InvokeServer("Items", "Lightning Rune", 1)
        end)
        task.wait(0.2)
        if success and (result == true or result == "Success") then
            Rayfield:Notify({
                Title = "✅ Purchase Successful",
                Content = "Bought: Lightning Rune successfully.",
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "❌ Purchase Failed",
                Content = "Failed to buy Lightning Rune.",
                Duration = 4
            })
        end
    end
})

-- ⚙️ Anti-Admin Detection Settings
local antiAdminEnabled = false
local adminAction = "Warn"

MiscTab:CreateParagraph({
    Title = "📢 about",
    Content = "this is anti ban for like example if the admin of the game join your server if you on the anti admin and in dropdown if you pick the none nothing do and if pick warning send the warning notification and if you pick leave automatically leave the 🎯."
})

-- 👥 Replace these with actual admin UserIds to detect
local adminUserIds = {
    3606665012, -- Example UserId
    1363894312,
    411198659,
    131141674
}

-- 📑 Settings Section
MiscTab:CreateSection("🛡️ Anti-Admin Detection")

-- 📋 Action Dropdown
MiscTab:CreateDropdown({
    Name = "Detection Action",
    Options = {"Leave", "Warn", "None"},
    CurrentOption = "Warn",
    Flag = "antibandn",
    Callback = function(selected)
        adminAction = selected
        Rayfield:Notify({
            Title = "Anti-Admin",
            Content = "Action set to: "..selected,
            Duration = 4
        })
    end
})

-- 🔘 Enable/Disable Toggle
MiscTab:CreateToggle({
    Name = "Enable Detection",
    CurrentValue = false,
    Flag = "antiban",
    Callback = function(state)
        antiAdminEnabled = state
        Rayfield:Notify({
            Title = "Anti-Admin",
            Content = state and "Anti-Admin detection enabled." or "Detection disabled.",
            Duration = 4
        })
    end
})

-- 🛡️ Anti-Admin Detection Function
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    if not antiAdminEnabled then return end

    if table.find(adminUserIds, player.UserId) then
        print("[Anti-Admin] Detected admin user:", player.Name)

        if adminAction == "Warn" then
            Rayfield:Notify({
                Title = "⚠️ Admin Detected!",
                Content = "Admin "..player.Name.." joined the game!",
                Duration = 8
            })

        elseif adminAction == "Leave" then
            Rayfield:Notify({
                Title = "⚠️ Admin Detected!",
                Content = "Leaving the server in 2 seconds...",
                Duration = 6
            })
            task.wait(2)
            game.Players.LocalPlayer:Kick("Detected admin: "..player.Name)

        elseif adminAction == "None" then
            -- Do nothing
        end
    end
end)

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
        return game:HttpGet("https://raw.githubusercontent.com/glitchstikers/Testscript-/main/Version.lua")
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
