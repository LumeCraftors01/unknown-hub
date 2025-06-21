local Players = game:GetService("Players")
local player = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

-- Services & Keys
local service = 4599
local secret = "32cb930f-f6cb-45ea-ad13-aefd18307edc"
local useNonce = true

local fClipboard = setclipboard or toclipboard
local fRequest = request or http_request
local fGetHwid = gethwid or function() return tostring(player.UserId) end

local function lDigest(s)
	local h = {}
	for i = 1, #s do table.insert(h, ('%02x'):format(s:byte(i))) end
	return table.concat(h)
end

local function jEncode(t) return HttpService:JSONEncode(t) end
local function jDecode(t) return HttpService:JSONDecode(t) end

-- Notifications
local function onMessage(msg)
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "[KeySystem] " .. msg,
		Color = Color3.fromRGB(0, 255, 150)
	})
end

-- Host Detection
local host = "https://api.platoboost.com"
local test = fRequest({ Url = host .. "/public/connectivity", Method = "GET" })
if not test or test.StatusCode ~= 200 then
	host = "https://api.platoboost.net"
end

local cache, lastFetch = "", 0
function fetchLink()
	if tick() > lastFetch + 600 then
		local res = fRequest({
			Url = host .. "/public/start",
			Method = "POST",
			Body = jEncode({ service = service, identifier = lDigest(fGetHwid()) }),
			Headers = { ["Content-Type"] = "application/json" }
		})
		if res and res.StatusCode == 200 then
			local d = jDecode(res.Body)
			if d.success then
				cache = d.data.url
				lastFetch = tick()
				return true, cache
			else
				onMessage(d.message)
			end
		else
			onMessage("Error connecting to server.")
		end
	else
		return true, cache
	end
	return false, nil
end

function copyLink()
	local ok, link = fetchLink()
	if ok then
		fClipboard(link)
		onMessage("✅ Key link copied!")
	end
end

function verifyKey(key)
	local nonce = useNonce and lDigest(tostring(math.random())) or nil
	local url = host .. "/public/whitelist/" .. service ..
		"?identifier=" .. lDigest(fGetHwid()) .. "&key=" .. key ..
		(nonce and "&nonce=" .. nonce or "")
	local res = fRequest({ Url = url, Method = "GET" })
	if res and res.StatusCode == 200 then
		local d = jDecode(res.Body)
		return d.success and d.data.valid
	else
		onMessage("❌ Invalid key or server error.")
	end
	return false
end

-- GUI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "KeySystemGui"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 360, 0, 230)
frame.Position = UDim2.new(0.5, -180, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(255, 255, 255)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🔐 Key System"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1

local input = Instance.new("TextBox", frame)
input.PlaceholderText = "Enter key here..."
input.Size = UDim2.new(0.9, 0, 0, 40)
input.Position = UDim2.new(0.05, 0, 0.28, 0)
input.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
input.TextColor3 = Color3.new(1, 1, 1)
input.Font = Enum.Font.Gotham
input.ClearTextOnFocus = false
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)

local copyBtn = Instance.new("TextButton", frame)
copyBtn.Text = "📋 Get Key"
copyBtn.Size = UDim2.new(0.4, 0, 0, 35)
copyBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
copyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
copyBtn.Font = Enum.Font.GothamMedium
copyBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 8)

local checkBtn = Instance.new("TextButton", frame)
checkBtn.Text = "✅ Check Key"
checkBtn.Size = UDim2.new(0.5, 0, 0, 35)
checkBtn.Position = UDim2.new(0.5, -5, 0.65, 0)
checkBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
checkBtn.Font = Enum.Font.GothamBold
checkBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", checkBtn).CornerRadius = UDim.new(0, 8)

local loading = Instance.new("TextLabel", frame)
loading.Size = UDim2.new(1, 0, 0, 25)
loading.Position = UDim2.new(0, 0, 0.9, 0)
loading.Text = ""
loading.Font = Enum.Font.Gotham
loading.TextColor3 = Color3.fromRGB(200, 200, 255)
loading.BackgroundTransparency = 1

-- Spinner
local spinnerRunning = false
local function startSpinner()
	spinnerRunning = true
	coroutine.wrap(function()
		local phases = { "|", "/", "—", "\\" }
		local i = 1
		while spinnerRunning do
			loading.Text = "🔄 Verifying... " .. phases[i]
			i = (i % #phases) + 1
			task.wait(0.15)
		end
		loading.Text = ""
	end)()
end

-- Save & Load Key (LocalStorage)
pcall(function()
	local saved = getgenv().SavedKey or nil
	if saved then input.Text = saved end
end)

-- Actions
copyBtn.MouseButton1Click:Connect(copyLink)

checkBtn.MouseButton1Click:Connect(function()
	local key = input.Text
	if key == "" then return onMessage("Please enter a key.") end

	startSpinner()
	local success = verifyKey(key)
	spinnerRunning = false

	if success then
		getgenv().SavedKey = key
		onMessage("✅ Key Verified! Loading...")
		task.wait(0.5)
		loadstring(game:HttpGet("https://raw.githubusercontent.com/LumeCraftors01/unknown-hub/main/Loaderv1.lua"))()
	else
		onMessage("❌ Invalid key.")
	end
end)
