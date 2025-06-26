-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Load Services
local HttpService = game:GetService("HttpService")

-- Platoboost API Implementation
local Platoboost = {}

Platoboost.APIBase = "https://api.platoboost.com"
Platoboost.Secret = "32cb930f-f6cb-45ea-ad13-aefd18307edc" -- Replace this
Platoboost.HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- Service name and main hub loader URL
local ServiceName = "unknown hub"
local MainScriptURL = "https://raw.githubusercontent.com/LumeCraftors01/unknown-hub/refs/heads/main/Loaderv1.lua" -- Replace with your hub script URL

-- Get Platoboost Key Link
function Platoboost:GetServiceLink(service)
    local url = string.format("%s/public/start?service=%s", self.APIBase, service)
    local response = game:HttpGet(url)
    local data = HttpService:JSONDecode(response)
    return data.link or "Link not found."
end

-- Check Active Key on HWID
function Platoboost:CheckKey(service)
    local url = string.format("%s/public/keys/%s?hwid=%s", self.APIBase, service, self.HWID)
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if success and result.success and result.key then
        return true, result.key
    else
        return false, result.message or "No active key."
    end
end

-- Redeem Key
function Platoboost:RedeemKey(service, userKey)
    local url = string.format("%s/public/redeem/%s", self.APIBase, service)
    local body = HttpService:JSONEncode({
        key = userKey,
        hwid = self.HWID
    })
    local headers = {
        ["Content-Type"] = "application/json"
    }

    local response = syn and syn.request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    }) or http_request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })

    if response.Success then
        local data = HttpService:JSONDecode(response.Body)
        if data.success then
            return true, data.message or "Key redeemed."
        else
            return false, data.message or "Invalid key."
        end
    else
        return false, "HTTP Error."
    end
end

-- Create Window
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

-- Key Tab UI
local KeyTab = Window:CreateTab("🔑 Key System", 4483362458)

KeyTab:CreateParagraph({
    Title = "Get Your Key",
    Content = "Press 'Copy Key Link' to get your key from the site."
})

local KeyInput = KeyTab:CreateInput({
    Name = "Enter Your Key",
    PlaceholderText = "Paste your Platoboost key here",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        _G.CurrentKey = text
    end
})

KeyTab:CreateButton({
    Name = "Copy Key Link",
    Callback = function()
        local link = Platoboost:GetServiceLink(ServiceName)
        setclipboard(link)
        Rayfield:Notify({
            Title = "Copied!",
            Content = "Key link copied to clipboard.",
            Duration = 3
        })
    end
})

KeyTab:CreateButton({
    Name = "Redeem Key",
    Callback = function()
        if not _G.CurrentKey then
            Rayfield:Notify({
                Title = "Missing Key",
                Content = "Please paste your key first.",
                Duration = 3
            })
            return
        end
        local isValid, result = Platoboost:RedeemKey(ServiceName, _G.CurrentKey)
        if isValid then
            Rayfield:Notify({
                Title = "Success!",
                Content = result,
                Duration = 3
            })
            loadstring(game:HttpGet(MainScriptURL))()
        else
            Rayfield:Notify({
                Title = "Invalid Key",
                Content = result,
                Duration = 3
            })
        end
    end
})

-- Auto Check Key on Join
task.spawn(function()
    local isValid, result = Platoboost:CheckKey(ServiceName)
    if isValid then
        Rayfield:Notify({
            Title = "Key Verified",
            Content = "Loading hub automatically...",
            Duration = 3
        })
        loadstring(game:HttpGet(MainScriptURL))()
    else
        Rayfield:Notify({
            Title = "Key Required",
            Content = "No valid key found. Please redeem one.",
            Duration = 3
        })
    end
end)
