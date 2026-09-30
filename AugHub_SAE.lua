--==================================================
-- AUG HUB SAE
-- Key System + Anti-Hit + Anti-Trap + Instant Steal
-- Bat Aura + Hop + FPS/MS Overlay
-- Clean Modern UI
--==================================================

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SetClipboard = setclipboard or toclipboard or function() end

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- SETTINGS
--==================================================

local LogoId = "rbxassetid://YOUR_IMAGE_ASSET_ID"
local targetParent = (gethui and gethui()) or PlayerGui
local CORRECT_KEY = "AUG-47731"
local GET_KEY_URL = "https://bstshrt.com/u/aug3gf"
local KEY_FILE = "AugHub_Key.txt"

--==================================================
-- THEME (Clean Modern)
--==================================================

local Theme = {
    Background     = Color3.fromRGB(18, 18, 24),
    Surface        = Color3.fromRGB(28, 28, 36),
    SurfaceLight   = Color3.fromRGB(38, 38, 48),
    Accent         = Color3.fromRGB(130, 90, 255),      -- Soft purple
    AccentDark     = Color3.fromRGB(90, 60, 190),
    Success        = Color3.fromRGB(70, 200, 140),
    Danger         = Color3.fromRGB(230, 70, 90),
    Text           = Color3.fromRGB(245, 245, 250),
    TextDim        = Color3.fromRGB(160, 160, 180),
    Border         = Color3.fromRGB(55, 55, 70),
    Off            = Color3.fromRGB(45, 45, 58),
}

--==================================================
-- REMOVE OLD GUI
--==================================================

local oldGui = targetParent:FindFirstChild("AugHubGui")
if oldGui then
    oldGui:Destroy()
end

--==================================================
-- STATE
--==================================================

local AntiHitEnabled = false
local AntiTrapEnabled = false
local InstantStealEnabled = false
local BatAuraEnabled = false
local IsTeleporting = false
local IsMinimized = false
local CurrentScale = 1
local CurrentBackground = "Dark"

local escapeCount = 0
local isTrapped = false
local savedJumpHeight = 7.2

local touchSave = {
    saved = {},
    char = nil,
    at = 0,
}

--==================================================
-- SCREEN GUI
--==================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AugHubGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = targetParent

--==================================================
-- HELPER: Create rounded button
--==================================================

local function createButton(parent, text, size, position, bgColor)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = position
    btn.BackgroundColor3 = bgColor or Theme.Off
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.ZIndex = 12
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = btn

    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.new(
                math.min(btn.BackgroundColor3.R * 1.15, 1),
                math.min(btn.BackgroundColor3.G * 1.15, 1),
                math.min(btn.BackgroundColor3.B * 1.15, 1)
            )
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = bgColor or Theme.Off
        }):Play()
    end)

    return btn
end

--==================================================
-- FPS + MS DISPLAY
--==================================================

local fpsFrame = Instance.new("Frame")
fpsFrame.Name = "FpsMsDisplay"
fpsFrame.Size = UDim2.fromOffset(148, 32)
fpsFrame.Position = UDim2.new(0.5, -74, 0, 12)
fpsFrame.BackgroundColor3 = Theme.Background
fpsFrame.BackgroundTransparency = 0.15
fpsFrame.BorderSizePixel = 0
fpsFrame.ZIndex = 100
fpsFrame.Parent = screenGui

local fpsCorner = Instance.new("UICorner")
fpsCorner.CornerRadius = UDim.new(0, 10)
fpsCorner.Parent = fpsFrame

