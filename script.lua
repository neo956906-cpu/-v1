local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==========================================
-- 1. Raycast 설정 (전역 무시 레이캐스트)
-- ==========================================
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true


-- ==========================================
-- 2. GUI 생성 (Gemini V2)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GeminiV2Gui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 중앙 빨간색 조준선 (FOV 원 - 기본 크기 160)
local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
fovCircle.BackgroundTransparency = 0.8
fovCircle.BorderSizePixel = 2
fovCircle.BorderColor3 = Color3.fromRGB(255, 0, 0)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Size = UDim2.new(0, 160, 0, 160)
fovCircle.Visible = false
fovCircle.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = fovCircle

-- 메뉴 열기/닫기 버튼
local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Size = UDim2.new(0, 120, 0, 50)
toggleMenuBtn.Position = UDim2.new(0, 20, 0, 20)
toggleMenuBtn.Text = "Gemini V2"
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleMenuBtn.Font = Enum.Font.GothamBold
toggleMenuBtn.TextSize = 14
toggleMenuBtn.Parent = screenGui

-- 메인 메뉴 프레임
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 530)
mainFrame.Position = UDim2.new(0, 20, 0, 80)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Visible = false
mainFrame.Parent = screenGui

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = mainFrame
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.Parent = mainFrame

local function createButton(text, order)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 200, 0, 40)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.LayoutOrder = order
	btn.Parent = mainFrame
	return btn
end

-- 버튼들 생성
local flyBtn = createButton("Fly : OFF", 1)
local noclipBtn = createButton("Noclip : OFF", 2)
local espBtn = createButton("ESP : OFF", 3)
local aimbotBtn = createButton("Head Lock : OFF", 4)
local fovToggleBtn = createButton("FOV Circle : OFF", 5)
local wallbangBtn = createButton("Wallbang : OFF", 6)

-- 입력창 생성 함수
local function createInputGroup(titleText, defaultText, order)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 200, 0, 55)
	container.BackgroundTransparency = 1
	container.LayoutOrder = order
	container.Parent = mainFrame
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.Text = titleText
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 12
	label.Parent = container
	
	local input = Instance.new("TextBox")
	input.Size = UDim2.new(1, 0, 0, 30)
	input.Position = UDim2.new(0, 0, 0, 25)
	input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	input.TextColor3 = Color3.fromRGB(0, 0, 0)
	input.Font = Enum.Font.GothamBold
	input.TextSize = 16
	input.Text = defaultText
	input.ClearTextOnFocus = false
	input.Parent = container
	return input
end

local speedInput = createInputGroup("Fly Speed (1 ~ 10000)", "50", 7)
local fovInput = createInputGroup("FOV Radius (50 ~ 1000)", "160", 8)


-- ==========================================
-- 3. 상태 변수 및 설정값
-- ==========================================
local menuOpen = false
local isFlying, isNoclipping, isESP, isAimbot, isFOVCircle, isWallbang = false, false, false, false, false, false
local flySpeed = 50
local fovRadius = 160
local bv, bg 


-- ==========================================
-- 4. 버튼 및 입력창 클릭 로직
-- ==========================================
local function toggleButtonVisual(btn, state, name)
	btn.Text = name .. (state and " : ON" or " : OFF")
	btn.BackgroundColor3 = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end

toggleMenuBtn.MouseButton1Click:Connect(function()
	menuOpen = not menuOpen
	mainFrame.Visible = menuOpen
	toggleMenuBtn.Text = menuOpen and "Gemini V2 (Close)" or "Gemini V2"
end)

speedInput.FocusLost:Connect(function()
	local num = tonumber(speedInput.Text)
	if num then flySpeed = math.clamp(num, 1, 10000) end
	speedInput.Text = tostring(flySpeed)
end)

fovInput.FocusLost:Connect(function()
	local num = tonumber(fovInput.Text)
	if num then
		fovRadius = math.clamp(num, 50, 1000)
		fovCircle.Size = UDim2.new(0, fovRadius, 0, fovRadius)
	end
	fovInput.Text = tostring(fovRadius)
end)


-- ==========================================
-- 5. 핵심 기능 세부 구현
-- ==========================================

-- [플라이]
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

-- [노클립]
noclipBtn.MouseButton1Click:Connect(function()
	isNoclipping = not isNoclipping
	toggleButtonVisual(noclipBtn, isNoclipping, "Noclip")
end)

RunService.Stepped:Connect(function()
	if isNoclipping and player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)

-- [ESP 박스]
local function updateESP()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local oldESP = p.Character:FindFirstChild("ESP_Highlight")
			if oldESP then oldESP:Destroy() end
			if isESP then
				local esp = Instance.new("Highlight", p.Character)
				esp.Name = "ESP_Highlight"
				esp.FillColor = Color3.fromRGB(255, 0, 0)
				esp.OutlineColor = Color3.fromRGB(255, 0, 0)
				esp.FillTransparency = 0.5
				esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			end
		end
	end
end

