-- Improved Platoboost Key System with Enhanced UI and Feedback

local service = 4599 -- Platoboost Service ID local secret = "32cb930f-f6cb-45ea-ad13-aefd18307edc" -- Platoboost Secret local useNonce = true

local HttpService = game:GetService("HttpService") local Players = game:GetService("Players") local StarterGui = game:GetService("StarterGui")

repeat task.wait() until game:IsLoaded() and Players.LocalPlayer local player = Players.LocalPlayer

-- Safe Function Aliases local fSetClipboard = setclipboard or toclipboard local fRequest = request or http_request local fGetHwid = gethwid or function() return player.UserId end

-- Helper Functions local function lEncode(data) return HttpService:JSONEncode(data) end

local function lDecode(data) return HttpService:JSONDecode(data) end

local function lDigest(input) local hash = {} for i = 1, #input do table.insert(hash, string.byte(input, i)) end local hex = "" for _, byte in ipairs(hash) do hex = hex .. string.format("%02x", byte) end return hex end

local function onMessage(msg) StarterGui:SetCore("ChatMakeSystemMessage", { Text = "[KeySystem] " .. msg; Color = Color3.new(0.6, 1, 0.6) }) end

-- API Host Resolver local host = "https://api.platoboost.com" local test = fRequest({ Url = host .. "/public/connectivity", Method = "GET" }) if test.StatusCode ~= 200 then host = "https://api.platoboost.net" end

-- Clipboard Key Link Caching local cachedLink = "" local cachedTime = 0 local function cacheLink() if tick() > cachedTime + 600 then local res = fRequest({ Url = host .. "/public/start", Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = lEncode({ service = service, identifier = lDigest(fGetHwid()) }) }) if res.StatusCode == 200 then local data = lDecode(res.Body) if data.success then cachedLink = data.data.url cachedTime = tick() return true, cachedLink else onMessage(data.message) end else onMessage("Could not get link. Server error.") end else return true, cachedLink end return false, "" end

-- Nonce Generator local function generateNonce() local charset = "abcdefghijklmnopqrstuvwxyz" local result = "" for _ = 1, 16 do local rand = math.random(1, #charset) result = result .. charset:sub(rand, rand) end return result end

-- Key Functions local function copyKeyLink() local success, link = cacheLink() if success and fSetClipboard then fSetClipboard(link) onMessage("Copied key link to clipboard!") else onMessage("Failed to copy key link.") end end

local function verifyKey(key) local nonce = generateNonce() local url = host .. "/public/whitelist/" .. tostring(service) .. "?identifier=" .. lDigest(fGetHwid()) .. "&key=" .. key if useNonce then url = url .. "&nonce=" .. nonce end local res = fRequest({ Url = url, Method = "GET" }) if res.StatusCode == 200 then local data = lDecode(res.Body) return data.success and data.data.valid else onMessage("Verification failed.") return false end end

-- GUI Setup local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui")) local frame = Instance.new("Frame", gui) frame.Size = UDim2.fromOffset(360, 220) frame.Position = UDim2.new(0.5, -180, 0.5, -110) frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40) frame.BorderSizePixel = 0 frame.Name = "KeySystemUI"

local title = Instance.new("TextLabel", frame) title.Text = "🔑 Enter Key" title.Size = UDim2.new(1, 0, 0, 40) title.TextScaled = true title.BackgroundColor3 = Color3.fromRGB(20, 20, 20) title.TextColor3 = Color3.fromRGB(255, 255, 255) title.Font = Enum.Font.GothamBold

local input = Instance.new("TextBox", frame) input.PlaceholderText = "Paste your key here..." input.Size = UDim2.new(0.9, 0, 0, 40) input.Position = UDim2.new(0.05, 0, 0.25, 0) input.Font = Enum.Font.Gotham input.TextSize = 18 input.TextColor3 = Color3.new(1, 1, 1) input.BackgroundColor3 = Color3.fromRGB(60, 60, 60) input.ClearTextOnFocus = false

local copyBtn = Instance.new("TextButton", frame) copyBtn.Text = "📋 Get Key" copyBtn.Size = UDim2.new(0.4, 0, 0, 35) copyBtn.Position = UDim2.new(0.05, 0, 0.6, 0) copyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) copyBtn.TextColor3 = Color3.new(1, 1, 1) copyBtn.Font = Enum.Font.GothamSemibold

local checkBtn = Instance.new("TextButton", frame) checkBtn.Text = "✅ Check Key" checkBtn.Size = UDim2.new(0.5, 0, 0, 35) checkBtn.Position = UDim2.new(0.5, -5, 0.6, 0) checkBtn.BackgroundColor3 = Color3.fromRGB(35, 180, 70) checkBtn.TextColor3 = Color3.new(1, 1, 1) checkBtn.Font = Enum.Font.GothamSemibold

-- GUI Logic copyBtn.MouseButton1Click:Connect(copyKeyLink)

checkBtn.MouseButton1Click:Connect(function() local key = input.Text if key == "" then onMessage("Please enter a key.") return end if verifyKey(key) then onMessage("✅ Key Valid! Loading...") loadstring(game:HttpGet("https://raw.githubusercontent.com/LumeCraftors01/unknown-hub/refs/heads/main/Loaderv1.lua"))() else onMessage("❌ Invalid Key.") end end)

-- Optional Draggable Frame local dragging, dragInput, dragStart, startPos = false, nil, nil, nil frame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = input.Position startPos = frame.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end) frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end) game:GetService("UserInputService").InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