local fpsStroke = Instance.new("UIStroke")
fpsStroke.Color = Theme.Border
fpsStroke.Thickness = 1.2
fpsStroke.Transparency = 0.35
fpsStroke.Parent = fpsFrame

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FpsLabel"
fpsLabel.Size = UDim2.new(0.5, -6, 1, 0)
fpsLabel.Position = UDim2.fromOffset(10, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "-- FPS"
fpsLabel.TextColor3 = Theme.Text
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 13
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.ZIndex = 101
fpsLabel.Parent = fpsFrame

local msLabel = Instance.new("TextLabel")
msLabel.Name = "MsLabel"
msLabel.Size = UDim2.new(0.5, -6, 1, 0)
msLabel.Position = UDim2.new(0.5, 0, 0, 0)
msLabel.BackgroundTransparency = 1
msLabel.Text = "-- ms"
msLabel.TextColor3 = Theme.Danger
msLabel.Font = Enum.Font.GothamBold
msLabel.TextSize = 13
msLabel.TextXAlignment = Enum.TextXAlignment.Right
msLabel.ZIndex = 101
msLabel.Parent = fpsFrame

-- FPS
local frames = 0
local lastTime = tick()

RunService.RenderStepped:Connect(function()
    frames = frames + 1
    local now = tick()
    if now - lastTime >= 0.5 then
        local fps = math.floor(frames / (now - lastTime) + 0.5)
        frames = 0
        lastTime = now

        fpsLabel.Text = fps .. " FPS"
        if fps >= 55 then
            fpsLabel.TextColor3 = Theme.Success
        elseif fps >= 30 then
            fpsLabel.TextColor3 = Color3.fromRGB(255, 210, 70)
        else
            fpsLabel.TextColor3 = Theme.Danger
        end
    end
end)

-- Ping
local function getPing()
    local ok, val = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ok and type(val) == "number" and val > 0 then
        return math.floor(val + 0.5)
    end

    ok, val = pcall(function()
        return LocalPlayer:GetNetworkPing() * 1000
    end)
    if ok and type(val) == "number" and val > 0 then
        return math.floor(val + 0.5)
    end

    ok, val = pcall(function()
        local net = Stats:FindFirstChild("Network")
        if not net then return nil end
        local item = net:FindFirstChild("ServerStatsItem")
        if not item then return nil end
        local data = item:FindFirstChild("Data Ping")
        if data then return data:GetValue() end
        return nil
    end)
    if ok and type(val) == "number" and val > 0 then
        return math.floor(val + 0.5)
    end

    return 0
end

task.spawn(function()
    while true do
        task.wait(0.4)
        local ping = getPing()
        msLabel.Text = ping .. " ms"

        if ping == 0 then
            msLabel.TextColor3 = Theme.TextDim
        elseif ping <= 70 then
            msLabel.TextColor3 = Theme.Success
        elseif ping <= 140 then
            msLabel.TextColor3 = Color3.fromRGB(255, 210, 70)
        else
            msLabel.TextColor3 = Theme.Danger
        end
    end
end)

--==================================================
-- KEY SYSTEM FRAME
--==================================================

local keyFrame = Instance.new("Frame")
keyFrame.Name = "KeyFrame"
keyFrame.Size = UDim2.fromOffset(280, 210)
keyFrame.Position = UDim2.new(0.5, -140, 0.5, -105)
keyFrame.BackgroundColor3 = Theme.Background
keyFrame.BorderSizePixel = 0
keyFrame.Active = true
keyFrame.Draggable = true
keyFrame.ZIndex = 20
keyFrame.Visible = true
keyFrame.Parent = screenGui

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 14)
keyCorner.Parent = keyFrame

local keyStroke = Instance.new("UIStroke")
keyStroke.Color = Theme.Accent
keyStroke.Thickness = 1.5
keyStroke.Transparency = 0.3
keyStroke.Parent = keyFrame

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, -50, 0, 42)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "AUG HUB"
keyTitle.TextColor3 = Theme.Text
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 16
keyTitle.ZIndex = 21
keyTitle.Parent = keyFrame

local keySub = Instance.new("TextLabel")
keySub.Size = UDim2.new(1, -50, 0, 18)
keySub.Position = UDim2.fromOffset(0, 28)
keySub.BackgroundTransparency = 1
keySub.Text = "Enter your key to continue"
keySub.TextColor3 = Theme.TextDim
keySub.Font = Enum.Font.Gotham
keySub.TextSize = 11
keySub.ZIndex = 21
keySub.Parent = keyFrame

local keyCloseBtn = Instance.new("TextButton")
keyCloseBtn.Size = UDim2.fromOffset(28, 28)
keyCloseBtn.Position = UDim2.new(1, -36, 0, 10)
keyCloseBtn.BackgroundColor3 = Theme.Surface
keyCloseBtn.Text = "×"
keyCloseBtn.TextColor3 = Theme.Text
keyCloseBtn.Font = Enum.Font.GothamBold
keyCloseBtn.TextSize = 18
keyCloseBtn.ZIndex = 22
keyCloseBtn.AutoButtonColor = false
keyCloseBtn.Parent = keyFrame

local keyCloseCorner = Instance.new("UICorner")
keyCloseCorner.CornerRadius = UDim.new(0, 8)
keyCloseCorner.Parent = keyCloseBtn

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -32, 0, 36)
keyBox.Position = UDim2.fromOffset(16, 58)
keyBox.BackgroundColor3 = Theme.Surface
keyBox.PlaceholderText = "Paste key here..."
keyBox.Text = ""
keyBox.TextColor3 = Theme.Text
keyBox.PlaceholderColor3 = Theme.TextDim
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 13
keyBox.ClearTextOnFocus = false
keyBox.ZIndex = 21
keyBox.Parent = keyFrame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 8)
boxCorner.Parent = keyBox

local boxStroke = Instance.new("UIStroke")
boxStroke.Color = Theme.Border
boxStroke.Thickness = 1
boxStroke.Parent = keyBox

