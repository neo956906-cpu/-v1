local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

local menuOpen = false
local isFlying, isNoclipping, isAimbot, isFOVCircle, isAutoFire, isRageBot, isDisync, isTriggerBot, isVoidSpam = false, false, false, false, false, false, false, false, false
local isCornerBoxESP, isSkeletonESP, isNameESP, isHealthESP, isTracerESP = false, false, false, false, false
local isBehindAttack, isHitFix, isWallbang = false, false, true
local isAimingHead = true
local flySpeed = 50
local fovRadius = 160
local fireDelay = 0.5
local bv, bg
local playerDrawings = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GeminiV3PremiumGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local success, parent = pcall(function()
    if gethui then
        return gethui()
    else
        return game:GetService("CoreGui")
    end
end)
if not success or not parent then
    parent = player:WaitForChild("PlayerGui")
end
screenGui.Parent = parent

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.BackgroundColor3 = Color3.fromRGB(255,255,255)
fovCircle.BackgroundTransparency = 0.6
fovCircle.BorderSizePixel = 0
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Size = UDim2.new(0, 160, 0, 160)
fovCircle.Visible = false
fovCircle.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = fovCircle

local fovGradient = Instance.new("UIGradient")
fovGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 0, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))})
fovGradient.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Thickness = 3
fovStroke.Color = Color3.fromRGB(255, 255, 255)
fovStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
fovStroke.Parent = fovCircle

local strokeGradient = Instance.new("UIGradient")
strokeGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))})
strokeGradient.Parent = fovStroke

local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Size = UDim2.new(0, 160, 0, 32)
toggleMenuBtn.Position = UDim2.new(0, 20, 0, 20)
toggleMenuBtn.Text = "Gemini V3 Premium"
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleMenuBtn.Font = Enum.Font.Code
toggleMenuBtn.TextSize = 12
toggleMenuBtn.Visible = true
toggleMenuBtn.Parent = screenGui

local toggleGrad = Instance.new("UIGradient")
toggleGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})
toggleGrad.Parent = toggleMenuBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Thickness = 1.5
toggleStroke.Color = Color3.fromRGB(0, 120, 255)
toggleStroke.Parent = toggleMenuBtn

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 480, 0, 380)
mainFrame.Position = UDim2.new(0.5, -240, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1.5
mainStroke.Color = Color3.fromRGB(0, 120, 255)
mainStroke.Parent = mainFrame

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, -20, 0, 22)
titleBar.Position = UDim2.new(0, 10, 0, 5)
titleBar.BackgroundTransparency = 1
titleBar.Text = "Gemini V3 Premium"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.Font = Enum.Font.Code
titleBar.TextSize = 13
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Parent = mainFrame

local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})
titleGrad.Parent = titleBar

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -20, 0, 25)
tabBar.Position = UDim2.new(0, 10, 0, 30)
tabBar.BackgroundTransparency = 1
tabBar.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabBar

local pages, tabBtns = {}, {}
local function createTab(tabName, isDefault)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 75, 1, 0)
    btn.BackgroundColor3 = isDefault and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(18, 18, 18)
    btn.Text = tabName
    btn.TextColor3 = isDefault and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.Code
    btn.TextSize = 11
    btn.Parent = tabBar

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = isDefault and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 40, 40)
    bStroke.Thickness = 1
    bStroke.Parent = btn

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -20, 1, -65)
    page.Position = UDim2.new(0, 10, 0, 60)
    page.BackgroundTransparency = 1
    page.Visible = isDefault
    page.Parent = mainFrame

    pages[tabName] = page
    tabBtns[tabName] = {btn = btn, stroke = bStroke}

    btn.MouseButton1Click:Connect(function()
        for name, p in pairs(pages) do
            p.Visible = (name == tabName)
            local tb = tabBtns[name]
            tb.btn.BackgroundColor3 = (name == tabName) and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(18, 18, 18)
            tb.btn.TextColor3 = (name == tabName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
            tb.stroke.Color = (name == tabName) and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 40, 40)
        end
    end)
    return page
end

local mainPage = createTab("Main", true)
local espPage = createTab("esp", false)
local miscPage = createTab("misc", false)
local uiPage = createTab("UI Settings", false)

