-- ================================================
-- Unknown Hub | Minen Update v1
-- Improved Version - Better stability & structure
-- ================================================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ================================================
-- CONSTANTS & CONFIG
-- ================================================
local HUB_NAME     = "Unknown Hub"
local HUB_GAME     = "Minen Update v1 ⛏️"
local VERSION_FILE = "unknown_Version.txt"
local DEFAULT_VER  = "v1.0"
local DISCORD_LINK = "https://discord.gg/yourlinkhere"
local UPDATE_URL   = "https://raw.githubusercontent.com/glitchstikers/Testscript-/main/Version.lua"

-- ================================================
-- VERSION MANAGEMENT
-- ================================================
local function LoadVersion()
    local ok, data = pcall(function()
        return isfile(VERSION_FILE) and readfile(VERSION_FILE) or DEFAULT_VER
    end)
    if ok and data then
        return data:match("^%s*(.-)%s*$") or DEFAULT_VER
    end
    return DEFAULT_VER
end

local function SaveVersion(v)
    pcall(writefile, VERSION_FILE, v)
end

local CurrentVersion = LoadVersion()

-- ================================================
-- WINDOW
-- ================================================
local Window = Rayfield:CreateWindow({
    Name           = string.format("%s | %s | %s", HUB_NAME, HUB_GAME, CurrentVersion),
    LoadingTitle   = "Loading Unknown Hub...",
    LoadingSubtitle = "By Unknown Team",
    ShowText       = "Unknown Hub",
    Icon           = "hammer",
    Theme          = "Dark",

    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "minen",        -- fixed: was missing quotes
        FileName   = "unknown_hub"
    },

    Discord = {
        Enabled     = true,
        Invite      = "noinvitelink",
        RememberJoins = true
    }
})

-- ================================================
-- SERVICES
-- ================================================
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player  = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

if not Remotes then
    Rayfield:Notify({ Title = "⚠️ Error", Content = "Remotes folder not found!", Duration = 6 })
    return
end

local Functions        = Remotes:WaitForChild("Functions", 5)
local Events           = Remotes:WaitForChild("Events", 5)
local BuyItem          = Functions and Functions:WaitForChild("BuyItem", 5)
local TryCastPile      = Functions and Functions:WaitForChild("TryCastPile", 5)
local MiningRemote     = Events and Events:WaitForChild("MiningRemote", 5)
local DialogueProgress = Events and Events:WaitForChild("DialogueProgress", 5)

-- ================================================
-- HELPERS
-- ================================================
local function SafeFireServer(remote, ...)
    if remote then
        pcall(function() remote:FireServer(...) end)
    end
end

local function SafeInvokeServer(remote, ...)
    if remote then
        local ok, result = pcall(function() return remote:InvokeServer(...) end)
        return ok, result
    end
    return false, nil
end

local function GetCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function GetHRP()
    local char = GetCharacter()
    return char:WaitForChild("HumanoidRootPart", 5)
end

local function TeleportTo(position, locationName)
    local hrp = GetHRP()
    if hrp then
        hrp.CFrame = CFrame.new(position)
        Rayfield:Notify({
            Title   = "✅ Teleport Success",
            Content = "Teleported to " .. locationName,
            Duration = 3
        })
    else
        Rayfield:Notify({
            Title   = "❌ Teleport Failed",
            Content = "HumanoidRootPart not found.",
            Duration = 3
        })
    end
end

-- ================================================
-- MAIN TAB
-- ================================================
local MainTab = Window:CreateTab("Main", "home")

MainTab:CreateParagraph({
    Title   = "Welcome 👋",
    Content = "Unknown Hub — making your Minen experience easier and more enjoyable. 🍫"
})

MainTab:CreateButton({
    Name = "ℹ️ About",
    Callback = function()
        Rayfield:Notify({
            Title    = "About",
            Content  = HUB_NAME .. " for " .. HUB_GAME .. " | Version: " .. CurrentVersion,
            Duration = 5
        })
    end
})

MainTab:CreateButton({
    Name = "📋 Copy Discord Link",
    Callback = function()
        pcall(setclipboard, DISCORD_LINK)
        Rayfield:Notify({ Title = "Copied ✅", Content = "Discord link copied to clipboard.", Duration = 3 })
    end
})

MainTab:CreateParagraph({
    Title   = "⚠️ Disclaimer",
    Content = "Use this at your own risk. We are not responsible for any bans or consequences."
})

-- ================================================
-- FARM TAB
-- ================================================
local FarmTab = Window:CreateTab("Farm", "pickaxe")

