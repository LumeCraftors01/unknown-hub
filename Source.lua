-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Load Services
local HttpService = game:GetService("HttpService")

-- Platoboost API Library (with full validation)
local Platoboost = {}

Platoboost.APIBase = "https://api.platoboost.com"
Platoboost.Secret = "32cb930f-f6cb-45ea-ad13-aefd18307edc"
Platoboost.HWID = game:GetService("RbxAnalyticsService"):GetClientId()

local ServiceName = "minenhack"
local MainScriptURL = "https://raw.githubusercontent.com/LumeCraftors01/unknown-hub/refs/heads/main/Loaderv1.lua"

-- Response message utility
local function onMessage(msg)
    Rayfield:Notify({
        Title = "Platoboost",
        Content = msg,
        Duration = 4
    })
end

function Platoboost:GetServiceLink(service)
    local url = string.format("%s/public/start?service=%s", self.APIBase, service)
    local response = syn and syn.request({Url = url, Method = "GET"}) or http_request({Url = url, Method = "GET"})

    if response.StatusCode == 200 then
        local decoded = HttpService:JSONDecode(response.Body)
        if decoded.success and decoded.link then
            return decoded.link
        else
            onMessage(decoded.message or "Unknown error while fetching link.")
            return "⚠️ Error retrieving link."
        end
    elseif response.StatusCode == 429 then
        onMessage("You are being rate limited, please wait a bit and try again.")
        return "⚠️ Rate limited."
    else
        onMessage("Server returned an invalid status code, please try again later.")
        return "⚠️ Server error."
    end
end

function Platoboost:CheckKey(service)
    local url = string.format("%s/public/keys/%s?hwid=%s", self.APIBase, service, self.HWID)
    local response = syn and syn.request({Url = url, Method = "GET"}) or http_request({Url = url, Method = "GET"})

    if response.StatusCode == 200 then
        local decoded = HttpService:JSONDecode(response.Body)
        if decoded.success and decoded.key then
            return true, decoded.key
        else
            return false, decoded.message or "No active key."
        end
    else
        return false, "Failed to check key (HTTP " .. response.StatusCode .. ")"
    end
end

function Platoboost:RedeemKey(service, userKey)
    local url = string.format("%s/public/redeem/%s", self.APIBase, service)
    local body = HttpService:JSONEncode({ key = userKey, hwid = self.HWID })
    local headers = {["Content-Type"] = "application/json"}

    local response = syn and syn.request({
        Url = url, Method = "POST", Headers = headers, Body = body
    }) or http_request({
        Url = url, Method = "POST", Headers = headers, Body = body
    })

    if response.StatusCode == 200 then
        local decoded = HttpService:JSONDecode(response.Body)
        if decoded.success then
            return true, decoded.message
        else
            return false, decoded.message
        end
    else
        return false, "Server returned status " .. response.StatusCode
    end
end

function Platoboost:GetFlags(service)
    local url = string.format("%s/public/flags/%s?hwid=%s", self.APIBase, service, self.HWID)
    local response = syn and syn.request({Url = url, Method = "GET"}) or http_request({Url = url, Method = "GET"})

    if response.StatusCode == 200 then
        local decoded = HttpService:JSONDecode(response.Body)
        if decoded.success and decoded.flags then
            return decoded.flags
        else
            onMessage(decoded.message or "Failed to get flags.")
            return nil
        end
    else
        onMessage("Error getting flags. (HTTP " .. response.StatusCode .. ")")
        return nil
    end
end

function Platoboost:DeleteKey(service)
    local url = string.format("%s/public/deletekey/%s?hwid=%s", self.APIBase, service, self.HWID)
    local response = syn and syn.request({Url = url, Method = "GET"}) or http_request({Url = url, Method = "GET"})

    if response.StatusCode == 200 then
        local decoded = HttpService:JSONDecode(response.Body)
        if decoded.success then
            return true, decoded.message
        else
            return false, decoded.message
        end
    else
        return false, "Server returned status " .. response.StatusCode
    end
end

function Platoboost:GetHWID()
    return self.HWID
end

-- UI Setup
local Window = Rayfield:CreateWindow({
    Name = "Delta Hub | Key System",
    LoadingTitle = "Authenticating...",
    LoadingSubtitle = "Powered by Platoboost",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DeltaHub",
        FileName = "KeySystemData"
    }
})

local KeyTab = Window:CreateTab("🔑 Key System", 4483362458)

local function getLiveLink()
    return Platoboost:GetServiceLink(ServiceName)
end

local LinkParagraph = KeyTab:CreateParagraph({
    Title = "Get Your Key",
    Content = "Key Link:\n" .. getLiveLink()
})

KeyTab:CreateInput({
    Name = "Enter Your Key",
    PlaceholderText = "Paste your Platoboost key here",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        _G.CurrentKey = text
    end
})

KeyTab:CreateButton({
    Name = "📋 Copy Key Link",
    Callback = function()
        local link = getLiveLink()
        setclipboard(link)
        onMessage("Link copied to clipboard.")
    end
})

KeyTab:CreateButton({
    Name = "🔄 Refresh Key Link",
    Callback = function()
        local newLink = getLiveLink()
        LinkParagraph:Set({Content = "Key Link:\n" .. newLink})
        onMessage("Key link refreshed.")
    end
})

KeyTab:CreateButton({
    Name = "✅ Redeem Key",
    Callback = function()
        if not _G.CurrentKey then
            onMessage("Please enter a key first.")
            return
        end
        local isValid, result = Platoboost:RedeemKey(ServiceName, _G.CurrentKey)
        if isValid then
            onMessage(result)
            loadstring(game:HttpGet(MainScriptURL))()
        else
            onMessage(result)
        end
    end
})

KeyTab:CreateButton({
    Name = "🎌 Show Flags (Debug)",
    Callback = function()
        local flags = Platoboost:GetFlags(ServiceName)
        if flags then
            onMessage("Flags: " .. table.concat(flags, ", "))
        end
    end
})

KeyTab:CreateButton({
    Name = "❌ Unbind/Delete Key",
    Callback = function()
        local ok, msg = Platoboost:DeleteKey(ServiceName)
        if ok then
            onMessage("Key deleted.")
        else
            onMessage(msg)
        end
    end
})

task.spawn(function()
    local isValid, result = Platoboost:CheckKey(ServiceName)
    if isValid then
        onMessage("Key verified. Loading hub.")
        loadstring(game:HttpGet(MainScriptURL))()
    else
        onMessage(result)
    end
end)