espBtn.MouseButton1Click:Connect(function()
	isESP = not isESP
	toggleButtonVisual(espBtn, isESP, "ESP")
	updateESP()
end)

Players.PlayerAdded:Connect(function(newPlayer)
	newPlayer.CharacterAdded:Connect(function() task.wait(1) updateESP() end)
end)

for _, p in pairs(Players:GetPlayers()) do
	p.CharacterAdded:Connect(function() task.wait(1) updateESP() end)
end

-- ==========================================
-- [완벽한 총알 벽 관통 (Wallbang) 시스템]
-- ==========================================
local wallbangOriginals = {}
local wallbangConnection
local oldRaycast

local function processWallbangPart(part)
	if part:IsA("BasePart") then
		for _, p in pairs(Players:GetPlayers()) do
			if p.Character and part:IsDescendantOf(p.Character) then return end
		end
		
		local partName = string.lower(part.Name)
		if part:IsA("Terrain") or partName:match("baseplate") or partName:match("spawn") then 
			return 
		end
		
		if not wallbangOriginals[part] then
			wallbangOriginals[part] = {
				CanCollide = part.CanCollide,
				Transparency = part.Transparency,
				CanQuery = part.CanQuery,
				CanTouch = part.CanTouch
			}
		end
		
		part.CanCollide = false
		part.CanTouch = false
		pcall(function() part.CanQuery = false end)
		part.Transparency = math.max(part.Transparency, 0.7)
	end
end

-- 총기 레이캐스트를 가로채서 벽을 완전히 무시하도록 후킹
pcall(function()
	oldRaycast = hookfunction(workspace.Raycast, newcclosure(function(self, origin, direction, params)
		if isWallbang and self == workspace then
			if not params then
				params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
			end
			local currentFilter = params.FilterDescendantsInstances or {}
			local newFilter = {}
			for _, v in ipairs(currentFilter) do
				table.insert(newFilter, v)
			end
			for part, _ in pairs(wallbangOriginals) do
				if part and part.Parent then
					table.insert(newFilter, part)
				end
			end
			params.FilterDescendantsInstances = newFilter
		end
		return oldRaycast(self, origin, direction, params)
	end))
end)

local function enableWallbang()
	for _, part in pairs(workspace:GetDescendants()) do
		processWallbangPart(part)
	end
	
	wallbangConnection = workspace.DescendantAdded:Connect(function(part)
		task.wait(0.05)
		if isWallbang then processWallbangPart(part) end
	end)
end

local function disableWallbang()
	if wallbangConnection then wallbangConnection:Disconnect() end
	
	for part, props in pairs(wallbangOriginals) do
		if part and part.Parent then
			part.CanCollide = props.CanCollide
			part.Transparency = props.Transparency
			part.CanTouch = props.CanTouch
			pcall(function() 
				part.CanQuery = props.CanQuery 
			end)
		end
	end
	wallbangOriginals = {}
end

wallbangBtn.MouseButton1Click:Connect(function()
	isWallbang = not isWallbang
	toggleButtonVisual(wallbangBtn, isWallbang, "Wallbang")
	
	if isWallbang then
		enableWallbang()
	else
		disableWallbang()
	end
end)


-- ==========================================
-- 6. 에임봇 (Head Lock)
-- ==========================================
aimbotBtn.MouseButton1Click:Connect(function()
	isAimbot = not isAimbot
	toggleButtonVisual(aimbotBtn, isAimbot, "Head Lock")
end)

fovToggleBtn.MouseButton1Click:Connect(function()
	isFOVCircle = not isFOVCircle
	toggleButtonVisual(fovToggleBtn, isFOVCircle, "FOV Circle")
	fovCircle.Visible = isFOVCircle
end)

local function getTargetInFOV()
	local bestTarget = nil
	local shortestDist = fovRadius / 2
	local center = camera.ViewportSize / 2
	
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local screenPos, onScreen = camera:WorldToViewportPoint(p.Character.Head.Position)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
					if dist <= shortestDist then
						shortestDist = dist
						bestTarget = p.Character
					end
				end
			end
		end
	end
	return bestTarget
end

RunService:BindToRenderStep("AimbotLogic", Enum.RenderPriority.Camera.Value + 1, function()
	if isAimbot then
		local target = getTargetInFOV()
		if target and target:FindFirstChild("Head") then
			camera.CFrame = CFrame.new(camera.CFrame.Position, target.Head.Position)
		end
	end
end)

local PlayerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()

RunService.RenderStepped:Connect(function()
	if isFlying and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local moveVector = controls:GetMoveVector()
		if bv and bg then
			bg.CFrame = camera.CFrame
			if moveVector.Magnitude > 0 then
				local moveDir = (camera.CFrame.RightVector * moveVector.X) - (camera.CFrame.LookVector * moveVector.Z)
				bv.Velocity = moveDir * flySpeed
			else
				bv.Velocity = Vector3.new(0, 0, 0)
			end
		end
	end
end)

player.CharacterAdded:Connect(function()
	if isFlying then
		task.wait(0.5)
		startFly()
	end
end)