-- State
local farmState = {
    autoFarm  = false,
    autoSell  = false,
    digSpeed  = 0.3,
    sellSpeed = 1.0,
}

local statusLabel = FarmTab:CreateLabel("Status: Idle ⏸️")

FarmTab:CreateSection("⛏️ AutoFarm Settings")

FarmTab:CreateParagraph({
    Title   = "💡 Recommended Speed",
    Content = "0.15s dig speed gives the best balance of speed and stability."
})

FarmTab:CreateSlider({
    Name         = "Dig Speed (seconds)",
    Range        = {0.1, 2},
    Increment    = 0.05,
    CurrentValue = farmState.digSpeed,
    Flag         = "digSpeed",
    Callback     = function(v)
        farmState.digSpeed = v
    end
})

FarmTab:CreateToggle({
    Name         = "🔥 AutoFarm",
    CurrentValue = false,
    Flag         = "autoFarm",
    Callback     = function(state)
        farmState.autoFarm = state
        statusLabel:Set(state and "Status: AutoFarm Running 🔥" or "Status: Idle ⏸️")

        if state then
            task.spawn(function()
                while farmState.autoFarm do
                    pcall(function()
                        local speed = farmState.digSpeed

                        SafeInvokeServer(TryCastPile, "Cast")
                        task.wait(speed)

                        SafeFireServer(MiningRemote, "PlayRaritySound")

                        for _, progress in ipairs({2, 59.66, 100}) do
                            SafeFireServer(MiningRemote, "OnPileProgress", {
                                Progress       = progress,
                                TargetMinigame = true
                            })
                            task.wait(speed)
                        end

                        for _ = 1, 3 do
                            SafeFireServer(MiningRemote, "OnBullseyeProgress", {
                                BullseyeProgress = 23.5
                            })
                            task.wait(speed)
                        end

                        SafeFireServer(MiningRemote, "CatchResult", { Success = true })
                        task.wait(speed)
                    end)
                end
                statusLabel:Set("Status: Idle ⏸️")
            end)
        end
    end
})

-- ─── AutoSell ───────────────────────────────────
FarmTab:CreateSection("💰 AutoSell Settings")

FarmTab:CreateParagraph({
    Title   = "📢 Before Using AutoSell",
    Content = "Stand near a Sell NPC and keep the sell menu OPEN before enabling AutoSell."
})

FarmTab:CreateParagraph({
    Title   = "💡 Recommended Speed",
    Content = "0.6s is stable and avoids errors/lag."
})

FarmTab:CreateSlider({
    Name         = "AutoSell Speed (seconds)",
    Range        = {0.1, 5},
    Increment    = 0.1,
    CurrentValue = farmState.sellSpeed,
    Flag         = "sellSpeed",
    Callback     = function(v)
        farmState.sellSpeed = v
    end
})

local SELL_NPCS = {
    "Joe Gravel", "Mike", "Zombie Gravel", "Dave Gravel",
    "Aurora", "Walter Silverpalm", "Brock", "Barak"
}

FarmTab:CreateToggle({
    Name         = "💰 AutoSell",
    CurrentValue = false,
    Flag         = "autoSell",
    Callback     = function(state)
        farmState.autoSell = state
        Rayfield:Notify({
            Title   = state and "AutoSell Enabled ✅" or "AutoSell Disabled ❌",
            Content = state and ("Selling every " .. farmState.sellSpeed .. "s.") or "Auto sell stopped.",
            Duration = 3
        })

        if state then
            task.spawn(function()
                while farmState.autoSell do
                    for _, npc in ipairs(SELL_NPCS) do
                        SafeFireServer(DialogueProgress, npc, "SellAll")
                    end
                    task.wait(farmState.sellSpeed)
                end
            end)
        end
    end
})

-- ================================================
-- TELEPORT TAB
-- ================================================
local TeleportTab = Window:CreateTab("Teleport", "map")

local LOCATIONS = {
    { name = "Oreville",      pos = Vector3.new(1218.24,  -2.38,  1036.68) },
    { name = "Glow Forest",   pos = Vector3.new(2840.52,  30.45,   743.44) },
    { name = "Cragpire",      pos = Vector3.new(4082.79,   6.79,   475.83) },
    { name = "Frostshard",    pos = Vector3.new(2582.50,  42.33,  3415.08) },
    { name = "Glimmergrove",  pos = Vector3.new(4194.71,  49.58,  1870.27) },
    { name = "Ashenreach",    pos = Vector3.new(-533.55,   2.67,  -330.58) },
    { name = "Rustmere",      pos = Vector3.new(1382.81,  85.88, -1001.60) },
    { name = "Boat Station",  pos = Vector3.new(1547.21,  16.36,  1308.58) },
    { name = "Lighthouse",    pos = Vector3.new(20.06,     3.64,  1651.04) },
    { name = "Mini Atlantis", pos = Vector3.new(4528.42,  -2.24,  4176.88) },
}

