-- ================================================
-- Unknown Hub | Minen Update v1
-- Fixed & Improved Version — No nil errors
-- ================================================

local ok_rayfield, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not ok_rayfield then warn("❌ Failed to load Rayfield UI") return end

-- ================================================
-- CONSTANTS
-- ================================================
local HUB_NAME     = "Unknown Hub"
local HUB_GAME     = "Minen Update v1 ⛏️"
local VERSION_FILE = "unknown_Version.txt"
local DEFAULT_VER  = "v1.0"
local DISCORD_LINK = "https://discord.gg/yourlinkhere"
local UPDATE_URL   = "https://raw.githubusercontent.com/glitchstikers/Testscript-/main/Version.lua"

-- ================================================
-- VERSION
-- ================================================
local function LoadVersion()
    local ok, data = pcall(function()
        return (isfile and isfile(VERSION_FILE)) and readfile(VERSION_FILE) or DEFAULT_VER
    end)
    return (ok and data and data:match("^%s*(.-)%s*$")) or DEFAULT_VER
end
local function SaveVersion(v)
    pcall(function() if writefile then writefile(VERSION_FILE, v) end end)
end
local CurrentVersion = LoadVersion()

-- ================================================
-- NOTIFY HELPER (safe, always works)
-- ================================================
local function Notify(title, content, duration)
    pcall(function()
        Rayfield:Notify({ Title = title, Content = content, Duration = duration or 4 })
    end)
end

-- ================================================
-- WINDOW
-- ================================================
local Window = Rayfield:CreateWindow({
    Name            = string.format("%s | %s | %s", HUB_NAME, HUB_GAME, CurrentVersion),
    LoadingTitle    = "Loading Unknown Hub...",
    LoadingSubtitle = "By Unknown Team",
    ShowText        = "Unknown Hub",
    Icon            = "hammer",
    Theme           = "Dark",
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "minen",
        FileName   = "unknown_hub"
    },
    Discord = {
        Enabled       = true,
        Invite        = "noinvitelink",
        RememberJoins = true
    }
})

-- ================================================
-- SERVICES
-- ================================================
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local player            = Players.LocalPlayer

-- ================================================
-- SAFE REMOTE FINDER
-- Waits up to `timeout` seconds, returns nil if not found
-- ================================================
local function SafeFind(parent, name, timeout)
    if not parent then return nil end
    local ok, result = pcall(function()
        return parent:WaitForChild(name, timeout or 8)
    end)
    if ok and result then return result end
    warn("⚠️ Remote not found: " .. tostring(name))
    return nil
end

-- ================================================
-- REMOTES — all nil-safe
-- ================================================
local Remotes, Functions, Events
local BuyItem, TryCastPile, MiningRemote, DialogueProgress

local function InitRemotes()
    Remotes   = SafeFind(ReplicatedStorage, "Remotes", 10)
    if not Remotes then
        Notify("❌ Remote Error", "Remotes folder not found. Some features may not work.", 8)
        return
    end
    Functions = SafeFind(Remotes, "Functions", 8)
    Events    = SafeFind(Remotes, "Events", 8)

    if Functions then
        BuyItem     = SafeFind(Functions, "BuyItem",     8)
        TryCastPile = SafeFind(Functions, "TryCastPile", 8)
    end
    if Events then
        MiningRemote     = SafeFind(Events, "MiningRemote",     8)
        DialogueProgress = SafeFind(Events, "DialogueProgress", 8)
    end

    -- Report what loaded
    local loaded, missing = {}, {}
    for name, ref in pairs({
        BuyItem=BuyItem, TryCastPile=TryCastPile,
        MiningRemote=MiningRemote, DialogueProgress=DialogueProgress
    }) do
        if ref then table.insert(loaded, name) else table.insert(missing, name) end
    end
    if #missing > 0 then
        Notify("⚠️ Some Remotes Missing", table.concat(missing, ", ") .. " not found.", 6)
    else
        Notify("✅ Remotes Loaded", "All remotes connected successfully.", 4)
    end
end

task.spawn(InitRemotes)