local submitBtn = createButton(keyFrame, "SUBMIT", UDim2.new(1, -32, 0, 34), UDim2.fromOffset(16, 104), Theme.Accent)
submitBtn.TextSize = 13

local getKeyBtn = createButton(keyFrame, "GET KEY", UDim2.new(1, -32, 0, 34), UDim2.fromOffset(16, 146), Theme.Surface)
getKeyBtn.TextSize = 12
getKeyBtn.TextColor3 = Theme.TextDim

--==================================================
-- MAIN FRAME
--==================================================

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.fromOffset(250, 400)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
mainFrame.BackgroundColor3 = Theme.Background
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ZIndex = 10
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Theme.Accent
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.35
mainStroke.Parent = mainFrame

--==================================================
-- HEADER
--==================================================

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = Theme.Surface
header.BorderSizePixel = 0
header.ZIndex = 11
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

-- Cover bottom corners of header
local headerCover = Instance.new("Frame")
headerCover.Size = UDim2.new(1, 0, 0, 14)
headerCover.Position = UDim2.new(0, 0, 1, -14)
headerCover.BackgroundColor3 = Theme.Surface
headerCover.BorderSizePixel = 0
headerCover.ZIndex = 11
headerCover.Parent = header

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.fromOffset(26, 26)
logo.Position = UDim2.fromOffset(10, 8)
logo.BackgroundTransparency = 1
logo.Image = LogoId
logo.ZIndex = 12
logo.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.fromOffset(42, 0)
title.BackgroundTransparency = 1
title.Text = "AUG HUB"
title.TextColor3 = Theme.Text
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 12
title.Parent = header

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.fromOffset(28, 28)
minimizeButton.Position = UDim2.new(1, -68, 0, 7)
minimizeButton.BackgroundColor3 = Theme.SurfaceLight
minimizeButton.Text = "−"
minimizeButton.TextColor3 = Theme.Text
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 16
minimizeButton.ZIndex = 13
minimizeButton.AutoButtonColor = false
minimizeButton.Parent = header

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 8)
minimizeCorner.Parent = minimizeButton

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(28, 28)
closeButton.Position = UDim2.new(1, -34, 0, 7)
closeButton.BackgroundColor3 = Theme.Danger
closeButton.Text = "×"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.ZIndex = 13
closeButton.AutoButtonColor = false
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

--==================================================
-- TABS
--==================================================

local mainTab = Instance.new("TextButton")
mainTab.Size = UDim2.fromOffset(110, 28)
mainTab.Position = UDim2.fromOffset(12, 50)
mainTab.BackgroundColor3 = Theme.Accent
mainTab.Text = "MAIN"
mainTab.TextColor3 = Color3.new(1, 1, 1)
mainTab.Font = Enum.Font.GothamBold
mainTab.TextSize = 11
mainTab.ZIndex = 12
mainTab.AutoButtonColor = false
mainTab.Parent = mainFrame

local mainTabCorner = Instance.new("UICorner")
mainTabCorner.CornerRadius = UDim.new(0, 8)
mainTabCorner.Parent = mainTab

local miscTab = Instance.new("TextButton")
miscTab.Size = UDim2.fromOffset(110, 28)
miscTab.Position = UDim2.fromOffset(128, 50)
miscTab.BackgroundColor3 = Theme.Surface
miscTab.Text = "MISC"
miscTab.TextColor3 = Theme.TextDim
miscTab.Font = Enum.Font.GothamBold
miscTab.TextSize = 11
miscTab.ZIndex = 12
miscTab.AutoButtonColor = false
miscTab.Parent = mainFrame

local miscTabCorner = Instance.new("UICorner")
miscTabCorner.CornerRadius = UDim.new(0, 8)
miscTabCorner.Parent = miscTab

--==================================================
-- CONTENT
--==================================================

local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, -24, 1, -90)
mainContent.Position = UDim2.fromOffset(12, 88)
mainContent.BackgroundTransparency = 1
mainContent.ZIndex = 11
mainContent.Parent = mainFrame

local miscContent = Instance.new("Frame")
miscContent.Size = UDim2.new(1, -24, 1, -90)
miscContent.Position = UDim2.fromOffset(12, 88)
miscContent.BackgroundTransparency = 1
miscContent.Visible = false
miscContent.ZIndex = 11
miscContent.Parent = mainFrame

--==================================================
-- MAIN FEATURE BUTTONS
--==================================================

