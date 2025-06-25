-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Hub Info
local HubName, GameName, CurrentVersion = "Unknown Hub v1", "Minen ⛏️", "v1.0"
local DefaultVersion, VersionFile = CurrentVersion, "unknown_Version.txt"

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = string.format("%s | %s | %s", HubName, GameName, CurrentVersion),
    LoadingTitle = "Loading Unknown Hub...",
    LoadingSubtitle = "By Unknown Team",
    ShowText = "unknown hub",
    Icon = "hammer",
    Theme = "Dark"
})

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Functions, Events = Remotes.Functions, Remotes.Events
local BuyItem, TryCastPile = Functions.BuyItem, Functions.TryCastPile
local MiningRemote, DialogueProgress = Events.MiningRemote, Events.DialogueProgress

-- Persistent Version
local function LoadVersion()
    return isfile(VersionFile) and readfile(VersionFile):match("^%s*(.-)%s*$") or DefaultVersion
end
local function SaveVersion(v) writefile(VersionFile, v) end
CurrentVersion = LoadVersion()

-- 📌 1️⃣ Main Tab
local MainTab = Window:CreateTab("Main", "home")
MainTab:CreateSection("About & Links")

MainTab:CreateButton({
    Name = "ℹ️ About",
    Callback = function()
        Rayfield:Notify({
            Title = "About",
            Content = HubName.." for "..GameName.." — reliable farming hub.",
            Duration = 5
        })
    end
})

MainTab:CreateButton({
    Name = "📋 Copy Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/yourlinkhere")
        Rayfield:Notify({Title="Copied",Content="Discord link copied.",Duration=4})
    end
})

MainTab:CreateParagraph({
    Title = "⚠️ Disclaimer",
    Content = "Use this at your own risk. We are not responsible for bans."
})

-- 📌 2️⃣ Farm Tab
local FarmTab = Window:CreateTab("Farm", "pickaxe")
local autoFarm, autoSell, digSpeed = false, false, 0.3
local statusLabel = FarmTab:CreateLabel("Status: Idle")

FarmTab:CreateSlider({
    Name = "Dig Speed (s)", Range = {0.1, 2}, Increment = 0.05, CurrentValue = digSpeed,
    Callback = function(v) digSpeed = v end
})

FarmTab:CreateToggle({
    Name = "🔥 AutoFarm", CurrentValue = false,
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
                            MiningRemote:FireServer("OnPileProgress", {Progress=p,TargetMinigame=true})
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

FarmTab:CreateToggle({
    Name = "💰 Auto Sell", CurrentValue = false,
    Callback = function(state)
        autoSell = state
        Rayfield:Notify({
            Title = state and "AutoSell Enabled" or "AutoSell Disabled",
            Content = state and "Selling ores automatically." or "Auto selling stopped.",
            Duration = 3
        })
        if state then
            task.spawn(function()
                while autoSell do
                    for _, npc in ipairs({"Joe Gravel","Mike","Zombie Gravel","Dave Gravel","Aurora"}) do
                        DialogueProgress:FireServer(npc, "SellAll")
                    end
                    task.wait(3)
                end
            end)
        end
    end
})

-- 📌 3️⃣ Market Tab
local MarketTab = Window:CreateTab("Market", "shopping-bag")

-- Pickaxe Market
MarketTab:CreateSection("Pickaxe Market")
local PickaxeList = {
    "Stone Pickaxe","Copper Pickaxe","Palm Tree Pickaxe","Lucky Pickaxe","Iron Pickaxe","Sword Pickaxe",
    "Soil Pickaxe","Golden Pickaxe","Voxel Pickaxe","Climber Pickaxe","Twisted Pickaxe","Futuristic Pickaxe",
    "Jester Pickaxe","Lighthouse Pickaxe","Magma Pickaxe","Frozen Pickaxe","Overseer Pickaxe","Traffic Pickaxe",
    "Trident Pickaxe","Shark Pickaxe"
}

for _, pickaxeName in ipairs(PickaxeList) do
    MarketTab:CreateButton({
        Name = "🛒 Buy "..pickaxeName,
        Callback = function()
            local success, result = pcall(function()
                return BuyItem:InvokeServer("Pickaxe", pickaxeName)
            end)
            Rayfield:Notify({
                Title = success and (result == "Success" or result == true) and "✅ Purchase Successful" or "❌ Purchase Failed",
                Content = success and ("Bought: "..pickaxeName) or ("Failed: "..tostring(result)),
                Duration = 4
            })
        end
    })
end

MarketTab:CreateButton({
    Name = "💸 Buy All Pickaxes",
    Callback = function()
        for _, pickaxeName in ipairs(PickaxeList) do
            local success, result = pcall(function()
                return BuyItem:InvokeServer("Pickaxe", pickaxeName)
            end)
            Rayfield:Notify({
                Title = success and (result == "Success" or result == true) and "✅ Bought" or "❌ Failed",
                Content = pickaxeName,
                Duration = 3
            })
            task.wait(0.2)
        end
    end
})

-- Backpack Market
MarketTab:CreateSection("Backpack Market")
local BagList = {
    "Bucket","Bag","Lunchbox","Ruby Pouch","Pirate Backpack","Duffel's Bag","Mini Vault",
    "Climber Backpack","Chest","Adventurous Backpack","Toxic Backpack","Fusion Backpack","Amethyst Eye"
}

for _, bagName in ipairs(BagList) do
    MarketTab:CreateButton({
        Name = "🎒 Buy "..bagName,
        Callback = function()
            local success, result = pcall(function()
                return BuyItem:InvokeServer("Backpack", bagName)
            end)
            Rayfield:Notify({
                Title = success and (result == "Success" or result == true) and "✅ Purchase Successful" or "❌ Purchase Failed",
                Content = success and ("Bought: "..bagName) or ("Failed: "..tostring(result)),
                Duration = 4
            })
        end
    })
end

MarketTab:CreateButton({
    Name = "💸 Buy All Backpacks",
    Callback = function()
        for _, bagName in ipairs(BagList) do
            local success, result = pcall(function()
                return BuyItem:InvokeServer("Backpack", bagName)
            end)
            Rayfield:Notify({
                Title = success and (result == "Success" or result == true) and "✅ Bought" or "❌ Failed",
                Content = bagName,
                Duration = 3
            })
            task.wait(0.2)
        end
    end
})

-- Version Check
local VersionURL = "https://raw.githubusercontent.com/LumeCraftors01/unknown-hub/refs/heads/main/Minen/Version.lua"
local function CheckForUpdate()
    local success, response = pcall(function()
        return game:HttpGet(VersionURL)
    end)
    if success and response then
        local latest = response:match("^%s*(.-)%s*$")
        if latest and latest~=CurrentVersion then
            Rayfield:Notify({
                Title = "⚠️ UPDATE DETECTED!",
                Content = "New version available: "..latest..". Please rejoin.",
                Duration = 10
            })
            SaveVersion(latest)
            Window:SetName(string.format("%s | %s | %s", HubName, GameName, latest))
        end
    else
        warn("⚠️ Failed to check for updates.")
    end
end
CheckForUpdate()

-- Loaded Notification
Rayfield:Notify({
    Title = "✅ "..HubName.." Loaded",
    Content = "All systems active and ready.",
    Duration = 5
})