-- ================================================
-- SAFE CALL HELPERS
-- ================================================
local function SafeFire(remote, remoteName, ...)
    if not remote then
        Notify("❌ Remote Error", remoteName .. " is not available.", 3)
        return false
    end
    local ok, err = pcall(function() remote:FireServer(...) end)
    if not ok then
        Notify("❌ Fire Error", remoteName .. ": " .. tostring(err), 3)
        return false
    end
    return true
end

local function SafeInvoke(remote, remoteName, ...)
    if not remote then
        Notify("❌ Remote Error", remoteName .. " is not available.", 3)
        return false, nil
    end
    local ok, result = pcall(function() return remote:InvokeServer(...) end)
    if not ok then
        Notify("❌ Invoke Error", remoteName .. ": " .. tostring(result), 3)
        return false, nil
    end
    return true, result
end

-- ================================================
-- CHARACTER HELPERS
-- ================================================
local function GetHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    return hrp
end

local function TeleportTo(position, locationName)
    local hrp = GetHRP()
    if hrp then
        hrp.CFrame = CFrame.new(position)
        Notify("✅ Teleported", "Arrived at " .. locationName .. "!", 3)
    else
        Notify("❌ Teleport Failed", "HumanoidRootPart not found for " .. locationName, 3)
    end
end

-- ================================================
-- MAIN TAB
-- ================================================
local MainTab = Window:CreateTab("Main", "home")

MainTab:CreateParagraph({
    Title   = "👋 Welcome",
    Content = "Unknown Hub — making your Minen experience easier and more fun. 🍫"
})

MainTab:CreateButton({
    Name = "ℹ️ About Hub",
    Callback = function()
        Notify("ℹ️ About", HUB_NAME .. " | " .. HUB_GAME .. " | Version: " .. CurrentVersion, 5)
    end
})

MainTab:CreateButton({
    Name = "📋 Copy Discord Link",
    Callback = function()
        local ok = pcall(setclipboard, DISCORD_LINK)
        if ok then
            Notify("✅ Copied!", "Discord link copied to clipboard.", 3)
        else
            Notify("❌ Failed", "Could not copy to clipboard.", 3)
        end
    end
})

MainTab:CreateButton({
    Name = "🔄 Refresh Remotes",
    Callback = function()
        Notify("🔄 Refreshing...", "Re-connecting to game remotes.", 3)
        task.spawn(function()
            BuyItem, TryCastPile, MiningRemote, DialogueProgress = nil, nil, nil, nil
            task.wait(1)
            InitRemotes()
        end)
    end
})

MainTab:CreateParagraph({
    Title   = "⚠️ Disclaimer",
    Content = "Use at your own risk. We are not responsible for bans or consequences."
})

-- ================================================
-- FARM TAB
-- ================================================
local FarmTab = Window:CreateTab("Farm", "pickaxe")

local farmState = {
    autoFarm  = false,
    autoSell  = false,
    digSpeed  = 0.3,
    sellSpeed = 1.0,
}

local statusLabel = FarmTab:CreateLabel("Status: Idle ⏸️")

FarmTab:CreateSection("⛏️ AutoFarm")

FarmTab:CreateParagraph({
    Title   = "💡 Best Settings",
    Content = "0.15s dig speed = best balance of speed & stability. Lower = faster but may cause errors."
})

