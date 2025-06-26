--! Configuration
local service = 4599
local secret = "32cb930f-f6cb-45ea-ad13-aefd18307edc"
local useNonce = true

local HttpService = game:GetService("HttpService")

repeat task.wait() until game:IsLoaded()

local onMessage = function(msg)
    warn("[Platoboost] " .. msg)
end

local fSetClipboard = setclipboard or toclipboard
local fRequest = request or http_request or syn.request or fluxus and fluxus.request
local fStringChar, fToString, fStringSub = string.char, tostring, string.sub
local fOsTime, fMathRandom, fMathFloor = os.time, math.random, math.floor
local fGetHwid = gethwid or function() return game:GetService("Players").LocalPlayer.UserId end

if not fRequest then error("No supported HTTP request function found.") end

local lEncode = function(data) return HttpService:JSONEncode(data) end
local lDecode = function(data) return HttpService:JSONDecode(data) end

local lDigest = function(text)
    if crypt and crypt.hash then return crypt.hash(text, "sha256")
    elseif syn and syn.crypt and syn.crypt.hash then return syn.crypt.hash(text, "sha256")
    elseif fluxus and fluxus.hash then return fluxus.hash(text)
    elseif hash and typeof(hash) == "function" then return hash(text)
    else error("No supported SHA256 hash available.") end
end

local host = "https://api.platoboost.com"
local hostResponse = fRequest({ Url = host .. "/public/connectivity", Method = "GET" })
if not hostResponse or (hostResponse.StatusCode ~= 200 and hostResponse.StatusCode ~= 429) then
    host = "https://api.platoboost.net"
end

--! Generate Nonce
local function generateNonce()
    local nonce = {}
    for _ = 1, 16 do
        table.insert(nonce, fStringChar(fMathRandom(97, 122)))
    end
    return table.concat(nonce)
end

--! Link caching
local cachedLink, cachedTime = "", 0
local function cacheLink()
    if fOsTime() > cachedTime + 600 then
        local response = fRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode({ service = service, identifier = lDigest(fGetHwid()) }),
            Headers = { ["Content-Type"] = "application/json" }
        })
        if not response then
            onMessage("Failed to send start request.")
            return false, nil
        end
        if response.StatusCode == 200 then
            local decoded = lDecode(response.Body)
            if decoded.success then
                cachedLink, cachedTime = decoded.data.url, fOsTime()
                return true, cachedLink
            else
                onMessage(decoded.message)
                return false, nil
            end
        elseif response.StatusCode == 429 then
            onMessage("Rate limited — wait 20s.")
            return false, nil
        else
            onMessage("Failed to cache link.")
            return false, nil
        end
    else
        return true, cachedLink
    end
end

local function copyLink()
    local success, link = cacheLink()
    if success and fSetClipboard then
        fSetClipboard(link)
    else
        onMessage("Failed to copy link.")
    end
end

--! Redeem Key
local function redeemKey(key)
    local nonce = generateNonce()
    local body = { identifier = lDigest(fGetHwid()), key = key }
    if useNonce then body.nonce = nonce end

    local response = fRequest({
        Url = host .. "/public/redeem/" .. fToString(service),
        Method = "POST",
        Body = lEncode(body),
        Headers = { ["Content-Type"] = "application/json" }
    })

    if not response then onMessage("Failed to redeem.") return false end

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        if decoded.success and decoded.data.valid then
            if not useNonce or decoded.data.hash == lDigest("true-" .. nonce .. "-" .. secret) then
                return true
            else onMessage("Nonce mismatch.") return false end
        else onMessage(decoded.message or "Invalid key.") return false end
    elseif response.StatusCode == 429 then onMessage("Rate limited.") return false
    else onMessage("Server error.") return false end
end