local function createColumns(page)
    local left = Instance.new("Frame") left.Size = UDim2.new(0.485, 0, 1, 0) left.Position = UDim2.new(0, 0, 0, 0) left.BackgroundTransparency = 1 left.Parent = page
    local lList = Instance.new("UIListLayout") lList.Padding = UDim.new(0, 8) lList.SortOrder = Enum.SortOrder.LayoutOrder lList.Parent = left
    local right = Instance.new("Frame") right.Size = UDim2.new(0.485, 0, 1, 0) right.Position = UDim2.new(0.515, 0, 0, 0) right.BackgroundTransparency = 1 right.Parent = page
    local rList = Instance.new("UIListLayout") rList.Padding = UDim.new(0, 8) rList.SortOrder = Enum.SortOrder.LayoutOrder rList.Parent = right
    return left, right
end

local mainLeft, mainRight = createColumns(mainPage)
local espLeft, espRight = createColumns(espPage)
local miscLeft, miscRight = createColumns(miscPage)
local uiLeft, uiRight = createColumns(uiPage)

local function createSection(parent, title)
    local sec = Instance.new("Frame")
    sec.AutomaticSize = Enum.AutomaticSize.Y
    sec.Size = UDim2.new(1, 0, 0, 0)
    sec.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    sec.BorderSizePixel = 0
    sec.Parent = parent

    local secStroke = Instance.new("UIStroke")
    secStroke.Color = Color3.fromRGB(0, 120, 255)
    secStroke.Thickness = 1
    secStroke.Parent = sec

    local secTitle = Instance.new("TextLabel")
    secTitle.Size = UDim2.new(1, -10, 0, 20)
    secTitle.Position = UDim2.new(0, 5, 0, 2)
    secTitle.BackgroundTransparency = 1
    secTitle.Text = title
    secTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    secTitle.Font = Enum.Font.Code
    secTitle.TextSize = 11
    secTitle.TextXAlignment = Enum.TextXAlignment.Left
    secTitle.Parent = sec

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -10, 0, 1)
    line.Position = UDim2.new(0, 5, 0, 22)
    line.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    line.BorderSizePixel = 0
    line.Parent = sec

    local container = Instance.new("Frame")
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Size = UDim2.new(1, -10, 0, 0)
    container.Position = UDim2.new(0, 5, 0, 25)
    container.BackgroundTransparency = 1
    container.Parent = sec

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, 6)
    pad.Parent = sec

    return container
end

local mainSec1 = createSection(mainLeft, "Combat & Movement")
local mainSec2 = createSection(mainRight, "Aimbot & Auto")
local espSec1 = createSection(espLeft, "ESP Overlay")
local miscSec1 = createSection(miscLeft, "Inputs & Config")
local miscSec2 = createSection(miscRight, "Device Spoof")
local uiSec1 = createSection(uiLeft, "UI Options")

local function createToggle(parent, text, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 22)
    btn.BackgroundTransparency = 1
    btn.Text = "[ ] "..text
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.Code
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    btn.Parent = parent
    return btn
end

local flyBtn = createToggle(mainSec1, "Fly", 1)
local noclipBtn = createToggle(mainSec1, "Noclip", 2)
local disyncBtn = createToggle(mainSec1, "Desync", 3)
local voidSpamBtn = createToggle(mainSec1, "Void Spam", 4)
local behindAttackBtn = createToggle(mainSec1, "Behind Attack", 5)

local aimTargetBtn = createToggle(mainSec2, "Aim Part : Head", 1)
local aimbotBtn = createToggle(mainSec2, "Head Lock", 2)
local rageBotBtn = createToggle(mainSec2, "Rage Bot", 3)
local fovToggleBtn = createToggle(mainSec2, "FOV Circle", 4)
local autoFireBtn = createToggle(mainSec2, "Auto Fire", 5)
local triggerBotBtn = createToggle(mainSec2, "Trigger Bot", 6)
local hitFixBtn = createToggle(mainSec2, "Hit Fix (Desync/Void)", 7)
local wallbangBtn = createToggle(mainSec2, "[X] Wallbang (Through Walls)", 8)