FarmTab:CreateSlider({
    Name         = "⏱️ Dig Speed (seconds)",
    Range        = {0.1, 2},
    Increment    = 0.05,
    CurrentValue = farmState.digSpeed,
    Flag         = "digSpeed",
    Callback     = function(v)
        farmState.digSpeed = v
        Notify("⚙️ Dig Speed", "Set to " .. v .. "s", 2)
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
            Notify("🔥 AutoFarm", "AutoFarm started! Dig speed: " .. farmState.digSpeed .. "s", 3)
            task.spawn(function()
                local cycleCount = 0
                while farmState.autoFarm do
                    local ok = pcall(function()
                        local speed = farmState.digSpeed

                        -- Cast pile
                        if TryCastPile then
                            pcall(function() TryCastPile:InvokeServer("Cast") end)
                        end
                        task.wait(speed)

                        -- Rarity sound
                        SafeFire(MiningRemote, "MiningRemote", "PlayRaritySound")

                        -- Pile progress
                        for _, progress in ipairs({2, 59.66, 100}) do
                            SafeFire(MiningRemote, "MiningRemote", "OnPileProgress", {
                                Progress       = progress,
                                TargetMinigame = true
                            })
                            task.wait(speed)
                        end

                        -- Bullseye
                        for _ = 1, 3 do
                            SafeFire(MiningRemote, "MiningRemote", "OnBullseyeProgress", {
                                BullseyeProgress = 23.5
                            })
                            task.wait(speed)
                        end

                        -- Catch result
                        SafeFire(MiningRemote, "MiningRemote", "CatchResult", { Success = true })
                        task.wait(speed)
                        cycleCount += 1
                    end)

                    -- Notify every 50 cycles
                    if cycleCount % 50 == 0 and cycleCount > 0 then
                        Notify("⛏️ AutoFarm", "Completed " .. cycleCount .. " mining cycles!", 3)
                    end
                end
                statusLabel:Set("Status: Idle ⏸️")
                Notify("⏸️ AutoFarm Stopped", "Completed " .. cycleCount .. " total cycles.", 4)
            end)
        else
            Notify("⏸️ AutoFarm", "AutoFarm disabled.", 3)
        end
    end
})

-- ─── AutoSell ─────────────────────────────────────
FarmTab:CreateSection("💰 AutoSell")

FarmTab:CreateParagraph({
    Title   = "📢 Important",
    Content = "Stand near a Sell NPC and keep the sell menu OPEN before enabling AutoSell, otherwise it won't work!"
})

FarmTab:CreateParagraph({
    Title   = "💡 Recommended Speed",
    Content = "0.6s is smooth and avoids lag/errors."
})

FarmTab:CreateSlider({
    Name         = "⏱️ AutoSell Speed (seconds)",
    Range        = {0.1, 5},
    Increment    = 0.1,
    CurrentValue = farmState.sellSpeed,
    Flag         = "sellSpeed",
    Callback     = function(v)
        farmState.sellSpeed = v
        Notify("⚙️ Sell Speed", "Set to " .. v .. "s", 2)
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

        if state then
            if not DialogueProgress then
                Notify("❌ AutoSell Error", "DialogueProgress remote not found. Try clicking 'Refresh Remotes' on the Main tab.", 6)
                farmState.autoSell = false
                return
            end
            Notify("💰 AutoSell Enabled", "Selling every " .. farmState.sellSpeed .. "s to all NPCs.", 4)
            task.spawn(function()
                local sellCount = 0
                while farmState.autoSell do
                    for _, npc in ipairs(SELL_NPCS) do
                        if not farmState.autoSell then break end
                        SafeFire(DialogueProgress, "DialogueProgress", npc, "SellAll")
                    end
                    sellCount += 1
                    if sellCount % 20 == 0 then
                        Notify("💰 AutoSell", "Completed " .. sellCount .. " sell cycles.", 3)
                    end
                    task.wait(farmState.sellSpeed)
                end
                Notify("⏸️ AutoSell Stopped", "Sell cycles completed: " .. sellCount, 4)
            end)
        else
            Notify("⏸️ AutoSell Disabled", "AutoSell has been turned off.", 3)
        end
    end
})

-- ================================================
-- TELEPORT TAB
-- ================================================
local TeleportTab = Window:CreateTab("Teleport", "map")

