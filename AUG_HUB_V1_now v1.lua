--========================================================
--              AUG HUB V1 • WITH FEATURES
--========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local genv = getgenv and getgenv() or _G

-- លុបម៉ឺនុយចាស់
local Old = PlayerGui:FindFirstChild("AUG_HUB_COMPLETE") or PlayerGui:FindFirstChild("MINH_KHA_HUB_COMPLETE")
if Old then Old:Destroy() end

--========================================================
-- Theme
--========================================================
local Theme = {
	BorderColor = Color3.fromRGB(220, 25, 45),
	GlassTransparency = 0.18,
	BorderThickness = 1.4,
	BorderTransparency = 0.08,
	UIScale = 1,
}

--========================================================
-- Config (ភ្ជាប់ទៅ senaV4Config បើមាន)
--========================================================
local Config = genv.SenaV4Config or genv.__SenaV4Config or {
	AutoSteal = false,
	GodMode = false,
	HelpFriend = false,
	LowSpeedBoost = true,
	StealMode = "Instant",
	StealHoldSeconds = 5,
	Noclip = false,
	InfiniteJump = false,
	AntiAFK = true,
	AutoReconnect = true,
	AutoPlace = false,
	AutoHatch = false,
	AutoSell = false,
	AutoSellEgg = false,
	AutoTreadmillIdle = false,
	AntiTreadmill = false,
	AntiHitGuard = false,
	AntiGuardKnockback = true,
	EggESP = false,
	BottingMode = false,
	AntiCutscene = false,
	TweenSpeedMultiplier = 60,
	StealPlayers = false,
}

genv.SenaV4Config = Config

--========================================================
-- Helpers
--========================================================
local function setConfig(key, value)
	Config[key] = value
	if genv.SenaV4Config then
		genv.SenaV4Config[key] = value
	end
end

local function notify(title, text)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = title or "AUG Hub",
			Text = text or "",
			Duration = 3,
		})
	end)
end

--========================================================
-- ScreenGui
--========================================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "AUG_HUB_COMPLETE"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 9999
Gui.Parent = PlayerGui

local function Corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 12)
	c.Parent = obj
	return c
end

local function Stroke(obj, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Name = "DynamicBorder"
	s.Color = color or Theme.BorderColor
	s.Thickness = thickness or Theme.BorderThickness
	s.Transparency = transparency or Theme.BorderTransparency
	s.Parent = obj
	return s
end

-- Main Window
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 440, 0, 360)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
Main.BackgroundTransparency = Theme.GlassTransparency
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Parent = Gui
Corner(Main, 16)
Stroke(Main)

local UIScaleObj = Instance.new("UIScale")
UIScaleObj.Scale = Theme.UIScale
UIScaleObj.Parent = Main

-- Top Bar
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 58)
Top.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
Top.BackgroundTransparency = 0.05
Top.BorderSizePixel = 0
Top.Parent = Main
Corner(Top, 16)

local Title = Instance.new("TextLabel")
Title.Position = UDim2.new(0, 18, 0, 8)
Title.Size = UDim2.new(1, -70, 0, 26)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(250, 250, 250)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "AUG HUB V1"
Title.Parent = Top

local Subtitle = Instance.new("TextLabel")
Subtitle.Position = UDim2.new(0, 18, 0, 33)
Subtitle.Size = UDim2.new(1, -70, 0, 16)
Subtitle.BackgroundTransparency = 1
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 11
Subtitle.TextColor3 = Color3.fromRGB(160, 160, 175)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Text = "STEAL AN EGG • DARK GLASS"
Subtitle.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 34, 0, 34)
Close.Position = UDim2.new(1, -44, 0, 12)
Close.BackgroundColor3 = Color3.fromRGB(110, 20, 30)
Close.BackgroundTransparency = 0.1
Close.BorderSizePixel = 0
Close.Font = Enum.Font.GothamBold
Close.TextSize = 20
Close.TextColor3 = Color3.fromRGB(250, 250, 250)
Close.Text = "×"
Close.Parent = Top
Corner(Close, 9)
Stroke(Close)
Close.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