local cornerEspBtn = createToggle(espSec1, "Corner Box ESP", 1)
local skeletonEspBtn = createToggle(espSec1, "Skeleton ESP", 2)
local nameEspBtn = createToggle(espSec1, "Name ESP", 3)
local healthEspBtn = createToggle(espSec1, "Health ESP", 4)
local tracerEspBtn = createToggle(espSec1, "Tracer ESP", 5)

local mobileBtn = createToggle(miscSec2, "Mobile Spoof", 1)
local pcBtn = createToggle(miscSec2, "PC Spoof", 2)
local vrBtn = createToggle(miscSec2, "VR Spoof", 3)
local calcBtn = createToggle(miscSec2, "Calculator Spoof", 4)

local currentSpoof = nil
local deviceBtns = {
    ["Mobile"] = mobileBtn,
    ["PC"] = pcBtn,
    ["VR"] = vrBtn,
    ["Calculator"] = calcBtn
}

local function applyDeviceSpoof(devName)
    currentSpoof = devName
    for name, btn in pairs(deviceBtns) do
        local isActive = (name == devName)
        btn.Text = (isActive and "[X] " or "[ ] ")..name.." Spoof"
        btn.TextColor3 = isActive and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(180, 180, 180)
    end
    
    pcall(function()
        if devName == "Mobile" then
            UserInputService.TouchEnabled = true
            UserInputService.KeyboardEnabled = false
            UserInputService.VREnabled = false
        elseif devName == "PC" then
            UserInputService.TouchEnabled = false
            UserInputService.KeyboardEnabled = true
            UserInputService.VREnabled = false
        elseif devName == "VR" then
            UserInputService.TouchEnabled = false
            UserInputService.KeyboardEnabled = true
            UserInputService.VREnabled = true
        elseif devName == "Calculator" then
            UserInputService.TouchEnabled = true
            UserInputService.KeyboardEnabled = false
            UserInputService.VREnabled = false
        end
    end)
end

mobileBtn.MouseButton1Click:Connect(function() applyDeviceSpoof("Mobile") end)
pcBtn.MouseButton1Click:Connect(function() applyDeviceSpoof("PC") end)
vrBtn.MouseButton1Click:Connect(function() applyDeviceSpoof("VR") end)
calcBtn.MouseButton1Click:Connect(function() applyDeviceSpoof("Calculator") end)

local function createInputGroup(parent, titleText, defaultText, order)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -5, 0, 38)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 14)
    label.Text = titleText
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.Code
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 20)
    input.Position = UDim2.new(0, 0, 0, 16)
    input.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    input.TextColor3 = Color3.fromRGB(0, 150, 255)
    input.Font = Enum.Font.Code
    input.TextSize = 11
    input.Text = defaultText
    input.ClearTextOnFocus = false
    input.Parent = container

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(50, 50, 50)
    boxStroke.Thickness = 1
    boxStroke.Parent = input

    return input
end

local fireDelayInput = createInputGroup(miscSec1, "Fire Delay (0.05 ~ 10s)", "0.5", 1)
local speedInput = createInputGroup(miscSec1, "Fly Speed (1 ~ 10000)", "50", 2)
local fovInput = createInputGroup(miscSec1, "FOV Radius (50 ~ 360)", "160", 3)

local circleRotationSpeed = 180
RunService.RenderStepped:Connect(function(deltaTime)
    if isFOVCircle and fovCircle and fovCircle.Visible then
        fovCircle.Rotation = (fovCircle.Rotation + (circleRotationSpeed * deltaTime)) % 360
    end
end)

local function toggleButtonVisual(btn, state, name)
    btn.Text = (state and "[X] " or "[ ] ")..name
    btn.TextColor3 = state and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(180, 180, 180)
end

toggleMenuBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    mainFrame.Visible = menuOpen
end)

speedInput.FocusLost:Connect(function()
    local num = tonumber(speedInput.Text)
    if num then flySpeed = math.clamp(num, 1, 10000) end
    speedInput.Text = tostring(flySpeed)
end)

fovInput.FocusLost:Connect(function()
    local num = tonumber(fovInput.Text)
    if num then fovRadius = math.clamp(num, 50, 360) fovCircle.Size = UDim2.new(0, fovRadius, 0, fovRadius) end
    fovInput.Text = tostring(fovRadius)
end)