local LOCATIONS = {
    { name = "Oreville",            pos = Vector3.new(1218.24,  -2.38,  1036.68) },
    { name = "Glow Forest",         pos = Vector3.new(2840.52,  30.45,   743.44) },
    { name = "Cragpire",            pos = Vector3.new(4082.79,   6.79,   475.83) },
    { name = "Frostshard",          pos = Vector3.new(2582.50,  42.33,  3415.08) },
    { name = "Glimmergrove",        pos = Vector3.new(4194.71,  49.58,  1870.27) },
    { name = "Ashenreach",          pos = Vector3.new(-533.55,   2.67,  -330.58) },
    { name = "Rustmere",            pos = Vector3.new(1382.81,  85.88, -1001.60) },
    { name = "Boat Station",        pos = Vector3.new(1547.21,  16.36,  1308.58) },
    { name = "Lighthouse",          pos = Vector3.new(20.06,     3.64,  1651.04) },
    { name = "Mini Atlantis",       pos = Vector3.new(4528.42,  -2.24,  4176.88) },
    { name = "Enchanting Tower",    pos = Vector3.new(2742.54, -230.86,  756.54) },
}

TeleportTab:CreateSection("📍 All Locations")
TeleportTab:CreateParagraph({
    Title   = "ℹ️ How to Use",
    Content = "Tap any location button to instantly teleport there. Works best when not in a minigame."
})

for _, loc in ipairs(LOCATIONS) do
    TeleportTab:CreateButton({
        Name     = "📍 " .. loc.name,
        Callback = function()
            Notify("🔄 Teleporting...", "Going to " .. loc.name .. "...", 2)
            task.wait(0.3)
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
    Content = "Make sure you have enough money and meet the level requirements before purchasing."
})