local function makeToggle(parent, text, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.fromOffset(0, y)
    btn.BackgroundColor3 = Theme.Off
    btn.Text = text .. "  :  OFF"
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.ZIndex = 12
    btn.AutoButtonColor = false
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = btn

    return btn
end

local antiHitBtn = makeToggle(mainContent, "🛡  Anti-Hit", 0)
local antiTrapBtn = makeToggle(mainContent, "🔓  Anti-Trap", 48)
local instantStealBtn = makeToggle(mainContent, "⚡  Instant Steal", 96)
local batAuraBtn = makeToggle(mainContent, "🏏  Bat Aura", 144)

local function setToggle(btn, on, label)
    if on then
        btn.Text = label .. "  :  ON"
        btn.BackgroundColor3 = Theme.Accent
        btn.TextColor3 = Color3.new(1, 1, 1)
    else
        btn.Text = label .. "  :  OFF"
        btn.BackgroundColor3 = Theme.Off
        btn.TextColor3 = Theme.Text
    end
end

--==================================================
-- MISC SETTINGS
--==================================================

local bgTitle = Instance.new("TextLabel")
bgTitle.Size = UDim2.new(1, 0, 0, 22)
bgTitle.BackgroundTransparency = 1
bgTitle.Text = "Background"
bgTitle.TextColor3 = Theme.TextDim
bgTitle.Font = Enum.Font.GothamBold
bgTitle.TextSize = 11
bgTitle.TextXAlignment = Enum.TextXAlignment.Left
bgTitle.ZIndex = 12
bgTitle.Parent = miscContent

local bgButton = createButton(miscContent, "Dark", UDim2.new(1, 0, 0, 34), UDim2.fromOffset(0, 24), Theme.Surface)
bgButton.TextSize = 12

local scaleTitle = Instance.new("TextLabel")
scaleTitle.Size = UDim2.new(1, 0, 0, 22)
scaleTitle.Position = UDim2.fromOffset(0, 68)
scaleTitle.BackgroundTransparency = 1
scaleTitle.Text = "GUI Scale"
scaleTitle.TextColor3 = Theme.TextDim
scaleTitle.Font = Enum.Font.GothamBold
scaleTitle.TextSize = 11
scaleTitle.TextXAlignment = Enum.TextXAlignment.Left
scaleTitle.ZIndex = 12
scaleTitle.Parent = miscContent

local scaleButton = createButton(miscContent, "Scale: 100%", UDim2.new(1, 0, 0, 34), UDim2.fromOffset(0, 92), Theme.Surface)
scaleButton.TextSize = 12

local HopSkipFull = true

local hopSkipFullBtn = createButton(miscContent, "⛔  Skip Full : ON", UDim2.new(1, 0, 0, 34), UDim2.fromOffset(0, 140), Theme.Accent)
hopSkipFullBtn.TextSize = 12

local hopNowBtn = createButton(miscContent, "🚀  Hop Now", UDim2.new(1, 0, 0, 34), UDim2.fromOffset(0, 182), Theme.Surface)
hopNowBtn.TextSize = 12

local scaleObject = Instance.new("UIScale")
scaleObject.Scale = 1
scaleObject.Parent = mainFrame

local function setScale(value)
    CurrentScale = value
    scaleObject.Scale = value
    scaleButton.Text = "Scale: " .. math.floor(value * 100) .. "%"
end

scaleButton.Activated:Connect(function()
    if CurrentScale == 1 then
        setScale(0.85)
    elseif CurrentScale == 0.85 then
        setScale(0.75)
    elseif CurrentScale == 0.75 then
        setScale(1.15)
    else
        setScale(1)
    end
end)

bgButton.Activated:Connect(function()
    if CurrentBackground == "Dark" then
        CurrentBackground = "Purple"
        mainFrame.BackgroundColor3 = Color3.fromRGB(22, 18, 32)
        Theme.Background = Color3.fromRGB(22, 18, 32)
        bgButton.Text = "Purple"
    else
        CurrentBackground = "Dark"
        mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        Theme.Background = Color3.fromRGB(18, 18, 24)
        bgButton.Text = "Dark"
    end
end)

hopSkipFullBtn.Activated:Connect(function()
    HopSkipFull = not HopSkipFull
    if HopSkipFull then
        hopSkipFullBtn.Text = "⛔  Skip Full : ON"
        hopSkipFullBtn.BackgroundColor3 = Theme.Accent
    else
        hopSkipFullBtn.Text = "⛔  Skip Full : OFF"
        hopSkipFullBtn.BackgroundColor3 = Theme.Off
    end
end)

--==================================================
-- HOP NOW LOGIC
--==================================================

local PlaceId = game.PlaceId
local HopInProgress = false

local function hopFetch(url)
    local reqs = {}
    if syn and syn.request then table.insert(reqs, syn.request) end
    if http_request then table.insert(reqs, http_request) end
    if request then table.insert(reqs, request) end
    if http and http.request then table.insert(reqs, http.request) end
    if fluxus and fluxus.request then table.insert(reqs, fluxus.request) end

    for _, req in ipairs(reqs) do
        local ok, res = pcall(req, {
            Url = url,
            Method = "GET",
            Headers = { ["Accept"] = "application/json" },
        })
        if ok and type(res) == "table" then
            local code = tonumber(res.StatusCode or res.status_code or res.Status) or 0
            local body = res.Body or res.body
            if code == 200 and type(body) == "string" and #body > 10 then
                return body
            end
        end
    end

    if type(game.HttpGet) == "function" then
        local ok, body = pcall(function() return game:HttpGet(url) end)
        if ok and type(body) == "string" and #body > 10 then
            return body
        end
    end
    return nil
end

local function hopNow()
    if HopInProgress then return end
    HopInProgress = true
    hopNowBtn.Text = "🚀  Hopping..."
    hopNowBtn.BackgroundColor3 = Theme.Accent

    task.spawn(function()
        local ok, err = pcall(function()
            local candidates = {}
            local cursor = nil

            for page = 1, 5 do
                local url = "https://games.roblox.com/v1/games/" .. tostring(PlaceId)
                    .. "/servers/Public?sortOrder=Asc&limit=100"
                    .. (cursor and ("&cursor=" .. HttpService:UrlEncode(tostring(cursor))) or "")

                local body = hopFetch(url)
                if not body then break end

                local decodeOk, data = pcall(function()
                    return HttpService:JSONDecode(body)
                end)
                if not decodeOk or type(data) ~= "table" or type(data.data) ~= "table" then break end

                for _, server in ipairs(data.data) do
                    if type(server) == "table"
                        and type(server.id) == "string"
                        and server.id ~= game.JobId
                    then
                        local playing = tonumber(server.playing) or 0
                        local maxP = tonumber(server.maxPlayers) or 999
                        if not HopSkipFull or playing < maxP then
                            candidates[#candidates + 1] = {
                                id = server.id,
                                playing = playing,
                            }
                        end
                    end
                end

                cursor = data.nextPageCursor
                if type(cursor) ~= "string" or cursor == "" then break end
                task.wait(0.12)
            end

            if #candidates == 0 then
                hopNowBtn.Text = "🚀  No servers"
                task.wait(1.5)
                hopNowBtn.Text = "🚀  Hop Now"
                hopNowBtn.BackgroundColor3 = Theme.Surface
                HopInProgress = false
                return
            end

            table.sort(candidates, function(a, b)
                if (a.playing == 1) ~= (b.playing == 1) then
                    return a.playing == 1
                end
                return a.playing < b.playing
            end)

            hopNowBtn.Text = "🚀  " .. candidates[1].playing .. "p..."

            for i = 1, math.min(#candidates, 12) do
                local target = candidates[i]
                local before = tostring(game.JobId)

                local tpOk = pcall(function()
                    TeleportService:TeleportToPlaceInstance(PlaceId, target.id, LocalPlayer)
                end)

                if tpOk then
                    local t0 = os.clock()
                    while (os.clock() - t0) < 3 do
                        if tostring(game.JobId) ~= before then return end
                        task.wait(0.1)
                    end
                    pcall(function() TeleportService:TeleportCancel() end)
                end
                task.wait(0.35)
            end

            hopNowBtn.Text = "🚀  Failed"
            task.wait(1.5)
            hopNowBtn.Text = "🚀  Hop Now"
            hopNowBtn.BackgroundColor3 = Theme.Surface
            HopInProgress = false
        end)

        if not ok then
            hopNowBtn.Text = "🚀  Error"
            task.wait(1.5)
            hopNowBtn.Text = "🚀  Hop Now"
            hopNowBtn.BackgroundColor3 = Theme.Surface
            HopInProgress = false
            warn("[HopNow]", err)
        end
    end)
end

hopNowBtn.Activated:Connect(hopNow)

--==================================================
-- TABS MANAGEMENT
--==================================================

local function showMain()
    mainContent.Visible = true
    miscContent.Visible = false
    mainTab.BackgroundColor3 = Theme.Accent
    mainTab.TextColor3 = Color3.new(1, 1, 1)
    miscTab.BackgroundColor3 = Theme.Surface
    miscTab.TextColor3 = Theme.TextDim
end

local function showMisc()
    mainContent.Visible = false
    miscContent.Visible = true
    mainTab.BackgroundColor3 = Theme.Surface
    mainTab.TextColor3 = Theme.TextDim
    miscTab.BackgroundColor3 = Theme.Accent
    miscTab.TextColor3 = Color3.new(1, 1, 1)
end

mainTab.Activated:Connect(showMain)
miscTab.Activated:Connect(showMisc)

--==================================================
-- ANTI-HIT SYSTEM
--==================================================

local TeleportPoints = {
    Vector3.new(500.62, 241.28, -366.64),
    Vector3.new(504.45, 155.80, -366.35),
    Vector3.new(508.30, 70.28, -366.03),
    Vector3.new(513.86, 70.28, -366.25),
    Vector3.new(519.43, 70.28, -366.47),
    Vector3.new(524.32, 70.28, -366.59),
    Vector3.new(529.22, 70.28, -366.71),
    Vector3.new(538.01, 70.28, -365.55),
    Vector3.new(546.80, 70.28, -364.40)
}

local ANTI_HIT_SPEED = 0.005

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.fromOffset(220, 78)
loadingFrame.Position = UDim2.new(0.5, -110, 0.5, -39)
loadingFrame.BackgroundColor3 = Theme.Background
loadingFrame.BorderSizePixel = 0
loadingFrame.Visible = false
loadingFrame.ZIndex = 100
loadingFrame.Parent = screenGui

local loadingCorner = Instance.new("UICorner")
loadingCorner.CornerRadius = UDim.new(0, 12)
loadingCorner.Parent = loadingFrame

local loadingStroke = Instance.new("UIStroke")
loadingStroke.Color = Theme.Accent
loadingStroke.Thickness = 1.5
loadingStroke.Transparency = 0.3
loadingStroke.Parent = loadingFrame

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1, 0, 0, 32)
loadingText.Position = UDim2.fromOffset(0, 8)
loadingText.BackgroundTransparency = 1
loadingText.Text = "TELEPORTING..."
loadingText.TextColor3 = Theme.Text
loadingText.Font = Enum.Font.GothamBold
loadingText.TextSize = 13
loadingText.ZIndex = 101
loadingText.Parent = loadingFrame

local loadingBarBack = Instance.new("Frame")
loadingBarBack.Size = UDim2.new(1, -28, 0, 8)
loadingBarBack.Position = UDim2.fromOffset(14, 48)
loadingBarBack.BackgroundColor3 = Theme.Surface
loadingBarBack.BorderSizePixel = 0
loadingBarBack.ZIndex = 101
loadingBarBack.Parent = loadingFrame

local loadingBarCorner = Instance.new("UICorner")
loadingBarCorner.CornerRadius = UDim.new(1, 0)
loadingBarCorner.Parent = loadingBarBack

local loadingBar = Instance.new("Frame")
loadingBar.Size = UDim2.new(0, 0, 1, 0)
loadingBar.BackgroundColor3 = Theme.Accent
loadingBar.BorderSizePixel = 0
loadingBar.ZIndex = 102
loadingBar.Parent = loadingBarBack

local loadingBarFillCorner = Instance.new("UICorner")
loadingBarFillCorner.CornerRadius = UDim.new(1, 0)
loadingBarFillCorner.Parent = loadingBar

local function StopTeleportLoading()
    IsTeleporting = false
    loadingBar.Size = UDim2.new(1, 0, 1, 0)
    loadingFrame.Visible = false
end

local function TeleportRoute(character)
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    IsTeleporting = true
    loadingFrame.Visible = true
    loadingBar.Size = UDim2.new(0, 0, 1, 0)

    for i, position in ipairs(TeleportPoints) do
        if not AntiHitEnabled then
            StopTeleportLoading()
            return
        end
        if not root.Parent then
            StopTeleportLoading()
            return
        end

        root.CFrame = CFrame.new(position)
        local progress = i / #TeleportPoints

        TweenService:Create(
            loadingBar,
            TweenInfo.new(ANTI_HIT_SPEED, Enum.EasingStyle.Linear),
            { Size = UDim2.new(progress, 0, 1, 0) }
        ):Play()

        task.wait(ANTI_HIT_SPEED)
    end

    StopTeleportLoading()
end

antiHitBtn.Activated:Connect(function()
    AntiHitEnabled = not AntiHitEnabled
    setToggle(antiHitBtn, AntiHitEnabled, "🛡  Anti-Hit")
    if not AntiHitEnabled and IsTeleporting then
        StopTeleportLoading()
    end
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
    if player ~= LocalPlayer then return end
    if not AntiHitEnabled then return end
    if IsTeleporting then return end

    local character = LocalPlayer.Character
    if not character then return end

    task.spawn(function()
        TeleportRoute(character)
    end)
end)

--==================================================
-- ANTI-TRAP SYSTEM
--==================================================

local function untrap(reason)
    if not AntiTrapEnabled then
        isTrapped = false
        return false
    end

    local char = LocalPlayer.Character
    if not char then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then return false end

    if type(hum.JumpHeight) == "number" and hum.JumpHeight > 0.5 then
        savedJumpHeight = hum.JumpHeight
    end

    local trappedAttr = char:GetAttribute("IsTrapped") == true

    if not trappedAttr and (not hrp.Anchored and hum.JumpHeight ~= 0) then
        isTrapped = false
        return false
    end

    pcall(function()
        if trappedAttr then
            char:SetAttribute("IsTrapped", nil)
        end

        hrp.Anchored = false
        hum.PlatformStand = false
        hum.Sit = false
        hum.AutoRotate = true

        if hum.JumpHeight < 0.5 then
            hum.JumpHeight = savedJumpHeight
        end

        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.PlatformStanding
            or state == Enum.HumanoidStateType.Seated then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)

    pcall(function()
        local billboard = char:FindFirstChild("TrapBillboard", true)
        if billboard then
            billboard:Destroy()
        end
    end)

    if not isTrapped then
        isTrapped = true
        escapeCount += 1
        print("[AntiTrap] untrap:", reason or "freeze", "count:", escapeCount)
    end

    return true
end

local function applyNoTouch()
    if not AntiTrapEnabled then
        for part, old in pairs(touchSave.saved) do
            if part and part.Parent then
                pcall(function() part.CanTouch = old end)
            end
        end
        touchSave.saved = {}
        return
    end

    local char = LocalPlayer.Character
    if not char then return end

    if char ~= touchSave.char then
        touchSave.saved = {}
        touchSave.char = char
        touchSave.at = 0
    end

    local now = os.clock()
    if now - (touchSave.at or 0) < 0.25 then return end
    touchSave.at = now

    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then
            if touchSave.saved[d] == nil then
                touchSave.saved[d] = d.CanTouch
            end
            if d.CanTouch ~= false then
                d.CanTouch = false
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if AntiTrapEnabled then
            untrap("loop")
            applyNoTouch()
        end
    end
end)

