-- **Loader**
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- **Basic Information**
local CurrentName = "unknown Hub v1"
local CurrentGame = "Game"
local DefaultVersion = "v1.0"

-- **Persistent Version Storage**
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

-- **Create UI Window**
local Window = Rayfield:CreateWindow({
    Name = string.format("%s | %s | %s", CurrentName, CurrentGame, CurrentVersion),
    Icon = 0, -- You can change this to an asset ID if needed
    Theme = "Dark"
})

-- **Home Tab**
local HomeTab = Window:CreateTab("Home", "Home")
HomeTab:CreateSection("📌 Support")

HomeTab:CreateButton({
    Name = "ℹ️ About Us",
    Callback = function()
        Rayfield:Notify({
            Title = "📢 About Us",
            Content = "Shadow is designed for testing purposes.",
            Duration = 5
        })
    end
})

HomeTab:CreateSection("⚠️ Disclaimer")

HomeTab:CreateParagraph({
    Title = "🚨 Warning!",
    Content = "If you get kicked or banned, it's **your responsibility**, not ours."
})

-- **Settings Tab**
local SettingTab = Window:CreateTab("Settings", "Settings")
SettingTab:CreateSection("📝 Configuration")

SettingTab:CreateButton({
    Name = "📦 Save Data",
    Callback = function()
        Rayfield:Notify({
            Title = "✅ Success",
            Content = "Successfully saved data.",
            Duration = 5
        })
        Rayfield:LoadConfiguration()
    end
})

-- **Check for Updates**
local function CheckForUpdate()
    local success, response = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/glitchstikers/Testscript-/main/Version.lua")
    end)

    if success and response then
        local LatestVersion = response:match("^%s*(.-)%s*$")

        if LatestVersion and LatestVersion ~= CurrentVersion then
            Rayfield:Notify({
                Title = "⚠️ UPDATE DETECTED!",
                Content = "New version available: " .. LatestVersion .. ". Please rejoin.",
                Duration = 10
            })

            SaveVersion(LatestVersion)
            CurrentVersion = LatestVersion
            Window:SetName(string.format("%s | %s | %s", CurrentName, CurrentGame, CurrentVersion))
        end
    else
        warn("⚠️ Failed to check for updates! Possible network issue.")
    end
end

-- **Periodic Update Check**
task.spawn(function()
    while true do
        CheckForUpdate()
        task.wait(30) -- Every 30 seconds
    end
end)

-- **Initial Update Check**
CheckForUpdate()

-- **Auto Load Config**
pcall(function()
    Rayfield:LoadConfiguration()
end)

-- **Optional AutoSave Function**
local function AutoSave()
    pcall(function()
        Rayfield:SaveConfiguration()
    end)
end