fireDelayInput.FocusLost:Connect(function()
    local num = tonumber(fireDelayInput.Text)
    if num then fireDelay = math.clamp(num, 0.05, 10.0) end
    fireDelayInput.Text = tostring(fireDelay)
end)

autoFireBtn.MouseButton1Click:Connect(function()
    isAutoFire = not isAutoFire
    toggleButtonVisual(autoFireBtn, isAutoFire, "Auto Fire")
end)

rageBotBtn.MouseButton1Click:Connect(function()
    isRageBot = not isRageBot
    toggleButtonVisual(rageBotBtn, isRageBot, "Rage Bot")
end)

disyncBtn.MouseButton1Click:Connect(function()
    isDisync = not isDisync
    toggleButtonVisual(disyncBtn, isDisync, "Desync")
end)

voidSpamBtn.MouseButton1Click:Connect(function()
    isVoidSpam = not isVoidSpam
    toggleButtonVisual(voidSpamBtn, isVoidSpam, "Void Spam")
end)

triggerBotBtn.MouseButton1Click:Connect(function()
    isTriggerBot = not isTriggerBot
    toggleButtonVisual(triggerBotBtn, isTriggerBot, "Trigger Bot")
end)

behindAttackBtn.MouseButton1Click:Connect(function()
    isBehindAttack = not isBehindAttack
    toggleButtonVisual(behindAttackBtn, isBehindAttack, "Behind Attack")
end)

hitFixBtn.MouseButton1Click:Connect(function()
    isHitFix = not isHitFix
    toggleButtonVisual(hitFixBtn, isHitFix, "Hit Fix (Desync/Void)")
end)

wallbangBtn.MouseButton1Click:Connect(function()
    isWallbang = not isWallbang
    toggleButtonVisual(wallbangBtn, isWallbang, "Wallbang (Through Walls)")
end)

RunService.Heartbeat:Connect(function()
    if isDisync and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character.HumanoidRootPart
        local oldVel = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(math.random(-12000, 12000), math.random(-12000, 12000), math.random(-12000, 12000))
        RunService.RenderStepped:Wait()
        root.AssemblyLinearVelocity = oldVel
    end
end)

RunService.Heartbeat:Connect(function()
    if isVoidSpam and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character.HumanoidRootPart
        local currentCF = root.CFrame
        root.CFrame = CFrame.new(currentCF.Position - Vector3.new(0, 3500, 0)) * (currentCF - currentCF.Position)
        RunService.RenderStepped:Wait()
        root.CFrame = currentCF
    end
end)

-- 디싱크 및 보이드 스팸 상대 위치 보정/적중률 향상 함수 (실시간 예측 및 히트박스 확장 보정)
local function getResolvedTargetPosition(targetPart)
    if not targetPart then return nil end
    local pos = targetPart.Position
    if isHitFix then
        -- 보이드 스팸이나 디싱크로 인해 아래로 처박히거나 텔레포트한 대상의 본래 위치 또는 최근 유효 물리 속도 예측값 산출
        if math.abs(pos.Y) > 2000 then
            pos = Vector3.new(pos.X, pos.Y + 3500, pos.Z)
        end
        if targetPart.AssemblyLinearVelocity.Magnitude > 50 then
            pos = pos + (targetPart.AssemblyLinearVelocity * 0.08)
        end
    end
    return pos
end

task.spawn(function()
    while true do
        if isTriggerBot then
            local mouse = player:GetMouse()
            local target = mouse.Target
            if target and target.Parent then
                local char = target.Parent
                local p = Players:GetPlayerFromCharacter(char)
                if p and p ~= player then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        pcall(function()
                            local cam = workspace.CurrentCamera
                            VirtualUser:Button1Down(Vector2.new(0,0), cam.CFrame)
                            task.wait(0.05)
                            VirtualUser:Button1Up(Vector2.new(0,0), cam.CFrame)
                        end)
                        task.wait(fireDelay)
                    end
                end
            end
        end
        task.wait(0.05)
    end
end)

task.spawn(function()
    while true do
        if isAutoFire or isRageBot then
            local char = player.Character
            if char and char:FindFirstChildOfClass("Tool") then
                pcall(function()
                    local cam = workspace.CurrentCamera
                    VirtualUser:Button1Down(Vector2.new(0,0), cam.CFrame)
                    task.wait(0.05)
                    VirtualUser:Button1Up(Vector2.new(0,0), cam.CFrame)
                end)
            end
            task.wait(fireDelay)
        else
            task.wait(0.2)
        end
    end
end)

