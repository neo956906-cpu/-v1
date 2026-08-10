-- ==================================================
-- Gemini V2 - Advanced Auto Fire (VirtualUser), Skeleton Red & Fixed Scroll
-- ==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==========================================
-- 1. 상태 변수 및 설정값
-- ==========================================
local menuOpen = false
local isFlying, isNoclipping, isAimbot, isFOVCircle, isWallbang, isAutoFire = false, false, false, false, false, false
local isCornerBoxESP, isSkeletonESP, isNameESP, isHealthESP, isTracerESP = false, false, false, false, false
local isAimingHead = true

local flySpeed = 50
local fovRadius = 160
local fireDelay = 0.5 -- 기본 발사 딜레이 0.5초 (빠른 연사 지원)
local bv, bg 

local playerDrawings = {}

-- ==========================================
-- 2. GUI 생성 (CanvasSize 850px)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GeminiV2Gui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

-- FOV 원
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

-- 메뉴 토글 버튼
local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Size = UDim2.new(0, 120, 0, 45)
toggleMenuBtn.Position = UDim2.new(0, 20, 0, 20)
toggleMenuBtn.Text = "Gemini V2"
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleMenuBtn.Font = Enum.Font.GothamBold
toggleMenuBtn.TextSize = 14
toggleMenuBtn.Parent = screenGui

-- 메인 프레임
local mainFrame = Instance.new("ScrollingFrame")
mainFrame.Size = UDim2.new(0, 230, 0, 380)
mainFrame.Position = UDim2.new(0, 20, 0, 75)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ScrollBarThickness = 8
mainFrame.CanvasSize = UDim2.new(0, 0, 0, 850)
mainFrame.Visible = false
mainFrame.Parent = screenGui

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = mainFrame
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 30)
padding.Parent = mainFrame

local function createButton(text, order)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 200, 0, 35)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.LayoutOrder = order
	btn.Parent = mainFrame
	return btn
end

-- 버튼들 생성
local flyBtn = createButton("Fly : OFF", 1)
local noclipBtn = createButton("Noclip : OFF", 2)
local cornerEspBtn = createButton("Corner Box ESP : OFF", 3)
local skeletonEspBtn = createButton("Skeleton ESP : OFF", 4)
local nameEspBtn = createButton("Name ESP : OFF", 5)
local healthEspBtn = createButton("Health ESP : OFF", 6)
local tracerEspBtn = createButton("Tracer ESP : OFF", 7)
local aimTargetBtn = createButton("Aim Part : Head", 8)
local aimbotBtn = createButton("Head Lock : OFF", 9)
local fovToggleBtn = createButton("FOV Circle : OFF", 10)
local wallbangBtn = createButton("Wallbang : OFF", 11)
local autoFireBtn = createButton("Auto Fire : OFF", 12)

-- 입력창 생성
local function createInputGroup(titleText, defaultText, order)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 200, 0, 45)
	container.BackgroundTransparency = 1
	container.LayoutOrder = order
	container.Parent = mainFrame
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 15)
	label.Text = titleText
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 11
	label.Parent = container
	
	local input = Instance.new("TextBox")
	input.Size = UDim2.new(1, 0, 0, 25)
	input.Position = UDim2.new(0, 0, 0, 20)
	input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	input.TextColor3 = Color3.fromRGB(0, 0, 0)
	input.Font = Enum.Font.GothamBold
	input.TextSize = 13
	input.Text = defaultText
	input.ClearTextOnFocus = false
	input.Parent = container
	return input
end

local fireDelayInput = createInputGroup("Fire Delay (0.05 ~ 10s)", "0.5", 13)
local speedInput = createInputGroup("Fly Speed (1 ~ 10000)", "50", 14)
local fovInput = createInputGroup("FOV Radius (50 ~ 360)", "160", 15)


-- ==========================================
-- 3. 이벤트 및 로직
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
		fovRadius = math.clamp(num, 50, 360)
		fovCircle.Size = UDim2.new(0, fovRadius, 0, fovRadius)
	end
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

-- 업그레이드된 마우스 시뮬레이션 기반 자동 발사 (VirtualUser 활용)
task.spawn(function()
	while true do
		if isAutoFire then
			local char = player.Character
			if char and char:FindFirstChildOfClass("Tool") then
				pcall(function()
					-- 마우스 좌클릭 시뮬레이션 (인풋 리스너 및 건 시스템 대응)
					VirtualUser:Button1Down(Vector2.new(0, 0), camera.CFrame)
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(0, 0), camera.CFrame)
				end)
			end
			task.wait(fireDelay)
		else
			task.wait(0.2)
		end
	end
