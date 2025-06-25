-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Basic Information
local CurrentName = "Unknown Hub v1"
local CurrentGame = "Minen ⛏️"
local DefaultVersion = "v1.0"
local VersionFile = "unknown_Version.txt"

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

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = string.format("%s | %s | %s", CurrentName, CurrentGame, CurrentVersion),
    Icon = 0,
    Theme = "Dark"
})

-- Services & Remotes
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Functions = Remotes:WaitForChild("Functions")
local Events = Remotes:WaitForChild("Events")
local TryCastPile = Functions:WaitForChild("TryCastPile")
local MiningRemote = Events:WaitForChild("MiningRemote")
local DialogueProgress = Events:WaitForChild("DialogueProgress")

----------------------------------------------------------
-- 🎛️ Main Tab
----------------------------------------------------------
local discordlink = "https://discord.gg/yourlinkhere"
local MainTab = Window:CreateTab("Main", "home")

MainTab:CreateSection("Info 🎯")
MainTab:CreateButton({
    Name = "ℹ️ About Us",
    Callback = function()
        Rayfield:Notify({
            Title = "📢 About Us",
            Content = "Easy to get, use, and improve your game experience.",
            Duration = 5
        })
    end
})

MainTab:CreateSection("⚠️ Disclaimer")
MainTab:CreateParagraph({
    Title = "🚨 Warning!",
    Content = "If you get kicked or banned, it's **your responsibility**, not ours."
})

MainTab:CreateSection("Support 🎉")
MainTab:CreateButton({
    Name = "Copy Discord Invite",
    Callback = function()
        setclipboard(discordlink)
        Rayfield:Notify({
            Title = "✅ Discord Link Copied",
            Content = "Invite link copied to clipboard.",
            Duration = 5
        })
    end
})

----------------------------------------------------------
-- ⛏️ Farm Tab
----------------------------------------------------------
local autoFarm = false
local autoSell = false
local digSpeed = 0.3

local FarmTab = Window:CreateTab("Farm", "pickaxe")
FarmTab:CreateSection("⛏️ Auto Digging")

local statusLabel = FarmTab:CreateLabel("Status: Idle")

FarmTab:CreateSlider({
    Name = "Dig Speed (seconds)",
    Range = {0.1, 2},
    Increment = 0.05,
    CurrentValue = digSpeed,
    Callback = function(value) digSpeed = value end
})

FarmTab:CreateToggle({
    Name = "🔥 Enable AutoFarm",
    CurrentValue = false,
    Callback = function(state)
        autoFarm = state
        if autoFarm then
            statusLabel:Set("Status: AutoFarm Running ⛏️")
            task.spawn(function()
                while autoFarm do
                    pcall(function()
                        TryCastPile:InvokeServer("Cast")
                        task.wait(digSpeed)
                        MiningRemote:FireServer("PlayRaritySound")
                        task.wait(digSpeed)
                        for _, p in ipairs({2, 59.66, 100}) do
                            MiningRemote:FireServer("OnPileProgress", {Progress = p, TargetMinigame = true})
                            task.wait(digSpeed)
                        end
                        for _ = 1, 3 do
                            MiningRemote:FireServer("OnBullseyeProgress", {BullseyeProgress = 23.5})
                            task.wait(digSpeed)
                        end
                        MiningRemote:FireServer("CatchResult", {Success = true})
                        task.wait(digSpeed)
                    end)
                end
                statusLabel:Set("Status: Idle")
            end)
        else
            statusLabel:Set("Status: Idle")
        end
    end
})

FarmTab:CreateSection("💰 Auto Sell")

local SellNPCs = {"Joe Gravel", "Mike", "Zombie Gravel", "Dave Gravel", "Aurora"}

FarmTab:CreateToggle({
    Name = "🪙 Auto Sell (All NPCs)",
    CurrentValue = false,
    Callback = function(state)
        autoSell = state
        if autoSell then
            Rayfield:Notify({
                Title = "✅ Auto Sell Active",
                Content = "Selling to all NPCs.",
                Duration = 4
            })
            task.spawn(function()
                while autoSell do
                    for _, npc in ipairs(SellNPCs) do
                        pcall(function()
                            DialogueProgress:FireServer(npc, "SellAll")
                        end)
                        task.wait(1)
                    end
                    task.wait(3)
                end
            end)
        else
            Rayfield:Notify({
                Title = "🛑 Auto Sell Stopped",
                Content = "Auto sell turned off.",
                Duration = 3
            })
        end
    end
})

----------------------------------------------------------
-- 🛒 Market Tab
----------------------------------------------------------
local MarketTab = Window:CreateTab("Market", "shopping-bag")
MarketTab:CreateSection("🛒 Pickaxes")

local pickaxeList = {
    "Stone Pickaxe", "Copper Pickaxe", "Palm Tree Pickaxe", "Lucky Pickaxe",
    "Iron Pickaxe", "Sword Pickaxe", "Soil Pickaxe", "Golden Pickaxe",
    "Voxel Pickaxe", "Climber Pickaxe", "Twisted Pickaxe", "Futuristic Pickaxe",
    "Jester Pickaxe", "Lighthouse Pickaxe", "Magma Pickaxe", "Frozen Pickaxe",
    "Overseer Pickaxe", "Traffic Pickaxe", "Trident Pickaxe", "Shark Pickaxe"
}

local selectedPickaxe = pickaxeList[1]

MarketTab:CreateDropdown({
    Name = "Pickaxe List",
    Options = pickaxeList,
    CurrentOption = selectedPickaxe,
    Callback = function(option)
        selectedPickaxe = option
        Rayfield:Notify({
            Title = "✅ Pickaxe Selected",
            Content = "Selected: " .. option,
            Duration = 3
        })
    end
})

MarketTab:CreateButton({
    Name = "🛒 Buy Selected Pickaxe",
    Callback = function()
        local args = {[1] = "Pickaxe", [2] = selectedPickaxe}
        local result = Functions:WaitForChild("BuyItem"):InvokeServer(unpack(args))
        if result == "NotEnoughLevel" then
            Rayfield:Notify({Title="❌ Not Enough Level",Content="You don't meet the level for: "..selectedPickaxe,Duration=4})
        elseif result == "Success" or result == true then
            Rayfield:Notify({Title="🛒 Purchase Successful",Content="Bought: "..selectedPickaxe,Duration=4})
            task.wait(0.5)
            AutoEquipBestPickaxe()
        else
            Rayfield:Notify({Title="❌ Purchase Failed",Content="Reason: "..tostring(result),Duration=4})
        end
    end
})

function AutoEquipBestPickaxe()
    local backpack = game.Players.LocalPlayer.Backpack
    local tools = {}
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:find("Pickaxe") then
            table.insert(tools, tool)
        end
    end
    if #tools == 0 then
        Rayfield:Notify({Title="❌ No Pickaxes Found",Content="You have no pickaxes in your backpack.",Duration=4})
        return
    end
    table.sort(tools, function(a,b) return a.Name > b.Name end)
    game.Players.LocalPlayer.Character.Humanoid:EquipTool(tools[1])
    Rayfield:Notify({Title="✅ Pickaxe Equipped",Content="Equipped: "..tools[1].Name,Duration=4})
end

MarketTab:CreateButton({
    Name = "🎒 Auto Equip Best Pickaxe",
    Callback = AutoEquipBestPickaxe
})

----------------------------------------------------------
-- ✅ GUI Loaded Notify
----------------------------------------------------------
Rayfield:Notify({
    Title = "✅ Unknown Hub Loaded",
    Content = "Welcome to Unknown Hub!",
    Duration = 5
})
