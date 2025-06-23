--! Configuration
local service = 4599
local secret = "32cb930f-f6cb-45ea-ad13-aefd18307edc"
local useNonce = true

repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local fSetClipboard = setclipboard or toclipboard
local fRequest = request or http_request or syn.request or fluxus and fluxus.request
local fStringChar, fToString = string.char, tostring
local fMathRandom = math.random
local fGetHwid = gethwid or function() return game:GetService("Players").LocalPlayer.UserId end

if not fRequest then error("No supported HTTP request function found.") end

local lEncode = function(data) return HttpService:JSONEncode(data) end
local lDecode = function(data) return HttpService:JSONDecode(data) end

local lDigest = function(text)
    if crypt and crypt.hash then return crypt.hash(text, "sha256")
    elseif syn and syn.crypt and syn.crypt.hash then return syn.crypt.hash(text, "sha256")
    elseif fluxus and fluxus.hash then return fluxus.hash(text)
    elseif hash and typeof(hash) == "function" then return hash(text)
    else error("No supported SHA256 hashing function available.") end
end

local host = "https://api.platoboost.com"
local hostResponse = fRequest({ Url = host .. "/public/connectivity", Method = "GET" })
if not hostResponse or (hostResponse.StatusCode ~= 200 and hostResponse.StatusCode ~= 429) then
    host = "https://api.platoboost.net"
end

local function generateNonce()
    local nonce = {}
    for _ = 1, 16 do table.insert(nonce, fStringChar(fMathRandom(97, 122))) end
    return table.concat(nonce)
end

local function loadExternalScript()
    local scriptUrl = "https://raw.githubusercontent.com/LumeCraftors01/unknown-hub/main/Loaderv1.lua"
    local success, result = pcall(function() return loadstring(game:HttpGet(scriptUrl))() end)
    if success then
        warn("[Platoboost] Script loaded successfully.")
    else
        warn("Script load error:", result)
    end
end

local function checkActiveKeyForHwidAndLoad()
    local nonce = generateNonce()
    local url = host .. "/public/keys/" .. tostring(service)
    url = url .. "?identifier=" .. lDigest(fGetHwid())
    if useNonce then url = url .. "&nonce=" .. nonce end

    local response = fRequest({ Url = url, Method = "GET" })
    if not response then return false end

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        if decoded.success and decoded.data and #decoded.data > 0 then
            for _, keyData in ipairs(decoded.data) do
                if keyData.valid == true then
                    local expectedHash = lDigest("true-" .. nonce .. "-" .. secret)
                    if not useNonce or keyData.hash == expectedHash then
                        warn("[Platoboost] Active key found — loading script.")
                        loadExternalScript()
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function showKeySystemGui()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "Key System 🔐",
        LoadingTitle = "Connecting...",
        LoadingSubtitle = "Please wait...",
        ConfigurationSaving = { Enabled = true },
        Discord = { Enabled = false },
        KeySystem = false
    })

    local MainTab = Window:CreateTab("main", "Home")
    MainTab:CreateSection("key system 🗝️")

    MainTab:CreateButton({
        Name = "📋 Copy Key Link",
        Callback = function()
            local response = fRequest({
                Url = host .. "/public/start",
                Method = "POST",
                Body = lEncode({ service = service, identifier = lDigest(fGetHwid()) }),
                Headers = { ["Content-Type"] = "application/json" }
            })
            if response and response.StatusCode == 200 then
                local decoded = lDecode(response.Body)
                if decoded.success and fSetClipboard then
                    fSetClipboard(decoded.data.url)
                    Rayfield:Notify({ Title = "Copied!", Content = "Key link copied to clipboard.", Duration = 4 })
                end
            end
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
                Rayfield:Notify({ Title = "No Key Entered", Content = "Please enter a key.", Duration = 4 })
                return
            end
            local success = fRequest({
                Url = host .. "/public/redeem/" .. tostring(service),
                Method = "POST",
                Body = lEncode({ identifier = lDigest(fGetHwid()), key = _G.Key }),
                Headers = { ["Content-Type"] = "application/json" }
            })
            if success and success.StatusCode == 200 then
                local decoded = lDecode(success.Body)
                if decoded.success then
                    Rayfield:Notify({ Title = "✅ Key Valid", Content = "Loading your script...", Duration = 5 })
                    loadExternalScript()
                else
                    Rayfield:Notify({ Title = "❌ Invalid Key", Content = decoded.message or "Invalid key.", Duration = 5 })
                end
            else
                Rayfield:Notify({ Title = "Error", Content = "Request failed.", Duration = 4 })
            end
        end
    })
end

if not checkActiveKeyForHwidAndLoad() then
    showKeySystemGui()
end