end)

-- 플라이 및 노클립
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

-- ESP 및 기타 기능 (졸라맨 빨간색)
local function getPlayerDrawings(p)
	if not playerDrawings[p] then
		local data = {
			CornerLines = {},
			SkeletonLines = {},
			TracerLine = Drawing.new("Line"),
			NameText = Drawing.new("Text"),
			HealthText = Drawing.new("Text")
		}
		for i = 1, 8 do
			local l = Drawing.new("Line")
			l.Visible = false
			l.Color = Color3.fromRGB(0, 255, 0)
			l.Thickness = 1.5
			table.insert(data.CornerLines, l)
		end
		for i = 1, 15 do
			local l = Drawing.new("Line")
			l.Visible = false
			l.Color = Color3.fromRGB(255, 0, 0)
			l.Thickness = 1.5
			table.insert(data.SkeletonLines, l)
		end
		data.TracerLine.Visible = false
		data.TracerLine.Color = Color3.fromRGB(255, 0, 0)
		data.TracerLine.Thickness = 1.5
		
		data.NameText.Visible = false
		data.NameText.Size = 14
		data.NameText.Center = true
		data.NameText.Outline = true
		data.NameText.Color = Color3.fromRGB(255, 255, 255)
		
		data.HealthText.Visible = false
		data.HealthText.Size = 13
		data.HealthText.Center = true
		data.HealthText.Outline = true
		data.HealthText.Color = Color3.fromRGB(0, 255, 0)
		
		playerDrawings[p] = data
	end
	return playerDrawings[p]
end