-- Drag
local dragging, dragStart, startPos
Top.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- Body
local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Parent = Main
Body.Position = UDim2.new(0, 12, 0, 68)
Body.Size = UDim2.new(1, -24, 1, -80)
Body.BackgroundTransparency = 1

local Left = Instance.new("Frame")
Left.Name = "LeftMenu"
Left.Parent = Body
Left.Size = UDim2.new(0, 128, 1, 0)
Left.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Left.BackgroundTransparency = 0.1
Left.BorderSizePixel = 0
Corner(Left, 12)
Stroke(Left)

local MenuScroll = Instance.new("ScrollingFrame")
MenuScroll.Parent = Left
MenuScroll.Position = UDim2.new(0, 7, 0, 8)
MenuScroll.Size = UDim2.new(1, -14, 1, -16)
MenuScroll.BackgroundTransparency = 1
MenuScroll.BorderSizePixel = 0
MenuScroll.ScrollBarThickness = 2
MenuScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
MenuScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local MenuLayout = Instance.new("UIListLayout")
MenuLayout.Parent = MenuScroll
MenuLayout.Padding = UDim.new(0, 6)
MenuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Right = Instance.new("Frame")
Right.Name = "RightContent"
Right.Parent = Body
Right.Position = UDim2.new(0, 140, 0, 0)
Right.Size = UDim2.new(1, -140, 1, 0)
Right.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Right.BackgroundTransparency = 0.06
Right.BorderSizePixel = 0
Right.ClipsDescendants = true
Corner(Right, 12)
Stroke(Right)

local RightScroll = Instance.new("ScrollingFrame")
RightScroll.Parent = Right
RightScroll.Position = UDim2.new(0, 8, 0, 8)
RightScroll.Size = UDim2.new(1, -16, 1, -16)
RightScroll.BackgroundTransparency = 1
RightScroll.BorderSizePixel = 0
RightScroll.ScrollBarThickness = 3
RightScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
RightScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local RightLayout = Instance.new("UIListLayout")
RightLayout.Parent = RightScroll
RightLayout.Padding = UDim.new(0, 7)

--========================================================
-- Library
--========================================================
local Pages, Tabs, firstTab = {}, {}, true
local Library = {}