antiTrapBtn.Activated:Connect(function()
    AntiTrapEnabled = not AntiTrapEnabled
    setToggle(antiTrapBtn, AntiTrapEnabled, "🔓  Anti-Trap")
    if not AntiTrapEnabled then
        applyNoTouch()
    end
end)

--==================================================
-- INSTANT STEAL SYSTEM
--==================================================

local function applyInstantSteal()
    if not InstantStealEnabled then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            pcall(function()
                obj.HoldDuration = 0
            end)
        end
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if InstantStealEnabled and obj:IsA("ProximityPrompt") then
        pcall(function()
            obj.HoldDuration = 0
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if InstantStealEnabled then
            applyInstantSteal()
        end
    end
end)

instantStealBtn.Activated:Connect(function()
    InstantStealEnabled = not InstantStealEnabled
    setToggle(instantStealBtn, InstantStealEnabled, "⚡  Instant Steal")
    if InstantStealEnabled then
        applyInstantSteal()
    end
end)

--==================================================
-- BAT AURA SYSTEM
--==================================================

local BAT_RANGE = 17
local lastBatSwing = 0
local lastBatEquip = 0
local batConn = nil
local batSwingRemote = nil

local function isBatTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool:GetAttribute("IsBat") == true then return true end
    local name = string.lower(tool.Name or "")
    return name:find("bat", 1, true) ~= nil
