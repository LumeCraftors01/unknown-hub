-- **Loader**
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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
    Icon = 0,
    Theme = "Dark"
})

-- **Home Tab**
local HomeTab = Window:CreateTab("Home", "1000013070")
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
local SettingTab = Window:CreateTab("Settings", "1000013069")
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

-- **Function to Check for Updates**
local function CheckForUpdate()
    local success, response = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/LumeCraftors01/unknown-hub/refs/heads/main/Just%20a%20baseplate/Version")
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
        task.wait(30) -- Check every 30 seconds
    end
end)

-- **Check Immediately on Load**
CheckForUpdate()

-- **Auto Load Configuration**
pcall(function()
    Rayfield:LoadConfiguration()
end)

-- **AutoSave (Optional to use in future)**
local function AutoSave()
    pcall(function()
        Rayfield:SaveConfiguration()
    end)
end