--! Verify Key
local requestSending = false
local function verifyKey(key)
    if requestSending then onMessage("Request in progress.") return false end
    requestSending = true

    local nonce = generateNonce()
    local url = host .. "/public/whitelist/" .. fToString(service)
    url = url .. "?identifier=" .. lDigest(fGetHwid()) .. "&key=" .. key
    if useNonce then url = url .. "&nonce=" .. nonce end

    local response = fRequest({ Url = url, Method = "GET" })
    requestSending = false

    if not response then onMessage("Failed to verify.") return false end

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        if decoded.success and decoded.data.valid then
            if not useNonce or decoded.data.hash == lDigest("true-" .. nonce .. "-" .. secret) then
                return true
            else onMessage("Nonce mismatch.") return false end
        elseif fStringSub(key, 1, 4) == "KEY_" then
            return redeemKey(key)
        else onMessage(decoded.message or "Invalid key.") return false end
    elseif response.StatusCode == 429 then onMessage("Rate limited.") return false
    else onMessage("Server error.") return false end
end

--! Safe External Script Loader
local function loadExternalScript()
    local url = "https://raw.githubusercontent.com/LumeCraftors01/unknown-hub/main/Loaderv1.lua"
    local success, result = pcall(function() return loadstring(game:HttpGet(url))() end)
    if success then
        Rayfield:Notify({ Title = "✅ Loaded", Content = "Script loaded.", Duration = 5 })
    else
        Rayfield:Notify({ Title = "❌ Error", Content = "Failed to load.", Duration = 5 })
        warn("Load Error:", result)
    end
end

--! Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Delta Hub 🔐",
    LoadingTitle = "Connecting...",
    LoadingSubtitle = "Authenticating...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "KeySystem",
        FileName = "config"
    }
})

--! UI
local MainTab = Window:CreateTab("Main", "home")
MainTab:CreateSection("Key System")

MainTab:CreateButton({
    Name = "📋 Copy Key Link",
    Callback = function()
        copyLink()
        Rayfield:Notify({ Title = "Copied", Content = "Key link copied.", Duration = 3 })
    end
})

_G.Key = "none"
local keyLabel = MainTab:CreateLabel("Current Key: [none]")

MainTab:CreateInput({
    Name = "Enter Key",
    PlaceholderText = "Paste your Platoboost key",
    RemoveTextAfterFocusLost = false,
    Callback = function(input)
        _G.Key = input
        keyLabel:Set("Current Key: " .. input)
    end
})

MainTab:CreateButton({
    Name = "✅ Check Key",
    Callback = function()
        if _G.Key == "none" or _G.Key == "" then
            Rayfield:Notify({ Title = "Missing", Content = "Enter your key first.", Duration = 3 })
            return
        end
        local valid = verifyKey(_G.Key)
        if valid then
            Rayfield:Notify({ Title = "✅ Valid", Content = "Loading script...", Duration = 4 })
            loadExternalScript()
        else
            Rayfield:Notify({ Title = "❌ Invalid", Content = "Invalid key.", Duration = 4 })
        end
    end
})

--! Settings Tab
local Setting = Window:CreateTab("Settings", "settings")
Setting:CreateDropdown({
    Name = "Theme",
    Options = { "Default", "EmberGlow", "Amethyst", "Bloom", "DarkBlue", "Green", "Light", "Ocean", "Serenity" },
    CurrentOption = "Default",
    Callback = function(theme)
        Rayfield:SetTheme(theme)
        Rayfield:Notify({ Title = "Theme Changed", Content = "Now using " .. theme, Duration = 3 })
    end
})

local notificationsEnabled = true
Setting:CreateToggle({
    Name = "Enable Notifications",
    CurrentValue = true,
    Callback = function(v)
        notificationsEnabled = v
        Rayfield:Notify({ Title = "Notifications", Content = "Now " .. (v and "Enabled" or "Disabled"), Duration = 3 })
    end
})

Setting:CreateButton({
    Name = "💾 Save Settings",
    Callback = function()
        Rayfield:SaveConfiguration()
        Rayfield:Notify({ Title = "Saved", Content = "Settings saved.", Duration = 3 })
    end
})

Setting:CreateButton({
    Name = "📤 Load Settings",
    Callback = function()
        Rayfield:LoadConfiguration()
        Rayfield:Notify({ Title = "Loaded", Content = "Settings loaded.", Duration = 3 })
    end
})

Setting:CreateButton({
    Name = "❌ Exit Script",
    Callback = function()
        Rayfield:Destroy()
        onMessage("Script closed.")
    end
})