function Library:CreateTab(tabName)
	local page = Instance.new("Frame")
	page.Name = tabName
	page.Parent = RightScroll
	page.Size = UDim2.new(1, -4, 0, 0)
	page.AutomaticSize = Enum.AutomaticSize.Y
	page.BackgroundTransparency = 1
	page.Visible = false

	local layout = Instance.new("UIListLayout")
	layout.Parent = page
	layout.Padding = UDim.new(0, 7)

	Pages[tabName] = page

	local tabBtn = Instance.new("TextButton")
	tabBtn.Parent = MenuScroll
	tabBtn.Size = UDim2.new(1, -4, 0, 36)
	tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	tabBtn.BackgroundTransparency = 0.2
	tabBtn.BorderSizePixel = 0
	tabBtn.Text = tabName
	tabBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
	tabBtn.TextSize = 12
	tabBtn.Font = Enum.Font.GothamSemibold
	tabBtn.AutoButtonColor = false
	Corner(tabBtn, 9)
	Stroke(tabBtn)

	Tabs[tabName] = tabBtn

	tabBtn.MouseButton1Click:Connect(function()
		for pName, pObj in pairs(Pages) do
			pObj.Visible = (pName == tabName)
		end
		for tName, tObj in pairs(Tabs) do
			if tName == tabName then
				tObj.BackgroundColor3 = Theme.BorderColor
				tObj.BackgroundTransparency = 0.05
			else
				tObj.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
				tObj.BackgroundTransparency = 0.2
			end
		end
		RightScroll.CanvasPosition = Vector2.new(0, 0)
	end)

	if firstTab then
		firstTab = false
		page.Visible = true
		tabBtn.BackgroundColor3 = Theme.BorderColor
		tabBtn.BackgroundTransparency = 0.05
	end

	local TabFunctions = {}

	function TabFunctions:CreateButton(text, callback)
		local btn = Instance.new("TextButton")
		btn.Parent = page
		btn.Size = UDim2.new(1, -4, 0, 40)
		btn.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
		btn.BackgroundTransparency = 0.15
		btn.BorderSizePixel = 0
		btn.Text = text
		btn.TextColor3 = Color3.fromRGB(245, 245, 245)
		btn.TextSize = 13
		btn.Font = Enum.Font.GothamBold
		btn.AutoButtonColor = false
		Corner(btn, 10)
		Stroke(btn, Color3.fromRGB(55, 55, 65), 1, 0)
		btn.MouseButton1Click:Connect(function()
			pcall(callback)
		end)
	end

	function TabFunctions:CreateToggle(text, default, callback)
		local enabled = default
		local row = Instance.new("Frame")
		row.Parent = page
		row.Size = UDim2.new(1, -4, 0, 40)
		row.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
		row.BackgroundTransparency = 0.15
		row.BorderSizePixel = 0
		Corner(row, 10)
		Stroke(row, Color3.fromRGB(55, 55, 65), 1, 0)

		local label = Instance.new("TextLabel")
		label.Parent = row
		label.Size = UDim2.new(1, -55, 1, 0)
		label.Position = UDim2.new(0, 12, 0, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamSemibold
		label.TextSize = 13
		label.TextColor3 = Color3.fromRGB(245, 245, 245)
		label.TextXAlignment = Enum.TextXAlignment.Left

		local toggleBtn = Instance.new("TextButton")
		toggleBtn.Parent = row
		toggleBtn.Size = UDim2.new(0, 36, 0, 20)
		toggleBtn.Position = UDim2.new(1, -44, 0.5, -10)
		toggleBtn.Text = ""
		toggleBtn.BorderSizePixel = 0
		Corner(toggleBtn, 10)

		local function update()
			label.Text = text .. "  [" .. (enabled and "ON" or "OFF") .. "]"
			toggleBtn.BackgroundColor3 = enabled and Theme.BorderColor or Color3.fromRGB(40, 40, 48)
			pcall(function() callback(enabled) end)
		end

		toggleBtn.MouseButton1Click:Connect(function()
			enabled = not enabled
			update()
		end)
		update()
	end

	function TabFunctions:CreateInput(text, default, callback)
		local holder = Instance.new("Frame")
		holder.Parent = page
		holder.Size = UDim2.new(1, -4, 0, 42)
		holder.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
		holder.BackgroundTransparency = 0.15
		holder.BorderSizePixel = 0
		Corner(holder, 10)
		Stroke(holder, Color3.fromRGB(55, 55, 65), 1, 0)

		local label = Instance.new("TextLabel")
		label.Parent = holder
		label.Size = UDim2.new(0.38, 0, 1, 0)
		label.Position = UDim2.new(0, 12, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = Color3.fromRGB(245, 245, 245)
		label.TextSize = 13
		label.Font = Enum.Font.GothamBold
		label.TextXAlignment = Enum.TextXAlignment.Left

		local box = Instance.new("TextBox")
		box.Parent = holder
		box.Position = UDim2.new(0.42, 0, 0.15, 0)
		box.Size = UDim2.new(0.54, 0, 0.7, 0)
		box.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
		box.BorderSizePixel = 0
		box.Text = tostring(default)
		box.TextColor3 = Color3.fromRGB(245, 245, 245)
		box.TextSize = 13
		box.Font = Enum.Font.Gotham
		box.ClearTextOnFocus = false
		Corner(box, 7)

		box.FocusLost:Connect(function()
			local value = tonumber(box.Text)
			if value then
				pcall(function() callback(value) end)
			else
				pcall(function() callback(box.Text) end)
			end
		end)
	end

	function TabFunctions:CreateLabel(text)
		local label = Instance.new("TextLabel")
		label.Parent = page
		label.Size = UDim2.new(1, -4, 0, 28)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Gotham
		label.TextSize = 12
		label.TextColor3 = Color3.fromRGB(160, 160, 175)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Text = text
		label.TextWrapped = true
	end

	return TabFunctions
end

-- Floating AG button
local AG = Instance.new("TextButton")
AG.Size = UDim2.new(0, 56, 0, 56)
AG.Position = UDim2.new(0, 16, 0.5, -28)
AG.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
AG.BackgroundTransparency = 0.1
AG.BorderSizePixel = 0
AG.Font = Enum.Font.GothamBlack
AG.TextSize = 18
AG.TextColor3 = Theme.BorderColor
AG.Text = "AG"
AG.AutoButtonColor = false
AG.Parent = Gui
Corner(AG, 14)
Stroke(AG)

local agDragging, agDragStart, agStartPos, agMoved = false, nil, nil, false
AG.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		agDragging = true
		agMoved = false
		agDragStart = input.Position
		agStartPos = AG.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if agDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - agDragStart
		if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
			agMoved = true
		end
		AG.Position = UDim2.new(agStartPos.X.Scale, agStartPos.X.Offset + delta.X, agStartPos.Y.Scale, agStartPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		agDragging = false
	end
end)
AG.MouseButton1Click:Connect(function()
	if agMoved then agMoved = false return end
	Main.Visible = not Main.Visible
end)

--========================================================
-- FEATURES (ភ្ជាប់ទៅ backend)
--========================================================

-- STEAL TAB
local Steal = Library:CreateTab("Steal")
Steal:CreateLabel("Auto Steal & Combat")

Steal:CreateToggle("Auto Steal", Config.AutoSteal, function(v)
	setConfig("AutoSteal", v)
	local rt = genv.__SenaV4EggRuntime
	if rt and type(rt.setEnabled) == "function" then
		pcall(rt.setEnabled, rt, v)
	end
	notify("Auto Steal", v and "ON" or "OFF")
end)

Steal:CreateToggle("Aura Bat (God Mode)", Config.GodMode, function(v)
	setConfig("GodMode", v)
	notify("Aura Bat", v and "ON" or "OFF")
end)

Steal:CreateToggle("Help Friend", Config.HelpFriend, function(v)
	setConfig("HelpFriend", v)
end)

Steal:CreateToggle("Boost Instant Steal", Config.LowSpeedBoost, function(v)
	setConfig("LowSpeedBoost", v)
end)

Steal:CreateToggle("Steal From Players", Config.StealPlayers, function(v)
	setConfig("StealPlayers", v)
	local ps = genv.__SenaV4PlayerSteal
	if ps and type(ps.setEnabled) == "function" then
		pcall(ps.setEnabled, ps, v)
	end
end)

Steal:CreateToggle("Egg ESP", Config.EggESP, function(v)
	setConfig("EggESP", v)
end)

Steal:CreateInput("Steal Multiplier", Config.StealHoldSeconds or 5, function(v)
	setConfig("StealHoldSeconds", tonumber(v) or 5)
end)

Steal:CreateInput("Tween Speed", Config.TweenSpeedMultiplier or 60, function(v)
	setConfig("TweenSpeedMultiplier", math.clamp(tonumber(v) or 60, 20, 100))
end)

-- FARM TAB
local Farm = Library:CreateTab("Farm")
Farm:CreateLabel("Place • Hatch • Sell • Treadmill")

Farm:CreateToggle("Auto Place Egg", Config.AutoPlace, function(v)
	setConfig("AutoPlace", v)
end)

Farm:CreateToggle("Auto Hatch Egg", Config.AutoHatch, function(v)
	setConfig("AutoHatch", v)
end)

Farm:CreateToggle("Auto Sell Pet", Config.AutoSell, function(v)
	setConfig("AutoSell", v)
end)

Farm:CreateToggle("Auto Sell Egg", Config.AutoSellEgg, function(v)
	setConfig("AutoSellEgg", v)
end)

Farm:CreateToggle("Auto Treadmill", Config.AutoTreadmillIdle, function(v)
	setConfig("AutoTreadmillIdle", v)
end)

Farm:CreateToggle("Anti Treadmill", Config.AntiTreadmill, function(v)
	setConfig("AntiTreadmill", v)
end)

-- MOVEMENT TAB
local Move = Library:CreateTab("Movement")
Move:CreateLabel("Noclip • Jump • Guard")

Move:CreateToggle("Noclip", Config.Noclip, function(v)
	setConfig("Noclip", v)
	-- Simple noclip
	local char = Player.Character
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = not v
			end
		end
	end
end)

Move:CreateToggle("Infinite Jump", Config.InfiniteJump, function(v)
	setConfig("InfiniteJump", v)
end)

Move:CreateToggle("Anti Guard Knockback", Config.AntiGuardKnockback, function(v)
	setConfig("AntiGuardKnockback", v)
end)

Move:CreateToggle("Anti Hit Guard", Config.AntiHitGuard, function(v)
	setConfig("AntiHitGuard", v)
	local ag = genv.__SenaV4AntiHitGuard
	if ag and type(ag.setEnabled) == "function" then
		pcall(ag.setEnabled, ag, v)
	end
end)

-- Infinite Jump logic
UserInputService.JumpRequest:Connect(function()
	if not Config.InfiniteJump then return end
	local char = Player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Noclip loop
RunService.Stepped:Connect(function()
	if not Config.Noclip then return end
	local char = Player.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end)

-- SERVER TAB
local Server = Library:CreateTab("Server")
Server:CreateLabel("Session")

Server:CreateButton("Rejoin This Server", function()
	pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
	end)
end)

-- SETTINGS TAB
local Settings = Library:CreateTab("Settings")
Settings:CreateLabel("Session & Safety")

Settings:CreateToggle("Anti AFK", Config.AntiAFK, function(v)
	setConfig("AntiAFK", v)
	genv.__SenaV4AntiAfkEnabled = v
	if type(genv.__SenaV4SetAntiAfkEnabled) == "function" then
		pcall(genv.__SenaV4SetAntiAfkEnabled, v)
	end
end)

Settings:CreateToggle("Auto Reconnect", Config.AutoReconnect, function(v)
	setConfig("AutoReconnect", v)
end)

Settings:CreateToggle("Botting Mode (Black Screen)", Config.BottingMode, function(v)
	setConfig("BottingMode", v)
	-- Simple black overlay
	local existing = PlayerGui:FindFirstChild("AUG_BotOverlay")
	if existing then existing:Destroy() end
	if v then
		local overlay = Instance.new("ScreenGui")
		overlay.Name = "AUG_BotOverlay"
		overlay.DisplayOrder = 99999
		overlay.IgnoreGuiInset = true
		overlay.Parent = PlayerGui
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, 0, 1, 0)
		f.BackgroundColor3 = Color3.new(0, 0, 0)
		f.BorderSizePixel = 0
		f.Parent = overlay
	end
end)

Settings:CreateToggle("Anti Cutscene", Config.AntiCutscene, function(v)
	setConfig("AntiCutscene", v)
end)

Settings:CreateButton("Stop & Unload Hub", function()
	setConfig("AutoSteal", false)
	setConfig("AutoPlace", false)
	setConfig("AutoHatch", false)
	setConfig("AutoSell", false)
	setConfig("Noclip", false)
	setConfig("BottingMode", false)
	local existing = PlayerGui:FindFirstChild("AUG_BotOverlay")
	if existing then existing:Destroy() end
	if type(genv.__SenaV4HubShutdown) == "function" then
		pcall(genv.__SenaV4HubShutdown)
	end
	Gui:Destroy()
	notify("AUG Hub", "Unloaded")
end)

-- INFO TAB
local Info = Library:CreateTab("Info")
Info:CreateLabel("AUG Hub V1 • Steal An Egg")
Info:CreateLabel("Toggle AG button to show/hide menu")
Info:CreateLabel("Drag top bar to move window")
Info:CreateButton("Copy Discord (placeholder)", function()
	pcall(setclipboard, "https://discord.gg/yourserver")
	notify("AUG Hub", "Copied!")
end)

print("AUG HUB V1 • FEATURES READY!")