end

local function findBat(container)
    if not container then return nil end
    for _, child in ipairs(container:GetChildren()) do
        if isBatTool(child) then
            return child
        end
    end
    return nil
end

local function equipBat()
    local char = LocalPlayer.Character
    if not char then return nil end
    local equipped = findBat(char)
    if equipped then return equipped end

    local now = os.clock()
    if now - lastBatEquip < 0.4 then return nil end
    lastBatEquip = now

    local bag = LocalPlayer:FindFirstChild("Backpack")
    local bat = findBat(bag)
    if not bat then return nil end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:EquipTool(bat)
        end)
    end
    return findBat(char)
end

local function getSwingRemote()
    if batSwingRemote and batSwingRemote.Parent then
        return batSwingRemote
    end
    local paths = {
        function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if not r then return nil end
            local bs = r:FindFirstChild("BatSwing")
            return bs and (bs:FindFirstChild("Trigger") or bs)
        end,
        function()
            return ReplicatedStorage:FindFirstChild("BatSwing", true)
        end,
        function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            return r and r:FindFirstChild("BatSwing", true)
        end,
    }
    for _, fn in ipairs(paths) do
        local ok, rem = pcall(fn)
        if ok and rem and (rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction")) then
            batSwingRemote = rem
            return rem
        end
    end
    pcall(function()
        for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                local n = string.lower(d.Name)
                if n:find("bat", 1, true) and (n:find("swing", 1, true) or n:find("trigger", 1, true) or n:find("hit", 1, true)) then
                    batSwingRemote = d
                    return
                end
            end
        end
    end)
    return batSwingRemote
end

local function getRoot(player)
    local char = player and player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum and hrp and hum.Health > 0 then
        return hrp, hum
    end
    return nil
end

local function nearestTarget(myPos)
    local best, bestDist
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local hrp = getRoot(plr)
            if hrp then
                local d = (hrp.Position - myPos).Magnitude
                if d <= BAT_RANGE and (not bestDist or d < bestDist) then
                    best = plr
                    bestDist = d
                end
            end
        end
    end
    return best
end

local function swingAt(target)
    if not BatAuraEnabled or not target or target == LocalPlayer then
        return
    end
    local now = os.clock()
    if now - lastBatSwing < 0.65 then return end

    local myRoot = getRoot(LocalPlayer)
    local theirRoot = getRoot(target)
    if not myRoot or not theirRoot then return end
    if (myRoot.Position - theirRoot.Position).Magnitude > BAT_RANGE then return end

    if not equipBat() then return end

    local rem = getSwingRemote()
    if not rem then
        local bat = findBat(LocalPlayer.Character)
        if bat then
            lastBatSwing = now
            pcall(function() bat:Activate() end)
        end
        return
    end

    lastBatSwing = now
    pcall(function()
        if rem:IsA("RemoteEvent") then
            rem:FireServer(target)
        elseif rem:IsA("RemoteFunction") then
            rem:InvokeServer(target)
        end
    end)
end

local function batTick()
    if not BatAuraEnabled then return end
    local myRoot = getRoot(LocalPlayer)
    if not myRoot then return end
    equipBat()
    local target = nearestTarget(myRoot.Position)
    if target then
        swingAt(target)
    end
end

local function setBatAura(on)
    BatAuraEnabled = on
    setToggle(batAuraBtn, on, "🏏  Bat Aura")
    if on then
        if not batConn then
            batConn = RunService.Heartbeat:Connect(function()
                pcall(batTick)
            end)
        end
    else
        if batConn then
            batConn:Disconnect()
            batConn = nil
        end
    end
end

batAuraBtn.Activated:Connect(function()
    setBatAura(not BatAuraEnabled)
end)

--==================================================
-- MINIMIZE / MAXIMIZE
--==================================================

minimizeButton.Activated:Connect(function()
    IsMinimized = not IsMinimized

    if IsMinimized then
        minimizeButton.Text = "+"
        mainTab.Visible = false
        miscTab.Visible = false
        mainContent.Visible = false
        miscContent.Visible = false
        mainFrame.Size = UDim2.fromOffset(250, 42)
    else
        minimizeButton.Text = "−"
        mainTab.Visible = true
        miscTab.Visible = true
        mainFrame.Size = UDim2.fromOffset(250, 400)
        if mainTab.BackgroundColor3 == Theme.Accent then
            mainContent.Visible = true
        else
            miscContent.Visible = true
        end
    end
end)

--==================================================
-- CLOSE GUI
--==================================================

closeButton.Activated:Connect(function()
    screenGui.Enabled = false
end)

--==================================================
-- KEY SYSTEM LOGIC
--==================================================

local function saveKey()
    pcall(function()
        if writefile then
            writefile(KEY_FILE, CORRECT_KEY)
        end
    end)
end

local function hasValidSavedKey()
    local success, result = pcall(function()
        if type(isfile) == "function" and isfile(KEY_FILE) then
            return readfile(KEY_FILE)
        end
        return nil
    end)
    return success and result == CORRECT_KEY
end

keyCloseBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)
keyCloseBtn.Activated:Connect(function()
    screenGui.Enabled = false
end)

local function onSubmit()
    if keyBox.Text == CORRECT_KEY then
        saveKey()
        keyFrame.Visible = false
        keyFrame:Destroy()
        mainFrame.Visible = true
        showMain()
        print("[AUG] Hub loaded successfully with valid key.")
    else
        submitBtn.Text = "INVALID KEY"
        submitBtn.BackgroundColor3 = Theme.Danger
        task.wait(1.4)
        submitBtn.Text = "SUBMIT"
        submitBtn.BackgroundColor3 = Theme.Accent
    end
end

submitBtn.MouseButton1Click:Connect(onSubmit)
submitBtn.Activated:Connect(onSubmit)

local function onGetKey()
    pcall(function()
        SetClipboard(GET_KEY_URL)
    end)
    getKeyBtn.Text = "LINK COPIED!"
    task.wait(1.4)
    getKeyBtn.Text = "GET KEY"
end

getKeyBtn.MouseButton1Click:Connect(onGetKey)
getKeyBtn.Activated:Connect(onGetKey)

if hasValidSavedKey() then
    keyFrame.Visible = false
    keyFrame:Destroy()
    mainFrame.Visible = true
    showMain()
    print("[AUG] Hub loaded with saved key.")
end