local function removePlayerDrawings(p)
	if playerDrawings[p] then
		for _, l in pairs(playerDrawings[p].CornerLines) do l:Remove() end
		for _, l in pairs(playerDrawings[p].SkeletonLines) do l:Remove() end
		playerDrawings[p].TracerLine:Remove()
		playerDrawings[p].NameText:Remove()
		playerDrawings[p].HealthText:Remove()
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
		return {
			{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
			{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
			{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
			{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
			{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
		}
	else
		return {
			{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
			{"Torso", "Left Leg"}, {"Torso", "Right Leg"},
		}
	end
end

RunService.RenderStepped:Connect(function()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player then
			local drawings = getPlayerDrawings(p)
			local char = p.Character
			local rootPart = char and char:FindFirstChild("HumanoidRootPart")
			local humanoid = char and char:FindFirstChildOfClass("Humanoid")
			local active = char and rootPart and humanoid and humanoid.Health > 0
			
			if active then
				if isCornerBoxESP then
					local cf, size = char:GetBoundingBox()
					local topPos, topOn = camera:WorldToViewportPoint((cf * CFrame.new(0, size.Y / 2, 0)).Position)
					local bottomPos, botOn = camera:WorldToViewportPoint((cf * CFrame.new(0, -size.Y / 2, 0)).Position)
					if topOn or botOn then
						local height = math.abs(topPos.Y - bottomPos.Y)
						local width = height / 2
						local x, y = topPos.X - width / 2, topPos.Y
						local l = drawings.CornerLines
						local wLen, hLen = width / 4, height / 4
						
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
							local pos1, on1 = camera:WorldToViewportPoint(part1.Position)
							local pos2, on2 = camera:WorldToViewportPoint(part2.Position)
							if on1 and on2 then
								line.From = Vector2.new(pos1.X, pos1.Y)
								line.To = Vector2.new(pos2.X, pos2.Y)
								line.Visible = true
							else line.Visible = false end
						elseif line then line.Visible = false end
					end
					for i = #pairsList + 1, #drawings.SkeletonLines do drawings.SkeletonLines[i].Visible = false end
				else
					for _, line in ipairs(drawings.SkeletonLines) do line.Visible = false end
				end
				
				if isNameESP and rootPart then
					local pos, onScreen = camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
					drawings.NameText.Visible = onScreen
					if onScreen then drawings.NameText.Position = Vector2.new(pos.X, pos.Y - 15) drawings.NameText.Text = p.Name end
				else drawings.NameText.Visible = false end
				
				if isHealthESP and rootPart then
					local pos, onScreen = camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, -3.5, 0))
					drawings.HealthText.Visible = onScreen
					if onScreen then drawings.HealthText.Position = Vector2.new(pos.X, pos.Y + 5) drawings.HealthText.Text = "HP: " .. math.floor(humanoid.Health) end
				else drawings.HealthText.Visible = false end
				
				if isTracerESP and rootPart then
					local pos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
					drawings.TracerLine.Visible = onScreen
					if onScreen then drawings.TracerLine.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y) drawings.TracerLine.To = Vector2.new(pos.X, pos.Y) end
				else drawings.TracerLine.Visible = false end
			else
				for _, line in ipairs(drawings.CornerLines) do line.Visible = false end
				for _, line in ipairs(drawings.SkeletonLines) do line.Visible = false end
				drawings.TracerLine.Visible = false drawings.NameText.Visible = false drawings.HealthText.Visible = false
			end
		end
	end
end)

-- Wallbang 기능
local wallbangOriginals = {}
local wallbangConnection
local oldRaycast

local function processWallbangPart(part)
	if part:IsA("BasePart") then
		for _, p in pairs(Players:GetPlayers()) do
			if p.Character and part:IsDescendantOf(p.Character) then return end
		end
		local partName = string.lower(part.Name)
		if part:IsA("Terrain") or partName:match("baseplate") or partName:match("spawn") then return end
		
		if not wallbangOriginals[part] then
			wallbangOriginals[part] = { CanCollide = part.CanCollide, Transparency = part.Transparency, CanQuery = part.CanQuery, CanTouch = part.CanTouch }
		end
		part.CanCollide = false part.CanTouch = false pcall(function() part.CanQuery = false end) part.Transparency = math.max(part.Transparency, 0.7)
	end
end

pcall(function()
	oldRaycast = hookfunction(workspace.Raycast, newcclosure(function(self, origin, direction, params)
		if isWallbang and self == workspace then
			if not params then params = RaycastParams.new() params.FilterType = Enum.RaycastFilterType.Exclude end
			local newFilter = {}
			for _, v in ipairs(params.FilterDescendantsInstances or {}) do table.insert(newFilter, v) end
			for part, _ in pairs(wallbangOriginals) do if part and part.Parent then table.insert(newFilter, part) end end
			params.FilterDescendantsInstances = newFilter
		end
		return oldRaycast(self, origin, direction, params)
	end))
end)

wallbangBtn.MouseButton1Click:Connect(function()
	isWallbang = not isWallbang
	toggleButtonVisual(wallbangBtn, isWallbang, "Wallbang")
	if isWallbang then
		for _, part in pairs(workspace:GetDescendants()) do processWallbangPart(part) end
		wallbangConnection = workspace.DescendantAdded:Connect(function(part) task.wait(0.05) if isWallbang then processWallbangPart(part) end end)
	else
		if wallbangConnection then wallbangConnection:Disconnect() end
		for part, props in pairs(wallbangOriginals) do
			if part and part.Parent then
				part.CanCollide = props.CanCollide part.Transparency = props.Transparency part.CanTouch = props.CanTouch pcall(function() part.CanQuery = props.CanQuery end)
			end
		end
		wallbangOriginals = {}
	end
end)

-- 에임봇
aimTargetBtn.MouseButton1Click:Connect(function()
	isAimingHead = not isAimingHead
	aimTargetBtn.Text = "Aim Part : " .. (isAimingHead and "Head" or "Body")
	aimTargetBtn.BackgroundColor3 = isAimingHead and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 100, 200)
end)

aimbotBtn.MouseButton1Click:Connect(function() isAimbot = not isAimbot toggleButtonVisual(aimbotBtn, isAimbot, "Head Lock") end)
fovToggleBtn.MouseButton1Click:Connect(function() isFOVCircle = not isFOVCircle toggleButtonVisual(fovToggleBtn, isFOVCircle, "FOV Circle") fovCircle.Visible = isFOVCircle end)

local function getTargetInFOV()
	local bestTarget = nil
	local shortestDist = fovRadius / 2
	local center = camera.ViewportSize / 2
	local targetPartName = isAimingHead and "Head" or "HumanoidRootPart"
	
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild(targetPartName) then
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local screenPos, onScreen = camera:WorldToViewportPoint(p.Character[targetPartName].Position)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
					if dist <= shortestDist then shortestDist = dist bestTarget = p.Character end
				end
			end
		end
	end
	return bestTarget
end

RunService:BindToRenderStep("AimbotLogic", Enum.RenderPriority.Camera.Value + 1, function()
	if isAimbot then
		local target = getTargetInFOV()
		local targetPartName = isAimingHead and "Head" or "HumanoidRootPart"
		if target and target:FindFirstChild(targetPartName) then camera.CFrame = CFrame.new(camera.CFrame.Position, target[targetPartName].Position) end
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
			else bv.Velocity = Vector3.new(0, 0, 0) end
		end
	end
end)

player.CharacterAdded:Connect(function() if isFlying then task.wait(0.5) startFly() end end)