TeleportTab:CreateSection("📍 Teleport Locations")

for _, loc in ipairs(LOCATIONS) do
    TeleportTab:CreateButton({
        Name     = "📍 " .. loc.name,
        Callback = function()
            TeleportTo(loc.pos, loc.name)
        end
    })
end

-- ================================================
-- MARKET TAB
-- ================================================
local MarketTab = Window:CreateTab("Market", "shopping-bag")

MarketTab:CreateParagraph({
    Title   = "📌 Before Buying",
    Content = "Make sure you have enough Money and meet the required Level before purchasing items."
})

local function CreateBuySection(tab, sectionName, itemType, itemList, icon)
    tab:CreateSection(sectionName)
    for _, item in ipairs(itemList) do
        tab:CreateButton({
            Name     = icon .. " Buy " .. item,
            Callback = function()
                local ok, result = SafeInvokeServer(BuyItem, itemType, item)
                Rayfield:Notify({
                    Title   = ok and "✅ Purchased" or "❌ Failed",
                    Content = ok and ("Bought: " .. item) or ("Could not buy: " .. item),
                    Duration = 3
                })
            end
        })
    end
    tab:CreateButton({
        Name     = "💸 Buy All (" .. sectionName .. ")",
        Callback = function()
            task.spawn(function()
                local bought, failed = 0, 0
                for _, item in ipairs(itemList) do
                    local ok = SafeInvokeServer(BuyItem, itemType, item)
                    if ok then bought += 1 else failed += 1 end
                    task.wait(0.2)
                end
                Rayfield:Notify({
                    Title   = "💸 Buy All Done",
                    Content = bought .. " bought, " .. failed .. " failed.",
                    Duration = 5
                })
            end)
        end
    })
end

local PICKAXES = {
    "Stone Pickaxe","Copper Pickaxe","Palm Tree Pickaxe","Lucky Pickaxe",
    "Iron Pickaxe","Sword Pickaxe","Soil Pickaxe","Golden Pickaxe",
    "Voxel Pickaxe","Climber Pickaxe","Twisted Pickaxe","Futuristic Pickaxe",
    "Jester Pickaxe","Lighthouse Pickaxe","Magma Pickaxe","Frozen Pickaxe",
    "Overseer Pickaxe","Traffic Pickaxe","Trident Pickaxe","Shark Pickaxe"
}

local BACKPACKS = {
    "Bucket","Bag","Lunchbox","Ruby Pouch","Pirate Backpack",
    "Duffel's Bag","Mini Vault","Climber Backpack","Chest",
    "Adventurous Backpack","Toxic Backpack","Fusion Backpack","Amethyst Eye"
}

local VEHICLES = {
    "Camper Van","Small Truck","Buggy","Pickup","Police Cruiser",
    "Sports Car","Super Car","Monster Truck","Tank"
}

CreateBuySection(MarketTab, "⛏️ Pickaxes",  "Pickaxe",  PICKAXES,  "⛏️")
CreateBuySection(MarketTab, "🎒 Backpacks", "Backpack",  BACKPACKS, "🎒")
CreateBuySection(MarketTab, "🚗 Vehicles",  "Vehicles",  VEHICLES,  "🚗")

-- ================================================
-- MISC TAB
-- ================================================
local MiscTab = Window:CreateTab("Misc", "book")

-- Enchanting
MiscTab:CreateSection("✨ Enchanting")
MiscTab:CreateParagraph({
    Title   = "📢 Requirements",
    Content = "Must be at the Enchanting Tower, have a Lightning Rune, and it must be nighttime. ⛏️"
})

MiscTab:CreateButton({
    Name     = "⚡ Teleport to Enchanting Tower",
    Callback = function()
        TeleportTo(Vector3.new(2742.54, -230.86, 756.54), "Enchanting Tower")
    end
})

MiscTab:CreateButton({
    Name     = "🛒 Buy Lightning Rune",
    Callback = function()
        local ok, result = SafeInvokeServer(BuyItem, "Items", "Lightning Rune", 1)
        Rayfield:Notify({
            Title   = ok and "✅ Purchase Successful" or "❌ Purchase Failed",
            Content = ok and "Bought: Lightning Rune" or "Failed to buy Lightning Rune.",
            Duration = 4
        })
    end
})