local function startFly()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    isFlying = true
    toggleButtonVisual(flyBtn, isFlying, "Fly")
    char:FindFirstChildOfClass("Humanoid").PlatformStand = true
    bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bg = Instance.new("BodyGyro", char.HumanoidRootPart)
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.CFrame = char.HumanoidRootPart.CFrame
end

local function stopFly()
    isFlying = false
    toggleButtonVisual(flyBtn, isFlying, "Fly")
    local char = player.Character
    if char then char:FindFirstChildOfClass("Humanoid").PlatformStand = false end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

flyBtn.MouseButton1Click:Connect(function() if isFlying then stopFly() else startFly() end end)
noclipBtn.MouseButton1Click:Connect(function() isNoclipping = not isNoclipping toggleButtonVisual(noclipBtn, isNoclipping, "Noclip") end)

RunService.Stepped:Connect(function()
    if isNoclipping and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

local function safeRemoveObj(obj)
    if obj then
        pcall(function()
            if obj.Destroy then obj:Destroy() elseif obj.Remove then obj:Remove() end
        end)
    end
end

local function getPlayerDrawings(p)
    if not Drawing then return nil end
    if not playerDrawings[p] then
        local data = {CornerLines = {}, SkeletonLines = {}, TracerLine = Drawing.new("Line"), NameText = Drawing.new("Text"), HealthText = Drawing.new("Text")}
        for i = 1, 8 do
            local l = Drawing.new("Line") l.Visible = false l.Color = Color3.fromRGB(0, 255, 0) l.Thickness = 1.5 table.insert(data.CornerLines, l)
        end
        for i = 1, 15 do
            local l = Drawing.new("Line") l.Visible = false l.Color = Color3.fromRGB(255, 0, 0) l.Thickness = 1.5 table.insert(data.SkeletonLines, l)
        end
        data.TracerLine.Visible = false data.TracerLine.Color = Color3.fromRGB(255, 0, 0) data.TracerLine.Thickness = 1.5
        data.NameText.Visible = false data.NameText.Size = 14 data.NameText.Center = true data.NameText.Outline = true data.NameText.Color = Color3.fromRGB(255, 255, 255)
        data.HealthText.Visible = false data.HealthText.Size = 13 data.HealthText.Center = true data.HealthText.Outline = true data.HealthText.Color = Color3.fromRGB(0, 255, 0)
        playerDrawings[p] = data
    end
    return playerDrawings[p]
end

local function removePlayerDrawings(p)
    if playerDrawings[p] then
        for _, l in pairs(playerDrawings[p].CornerLines) do safeRemoveObj(l) end
        for _, l in pairs(playerDrawings[p].SkeletonLines) do safeRemoveObj(l) end
        safeRemoveObj(playerDrawings[p].TracerLine)
        safeRemoveObj(playerDrawings[p].NameText)
        safeRemoveObj(playerDrawings[p].HealthText)
        playerDrawings[p] = nil
    end
end

Players.PlayerRemoving:Connect(removePlayerDrawings)

cornerEspBtn.MouseButton1Click:Connect(function() isCornerBoxESP = not isCornerBoxESP toggleButtonVisual(cornerEspBtn, isCornerBoxESP, "Corner Box ESP") end)
skeletonEspBtn.MouseButton1Click:Connect(function() isSkeletonESP = not isSkeletonESP toggleButtonVisual(skeletonEspBtn, isSkeletonESP, "Skeleton ESP") end)
nameEspBtn.MouseButton1Click:Connect(function() isNameESP = not isNameESP toggleButtonVisual(nameEspBtn, isNameESP, "Name ESP") end)
healthEspBtn.MouseButton1Click:Connect(function() isHealthESP = not isHealthESP toggleButtonVisual(healthEspBtn, isHealthESP, "Health ESP") end)
tracerEspBtn.MouseButton1Click:Connect(function() isTracerESP = not isTracerESP toggleButtonVisual(tracerEspBtn, isTracerESP, "Tracer ESP") end)

local function getSkeletonPairs(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return {} end
    if hum.RigType == Enum.HumanoidRigType.R15 then
        return {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
    else
        return {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
    end
end

RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local drawings = getPlayerDrawings(p)
            if drawings then
                local char = p.Character
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                local active = char and rootPart and humanoid and humanoid.Health > 0
                if active then
                    if isCornerBoxESP then
                        local cf, size = char:GetBoundingBox()
                        local topPos, topOn = cam:WorldToViewportPoint((cf * CFrame.new(0, size.Y/2, 0)).Position)
                        local bottomPos, botOn = cam:WorldToViewportPoint((cf * CFrame.new(0, -size.Y/2, 0)).Position)
                        if (topOn or botOn) and topPos.Z > 0 and bottomPos.Z > 0 then
                            local height = math.abs(topPos.Y - bottomPos.Y) local width = height / 2 local x, y = topPos.X - width/2, math.min(topPos.Y, bottomPos.Y) local l = drawings.CornerLines local wLen, hLen = width/4, height/4
                            l[1].From = Vector2.new(x, y) l[1].To = Vector2.new(x + wLen, y) l[1].Visible = true
                            l[2].From = Vector2.new(x, y) l[2].To = Vector2.new(x, y + hLen) l[2].Visible = true
                            l[3].From = Vector2.new(x + width, y) l[3].To = Vector2.new(x + width - wLen, y) l[3].Visible = true
                            l[4].From = Vector2.new(x + width, y) l[4].To = Vector2.new(x + width, y + hLen) l[4].Visible = true
                            l[5].From = Vector2.new(x, y + height) l[5].To = Vector2.new(x + wLen, y + height) l[5].Visible = true
                            l[6].From = Vector2.new(x, y + height) l[6].To = Vector2.new(x, y + height - hLen) l[6].Visible = true
                            l[7].From = Vector2.new(x + width, y + height) l[7].To = Vector2.new(x + width - wLen, y + height) l[7].Visible = true
                            l[8].From = Vector2.new(x + width, y + height) l[8].To = Vector2.new(x + width, y + height - hLen) l[8].Visible = true
                        else
                            for _, line in ipairs(drawings.CornerLines) do line.Visible = false end
                        end
                    else
                        for _, line in ipairs(drawings.CornerLines) do line.Visible = false end
                    end

                    if isSkeletonESP then
                        local pairsList = getSkeletonPairs(char)
                        for i, pair in ipairs(pairsList) do
                            local part1, part2 = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
                            local line = drawings.SkeletonLines[i]
                            if part1 and part2 and line then
                                local pos1, on1 = cam:WorldToViewportPoint(part1.Position)
                                local pos2, on2 = cam:WorldToViewportPoint(part2.Position)
                                if on1 and on2 and pos1.Z > 0 and pos2.Z > 0 then
                                    line.From = Vector2.new(pos1.X, pos1.Y) line.To = Vector2.new(pos2.X, pos2.Y) line.Visible = true
                                else line.Visible = false end
                            elseif line then line.Visible = false end
                        end
                        for i = #pairsList + 1, #drawings.SkeletonLines do drawings.SkeletonLines[i].Visible = false end
                    else
                        for _, line in ipairs(drawings.SkeletonLines) do line.Visible = false end
                    end

                    if isNameESP and rootPart then
                        local pos, onScreen = cam:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
                        drawings.NameText.Visible = onScreen and pos.Z > 0
                        if onScreen and pos.Z > 0 then drawings.NameText.Position = Vector2.new(pos.X, pos.Y - 15) drawings.NameText.Text = p.Name end
                    else drawings.NameText.Visible = false end

                    if isHealthESP and rootPart then
                        local pos, onScreen = cam:WorldToViewportPoint(rootPart.Position + Vector3.new(0, -3.5, 0))
                        drawings.HealthText.Visible = onScreen and pos.Z > 0
                        if onScreen and pos.Z > 0 then drawings.HealthText.Position = Vector2.new(pos.X, pos.Y + 5) drawings.HealthText.Text = "HP: "..math.floor(humanoid.Health) end
                    else drawings.HealthText.Visible = false end

                    if isTracerESP and rootPart then
                        local pos, onScreen = cam:WorldToViewportPoint(rootPart.Position)
                        drawings.TracerLine.Visible = onScreen and pos.Z > 0
                        if onScreen and pos.Z > 0 then drawings.TracerLine.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y) drawings.TracerLine.To = Vector2.new(pos.X, pos.Y) end
                    else drawings.TracerLine.Visible = false end
                else
                    for _, line in ipairs(drawings.CornerLines) do line.Visible = false end
                    for _, line in ipairs(drawings.SkeletonLines) do line.Visible = false end
                    drawings.TracerLine.Visible = false drawings.NameText.Visible = false drawings.HealthText.Visible = false
                end
            end
        end
    end
end)

local function isVisibleThroughWall(targetPart)
    if isWallbang then return true end
    local cam = workspace.CurrentCamera
    if not cam or not targetPart then return false end
    local origin = cam.CFrame.Position
    local direction = targetPart.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {player.Character}
    local result = workspace:Raycast(origin, direction, raycastParams)
    if not result or result.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return false
end

local function getTargetInFOV()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local bestTarget = nil
    local shortestDist = fovRadius / 2
    local center = cam.ViewportSize / 2
    local targetPartName = isAimingHead and "Head" or "HumanoidRootPart"
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild(targetPartName) then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local part = p.Character[targetPartName]
            if hum and hum.Health > 0 and isVisibleThroughWall(part) then
                local screenPos, onScreen = cam:WorldToViewportPoint(getResolvedTargetPosition(part))
                if onScreen and screenPos.Z > 0 then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist <= shortestDist then shortestDist = dist bestTarget = p.Character end
                end
            end
        end
    end
    return bestTarget
end

local function getRageTarget()
    local bestTarget = nil
    local shortestDist = math.huge
    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and targetPart and isVisibleThroughWall(targetPart) then
                local resolvedPos = getResolvedTargetPosition(targetPart)
                local dist = (resolvedPos - myRoot.Position).Magnitude
                if dist < shortestDist then shortestDist = dist bestTarget = targetPart end
            end
        end
    end
    return bestTarget
end

aimTargetBtn.MouseButton1Click:Connect(function()
    isAimingHead = not isAimingHead
    aimTargetBtn.Text = (isAimingHead and "[X] " or "[ ] ").."Aim Part : Head"
end)

aimbotBtn.MouseButton1Click:Connect(function() isAimbot = not isAimbot toggleButtonVisual(aimbotBtn, isAimbot, "Head Lock") end)
fovToggleBtn.MouseButton1Click:Connect(function() isFOVCircle = not isFOVCircle toggleButtonVisual(fovToggleBtn, isFOVCircle, "FOV Circle") fovCircle.Visible = isFOVCircle end)

-- 상대방 뒤에서 조준/공격 위치 계산 및 벽 관통 조준 반영 로직
RunService:BindToRenderStep("AimbotLogic", Enum.RenderPriority.Camera.Value + 1, function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    
    local targetPart = nil
    if isRageBot then
        targetPart = getRageTarget()
    elseif isAimbot then
        local targetChar = getTargetInFOV()
        local targetPartName = isAimingHead and "Head" or "HumanoidRootPart"
        if targetChar and targetChar:FindFirstChild(targetPartName) then
            targetPart = targetChar[targetPartName]
        end
    end
    
    if targetPart then
        local targetPos = getResolvedTargetPosition(targetPart)
        -- Behind Attack 기능: 상대방 뒤편(등 뒤) 좌표를 기준으로 조준점을 오프셋하여 백스탭 및 후면 공격 연출
        if isBehindAttack and targetPart.Parent then
            local targetRoot = targetPart.Parent:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                targetPos = targetPos - (targetRoot.CFrame.LookVector * 4) + Vector3.new(0, 1, 0)
            end
        end
        cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos)
    end
end)

local PlayerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()

RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if isFlying and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and cam then
        local moveVector = controls:GetMoveVector()
        if bv and bg then
            bg.CFrame = cam.CFrame
            if moveVector.Magnitude > 0 then
                local moveDir = (cam.CFrame.RightVector * moveVector.X) - (cam.CFrame.LookVector * moveVector.Z)
                bv.Velocity = moveDir * flySpeed
            else bv.Velocity = Vector3.new(0, 0, 0) end
        end
    end
end)

player.CharacterAdded:Connect(function() if isFlying then task.wait(0.5) startFly() end end)