local function CreateBuySection(tab, sectionTitle, itemType, itemList, icon)
    tab:CreateSection(sectionTitle)
    for _, item in ipairs(itemList) do
        tab:CreateButton({
            Name     = icon .. " Buy " .. item,
            Callback = function()
                Notify("🛒 Buying...", "Attempting to buy: " .. item, 2)
                local success, result = SafeInvoke(BuyItem, "BuyItem", itemType, item)
                if success then
                    Notify("✅ Purchased!", item .. " bought successfully.", 4)
                else
                    Notify("❌ Purchase Failed", "Could not buy " .. item .. ". Check money/level.", 4)
                end
            end
        })
    end
    tab:CreateButton({
        Name     = "💸 Buy ALL " .. sectionTitle,
        Callback = function()
            if not BuyItem then
                Notify("❌ Error", "BuyItem remote not available. Try Refresh Remotes.", 4)
                return
            end
            Notify("💸 Buying All...", "Purchasing all " .. sectionTitle .. "...", 3)
            task.spawn(function()
                local bought, failed = 0, 0
                for _, item in ipairs(itemList) do
                    local ok = SafeInvoke(BuyItem, "BuyItem", itemType, item)
                    if ok then bought += 1 else failed += 1 end
                    task.wait(0.25)
                end
                Notify(
                    "💸 Buy All Done — " .. sectionTitle,
                    "✅ Bought: " .. bought .. "  ❌ Failed: " .. failed,
                    6
                )
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

CreateBuySection(MarketTab, "⛏️ Pickaxes",  "Pickaxe", PICKAXES,  "⛏️")
CreateBuySection(MarketTab, "🎒 Backpacks", "Backpack", BACKPACKS, "🎒")
CreateBuySection(MarketTab, "🚗 Vehicles",  "Vehicles", VEHICLES,  "🚗")

-- ================================================
-- MISC TAB
-- ================================================
local MiscTab = Window:CreateTab("Misc", "book")

-- Enchanting Section
MiscTab:CreateSection("✨ Enchanting")
MiscTab:CreateParagraph({
    Title   = "📋 Requirements",
    Content = "Must be at the Enchanting Tower with a Lightning Rune in your inventory. Must be nighttime in-game."
})

MiscTab:CreateButton({
    Name     = "⚡ Teleport to Enchanting Tower",
    Callback = function()
        Notify("🔄 Teleporting...", "Going to Enchanting Tower...", 2)
        task.wait(0.3)
        TeleportTo(Vector3.new(2742.54, -230.86, 756.54), "Enchanting Tower")
    end
})

MiscTab:CreateButton({
    Name     = "🛒 Buy Lightning Rune",
    Callback = function()
        Notify("🛒 Buying...", "Attempting to buy Lightning Rune...", 2)
        local ok, result = SafeInvoke(BuyItem, "BuyItem", "Items", "Lightning Rune", 1)
        if ok then
            Notify("✅ Purchased!", "Lightning Rune bought successfully.", 4)
        else
            Notify("❌ Purchase Failed", "Could not buy Lightning Rune. Check money/level.", 4)
        end
    end
})

-- Admin Detection Section
local adminState = { enabled = false, action = "Warn" }

local ADMIN_IDS = {
    3606665012,
    1363894312,
    411198659,
    131141674,
}

MiscTab:CreateSection("🛡️ Admin Detection")
MiscTab:CreateParagraph({
    Title   = "ℹ️ How It Works",
    Content = "'Warn' → notification when admin joins. 'Leave' → auto-leaves server. 'None' → silent."
})

MiscTab:CreateDropdown({
    Name          = "Detection Action",
    Options       = {"Warn", "Leave", "None"},
    CurrentOption = "Warn",
    Flag          = "adminAction",
    Callback      = function(selected)
        adminState.action = selected
        Notify("🛡️ Admin Detection", "Action set to: " .. selected, 3)
    end
})

MiscTab:CreateToggle({
    Name         = "🛡️ Enable Admin Detection",
    CurrentValue = false,
    Flag         = "adminDetect",
    Callback     = function(state)
        adminState.enabled = state
        Notify(
            "🛡️ Admin Detection",
            state and "Detection is now ENABLED." or "Detection is now DISABLED.",
            3
        )
    end
})

Players.PlayerAdded:Connect(function(p)
    if not adminState.enabled then return end
    if not table.find(ADMIN_IDS, p.UserId) then return end

    if adminState.action == "Warn" then
        Notify("⚠️ Admin Joined!", p.Name .. " (admin) has entered the server!", 10)
    elseif adminState.action == "Leave" then
        Notify("⚠️ Admin Detected!", "Leaving server in 3 seconds... Admin: " .. p.Name, 6)
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
    Title   = "ℹ️ About Settings",
    Content = "Save and restore all your hub toggle/slider/dropdown settings here."
})

SettingsTab:CreateButton({
    Name     = "💾 Save Configuration",
    Callback = function()
        local ok = pcall(function() Rayfield:SaveConfiguration() end)
        if ok then
            Notify("✅ Saved", "Your configuration has been saved.", 3)
        else
            Notify("❌ Save Failed", "Could not save configuration.", 3)
        end
    end
})

SettingsTab:CreateButton({
    Name     = "📂 Load Configuration",
    Callback = function()
        local ok = pcall(function() Rayfield:LoadConfiguration() end)
        if ok then
            Notify("✅ Loaded", "Your configuration has been loaded.", 3)
        else
            Notify("❌ Load Failed", "Could not load configuration.", 3)
        end
    end
})

SettingsTab:CreateButton({
    Name     = "🔄 Refresh Remotes",
    Callback = function()
        Notify("🔄 Refreshing...", "Re-connecting to all game remotes.", 3)
        task.spawn(function()
            BuyItem, TryCastPile, MiningRemote, DialogueProgress = nil, nil, nil, nil
            task.wait(1)
            InitRemotes()
        end)
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
    if latest and latest ~= "" and latest ~= CurrentVersion then
        SaveVersion(latest)
        CurrentVersion = latest
        pcall(function()
            Window:SetName(string.format("%s | %s | %s", HUB_NAME, HUB_GAME, CurrentVersion))
        end)
        Notify("⬆️ Update Available!", "New version: " .. latest .. ". Rejoin for latest features.", 10)
    end
end

task.spawn(function()
    while true do
        CheckForUpdate()
        task.wait(60)
    end
end)

-- ================================================
-- DISCORD REMINDER
-- ================================================
task.spawn(function()
    task.wait(600)
    while true do
        Notify("📢 Discord", "Join our community: discord.gg/yourlinkhere", 6)
        task.wait(600)
    end
end)

-- ================================================
-- READY
-- ================================================
Notify("✅ " .. HUB_NAME .. " Ready", "Version " .. CurrentVersion .. " — All systems active! ⛏️", 5)