-- Admin Detection
local adminState = {
    enabled = false,
    action  = "Warn",
}

-- ⚠️ Replace these with real admin UserIds for the game
local ADMIN_IDS = {
    3606665012,
    1363894312,
    411198659,
    131141674,
}

MiscTab:CreateSection("🛡️ Admin Detection")

MiscTab:CreateParagraph({
    Title   = "ℹ️ How It Works",
    Content = "Monitors players joining. 'Warn' sends a notification. 'Leave' exits the server. 'None' does nothing."
})

MiscTab:CreateDropdown({
    Name          = "Detection Action",
    Options       = {"Warn", "Leave", "None"},
    CurrentOption = "Warn",
    Flag          = "adminAction",
    Callback      = function(selected)
        adminState.action = selected
        Rayfield:Notify({
            Title   = "Admin Detection",
            Content = "Action set to: " .. selected,
            Duration = 3
        })
    end
})

MiscTab:CreateToggle({
    Name         = "🛡️ Enable Admin Detection",
    CurrentValue = false,
    Flag         = "adminDetect",
    Callback     = function(state)
        adminState.enabled = state
        Rayfield:Notify({
            Title   = "Admin Detection",
            Content = state and "Detection ENABLED." or "Detection DISABLED.",
            Duration = 3
        })
    end
})

Players.PlayerAdded:Connect(function(p)
    if not adminState.enabled then return end
    if not table.find(ADMIN_IDS, p.UserId) then return end

    if adminState.action == "Warn" then
        Rayfield:Notify({
            Title    = "⚠️ Admin Joined!",
            Content  = p.Name .. " (admin) has joined the server!",
            Duration = 8
        })

    elseif adminState.action == "Leave" then
        Rayfield:Notify({
            Title    = "⚠️ Admin Detected!",
            Content  = "Leaving server in 3 seconds...",
            Duration = 6
        })
        task.wait(3)
        player:Kick("Admin detected: " .. p.Name)
    end
    -- "None" → do nothing
end)

-- ================================================
-- SETTINGS TAB
-- ================================================
local SettingsTab = Window:CreateTab("Settings", "settings")

SettingsTab:CreateSection("⚙️ Configuration")
SettingsTab:CreateParagraph({
    Title   = "📢 Info",
    Content = "Save and load all your hub settings here. ⛏️"
})

SettingsTab:CreateButton({
    Name     = "💾 Save Configuration",
    Callback = function()
        pcall(function() Rayfield:SaveConfiguration() end)
        Rayfield:Notify({
            Title   = "✅ Saved",
            Content = "Configuration saved successfully.",
            Duration = 3
        })
    end
})

SettingsTab:CreateButton({
    Name     = "📂 Load Configuration",
    Callback = function()
        pcall(function() Rayfield:LoadConfiguration() end)
        Rayfield:Notify({
            Title   = "✅ Loaded",
            Content = "Configuration loaded successfully.",
            Duration = 3
        })
    end
})

-- ================================================
-- VERSION CHECKER
-- ================================================
local function CheckForUpdate()
    local ok, response = pcall(function()
        return game:HttpGet(UPDATE_URL)
    end)
    if not ok or not response then return end

    local latest = response:match("^%s*(.-)%s*$")
    if latest and latest ~= CurrentVersion then
        SaveVersion(latest)
        CurrentVersion = latest
        Window:SetName(string.format("%s | %s | %s", HUB_NAME, HUB_GAME, CurrentVersion))
        Rayfield:Notify({
            Title    = "⬆️ Update Available!",
            Content  = "New version: " .. latest .. ". Please rejoin for the latest features.",
            Duration = 10
        })
    end
end

task.spawn(function()
    while true do
        CheckForUpdate()
        task.wait(60) -- check every 60s (was 30s, reduces unnecessary requests)
    end
end)

-- ================================================
-- DISCORD REMINDER (every 10 minutes)
-- ================================================
task.spawn(function()
    task.wait(600)
    while true do
        Rayfield:Notify({
            Title    = "📢 Discord",
            Content  = "Join our community: discord.gg/yourlinkhere",
            Duration = 6
        })
        task.wait(600)
    end
end)

-- ================================================
-- READY
-- ================================================
Rayfield:Notify({
    Title    = "✅ " .. HUB_NAME .. " Ready",
    Content  = "Version " .. CurrentVersion .. " loaded. All systems active.",
    Duration = 5
})
