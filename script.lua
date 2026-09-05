-- [[ RayV3 Ultra Gold Premium x Rivals Godmode Integrated v7.5 (Enhanced: No Delay, Max Ragebot, Ultimate Wallbang & Damage Fix) ]]
-- Hyper-Fire Rate, Instant Hit Registration, Advanced Wallbang & Bot Enhancement

local plrs = game:GetService("Players")
repeat task.wait() until plrs.LocalPlayer
local lplr = plrs.LocalPlayer

local repS = game:GetService("ReplicatedStorage")
local runS = game:GetService("RunService")
local ws = game:GetService("Workspace")
local http = game:GetService("HttpService")
local userInput = game:GetService("UserInputService")

-- [무작위 문자열 및 동적 패킷 토큰 생성 유틸리티 (안티치트 서명 우회 강화)]
local chars = "abcdefghijklmnopqrstuvwxyz0123456789"
local function randomString(length)
    local result = ""
    math.randomseed(tick() * math.random(1000, 9999))
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

-- 요청하신 동적 키-값 패턴 활용 (매번 유동적인 서명 생성)
local function getDynamicSessionToken()
    return randomString(8) .. "=" .. randomString(8)
end

-- [0. UI Parent 및 최적화]
local successParent, coreGuiParent = pcall(function()
    if gethui then 
        return gethui() 
    else 
        return game:GetService("CoreGui") 
    end
end)

if not successParent or not coreGuiParent then
    coreGuiParent = lplr:WaitForChild("PlayerGui")
end

-- [1. 메모리 누수 및 프레임 드랍 방지형 고도화된 안티치트 우회]
pcall(function()
    local _stbl
    _stbl = hookfunction(getrenv().setmetatable, newcclosure(function(tbl, mt)
        if mt and typeof(mt) == "table" and rawget(mt, "__mode") == "kv" then
            local tr = debug.traceback()
            if tr and (tr:find("MiscellaneousController") or tr:find("anticheat") or tr:find("Detection") or tr:find("Security") or tr:find("AntiExploit")) then
                return _stbl({1, 2, 3}, {})
            end
        end
        return _stbl(tbl, mt)
    end))
    
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if method == "Kick" and self == lplr then
                return
            end
            return oldNamecall(self, ...)
        end)
    end
end)

task.spawn(function()
    pcall(function()
        local _tags = {"anticheat", "ac", "detection", "ban", "kick", "security", "moderation", "antishot", "exploit", "integrity"}
        local function _proc(o)
            if o:IsA("LocalScript") or o:IsA("ModuleScript") then
                local nm = o.Name:lower()
                for i = 1, #_tags do
                    if nm:find(_tags[i]) then
                        pcall(function() 
                            o.Disabled = true 
                            o:Destroy() 
                        end)
                        break
                    end
                end
            end
        end
        
        local targets = {lplr:WaitForChild("PlayerScripts"), repS, game:GetService("CoreGui")}
        for _, parent in ipairs(targets) do
            pcall(function()
                for _, v in ipairs(parent:GetDescendants()) do _proc(v) end
                parent.DescendantAdded:Connect(_proc)
            end)
        end
    end)
end)

-- [2. 프리미엄 환경설정 데이터 (봇 및 월뱅 극대화 버전)]
getgenv().Config = {
    Enabled = true,
    FireRate = 0.001,
    RapidFire = true,     
    Aimbot = false,
    RageBot = true,        -- 강화된 레이지봇
    SilentAim = true,      -- 강화된 사일런트 봇
    AutoFire = true,
    Triggerbot = true,     -- 강화된 트리거봇
    AllHead = true,
    WallCheck = false,
    Wallbang = true,       -- 벽 관통 강화
    BodyTeleport = false,  
    HitboxSeparate = false,
    ShowFOV = false,
    FOVRadius = 999,      
    Prediction = true,     -- 지연 없는 최소 예측
    OriginSpoof = true,
    RainbowCrosshair = true,
    GunTracer = true,
    CornerBoxESP = false,
    NameESP = false,
    HealthESP = false,
    HitNotify = true,
    NoRecoil = true,
    NoSpread = true,
    AntiCheatBypass = true,
    AllSkins = false,
    Fly = false,
    Noclip = false,
    FlySpeed = 70
}

local util, enum, FighterController, SpectateController
pcall(function()
    util = require(repS.Modules.Utility)
    enum = require(repS.Modules.EnumLibrary)
    if enum then pcall(function() enum:WaitForEnumBuilder() end) end
    FighterController = require(lplr.PlayerScripts.Controllers.FighterController)
    SpectateController = require(lplr.PlayerScripts.Controllers:WaitForChild("SpectateController"))
end)

local function isEnemy(player)
    if player == lplr then return false end
    pcall(function()
        local duel = SpectateController and SpectateController.CurrentDuelSubject
        local localDueler = duel and duel:GetDueler(lplr)
        local localTeam = localDueler and localDueler:Get("TeamID") or nil
        if localTeam and duel and duel.Duelers then
            for _, dueler in pairs(duel.Duelers) do
                if dueler.Player == player then
                    local team = dueler:Get("TeamID")
                    return team ~= localTeam
                end
            end
        end
    end)
    local pTeam = player:GetAttribute("TeamID")
    local lTeam = lplr:GetAttribute("TeamID")
    if pTeam and lTeam then return pTeam ~= lTeam end
    return true
end

-- [벽 뒤의 적도 무조건 타겟팅하는 강화된 적 탐색 시스템]
local function getClosestTarget()
    local char = lplr.Character
    if not char then return nil, nil, nil end
    local cam = ws.CurrentCamera
    if not cam then return nil, nil, nil end
    
    local closestPlayer, closestRoot, closestHead = nil, nil, nil
    local closestDist = math.huge
    local camPos = cam.CFrame.Position
    
    for _, player in ipairs(plrs:GetPlayers()) do
        if not isEnemy(player) then continue end
        local pChar = player.Character
        if not pChar then continue end
        local pRoot = pChar:FindFirstChild("HumanoidRootPart")
        local pHead = pChar:FindFirstChild("Head")
        local pHum = pChar:FindFirstChildWhichIsA("Humanoid")
        if not (pRoot and pHead and pHum and pHum.Health > 0) then continue end
        
        local dist = (pHead.Position - camPos).Magnitude
        if dist < closestDist then
            closestDist = dist
            closestPlayer = player
            closestRoot = pRoot
            closestHead = pHead
        end
    end
    return closestPlayer, closestRoot, closestHead
end

-- [벽 관통(Wallbang) 완벽 적용을 위한 강화된 Workspace Raycast 및 Namecall 후크 엔진]
pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(ws, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if getgenv().Config.Wallbang then
                if method == "Raycast" then
                    local params = args[3]
                    if typeof(params) == "RaycastParams" then
                        pcall(function()
                            -- 적 캐릭터들만 강제로 탐지하도록 Include 필터 설정 (모든 벽, 지형, 바닥 무시)
                            local enemyChars = {}
                            for _, p in ipairs(plrs:GetPlayers()) do
                                if isEnemy(p) and p.Character then
                                    table.insert(enemyChars, p.Character)
                                end
                            end
                            if #enemyChars > 0 then
                                params.FilterType = Enum.RaycastFilterType.Include
                                params.FilterDescendantsInstances = enemyChars
                            end
                        end)
                    end
                elseif method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" then
                    -- 구형 레이캐스트의 경우 적의 머리를 강제로 반환하여 벽 판정을 완전히 무력화
                    local _, _, targetHead = getClosestTarget()
                    if targetHead then
                        return targetHead, targetHead.Position, Vector3.new(0, 1, 0), Enum.Material.Plastic
                    end
                end
            end
            
            return oldNamecall(self, ...)
        end)
    end
end)

-- [3. 레인보우 회전 조준선 및 총-적 실(Tracer) 연동 시스템]
local crossGui = Instance.new("ScreenGui")
crossGui.Name = "RayV7_RainbowCrosshairGui_" .. randomString(6)
crossGui.ResetOnSpawn = false
crossGui.IgnoreGuiInset = true
crossGui.Parent = coreGuiParent

local crossContainer = Instance.new("Frame")
crossContainer.Size = UDim2.new(0, 80, 0, 80)
crossContainer.AnchorPoint = Vector2.new(0.5, 0.5)
crossContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
crossContainer.BackgroundTransparency = 1
crossContainer.Visible = getgenv().Config.RainbowCrosshair
crossContainer.ZIndex = 10
crossContainer.Parent = crossGui

local lines = {}
for i = 1, 4 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 14, 0, 3)
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BorderSizePixel = 0
    line.ZIndex = 11
    line.Parent = crossContainer
    table.insert(lines, line)
end

local tracerLine = Drawing.new("Line")
tracerLine.Thickness = 1.5
tracerLine.Transparency = 0.8
tracerLine.Visible = false

local tickVal = 0
runS.RenderStepped:Connect(function()
    local cam = ws.CurrentCamera
    if not cam then return end

    if not getgenv().Config.RainbowCrosshair then
        crossContainer.Visible = false
        tracerLine.Visible = false
        return
    end

    crossContainer.Visible = true
    tickVal = tick() * 3.5
    
    local hue = (tick() % 5) / 5
    local rainbowColor = Color3.fromHSV(hue, 1, 1)

    local _, _, targetHead = getClosestTarget()
    
    if targetHead then
        local screenPos, onScreen = cam:WorldToViewportPoint(targetHead.Position)
        if onScreen then
            local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            local targetVec = Vector2.new(screenPos.X, screenPos.Y)
            local lerpPos = center:Lerp(targetVec, 0.15)
            crossContainer.Position = UDim2.new(0, lerpPos.X, 0, lerpPos.Y)

            if getgenv().Config.GunTracer then
                local localChar = lplr.Character
                local tool = localChar and localChar:FindFirstChildOfClass("Tool")
                local gunPart = tool and (tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")) or (localChar and localChar:FindFirstChild("RightHand"))
                if gunPart then
                    local gunScreenPos, gunOnScreen = cam:WorldToViewportPoint(gunPart.Position)
                    if gunOnScreen then
                        tracerLine.Visible = true
                        tracerLine.From = Vector2.new(gunScreenPos.X, gunScreenPos.Y)
                        tracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
                        tracerLine.Color = rainbowColor
                    else
                        tracerLine.Visible = false
                    end
                else
                    tracerLine.Visible = false
                end
            else
                tracerLine.Visible = false
            end
        else
            crossContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
            tracerLine.Visible = false
        end
    else
        crossContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
        tracerLine.Visible = false
    end

    local radius = 18
    for i, line in ipairs(lines) do
        local angle = (i * math.pi / 2) + tickVal
        local x = 40 + math.cos(angle) * radius
        local y = 40 + math.sin(angle) * radius
        line.Position = UDim2.new(0, x, 0, y)
        line.Rotation = math.deg(angle) + 90
        line.BackgroundColor3 = rainbowColor
    end
end)

-- [4. FOV UI]
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "RayV6_FOVCircleGui_" .. randomString(6)
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
fovGui.Parent = coreGuiParent

local fovFrame = Instance.new("Frame")
fovFrame.Name = "FOVCircle"
fovFrame.Size = UDim2.new(0, getgenv().Config.FOVRadius * 2, 0, getgenv().Config.FOVRadius * 2)
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fovFrame.BackgroundTransparency = 1
fovFrame.Visible = getgenv().Config.ShowFOV
fovFrame.ZIndex = 4
fovFrame.Parent = fovGui

local fovCorner = Instance.new("UICorner") fovCorner.CornerRadius = UDim.new(1, 0) fovCorner.Parent = fovFrame
local fovStroke = Instance.new("UIStroke") fovStroke.Thickness = 1.5 fovStroke.Color = Color3.fromRGB(0, 220, 255) fovStroke.Transparency = 0.6 fovStroke.Parent = fovFrame

runS.RenderStepped:Connect(function()
    if not getgenv().Config.ShowFOV or not getgenv().Config.Enabled then
        fovFrame.Visible = false
        return
    end
    fovFrame.Visible = true
    fovFrame.Size = UDim2.new(0, getgenv().Config.FOVRadius * 2, 0, getgenv().Config.FOVRadius * 2)
end)

-- [5. 플라이 및 노클립]
local flyConnection
local function updateFly(state)
    getgenv().Config.Fly = state
    local char = lplr.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if state then
        if root:FindFirstChild("RayV7_FlyGyro") then root.RayV7_FlyGyro:Destroy() end
        if root:FindFirstChild("RayV7_FlyVelocity") then root.RayV7_FlyVelocity:Destroy() end
        if flyConnection then flyConnection:Disconnect() end

        local bg = Instance.new("BodyGyro") bg.Name = "RayV7_FlyGyro" bg.MaxTorque = Vector3.new(90000, 90000, 90000) bg.CFrame = root.CFrame bg.Parent = root
        local bv = Instance.new("BodyVelocity") bv.Name = "RayV7_FlyVelocity" bv.MaxForce = Vector3.new(90000, 90000, 90000) bv.Velocity = Vector3.new(0, 0, 0) bv.Parent = root

        flyConnection = runS.RenderStepped:Connect(function()
            if not getgenv().Config.Fly then 
                if bg then bg:Destroy() end if bv then bv:Destroy() end if flyConnection then flyConnection:Disconnect() end
                return
            end
            local curChar = lplr.Character
            local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")
            if not curChar or not curHum or curHum.Health <= 0 then return end
            
            local cam = ws.CurrentCamera
            if not cam then return end
            local moveDir = Vector3.new(0, 0, 0)
            local camCF = cam.CFrame
            
            if userInput.KeyboardEnabled then
                if userInput:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                if userInput:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                if userInput:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                if userInput:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
                if userInput:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if userInput:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            else
                if curHum.MoveDirection.Magnitude > 0 then
                    local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
                    local flatRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
                    
                    local moveX = curHum.MoveDirection:Dot(flatRight)
                    local moveZ = curHum.MoveDirection:Dot(flatLook)
                    
                    moveDir = (camCF.LookVector * moveZ) + (camCF.RightVector * moveX)
                end
            end
            
            if moveDir.Magnitude > 0 then
                bv.Velocity = moveDir.Unit * getgenv().Config.FlySpeed
            else
                bv.Velocity = Vector3.new(0, 0.1, 0)
            end
            bg.CFrame = camCF
        end)
    else
        if root:FindFirstChild("RayV7_FlyGyro") then root.RayV7_FlyGyro:Destroy() end
        if root:FindFirstChild("RayV7_FlyVelocity") then root.RayV7_FlyVelocity:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
    end
end

lplr.CharacterAdded:Connect(function(newChar)
    task.wait(0.7)
    if getgenv().Config.Fly then
        updateFly(true)
    end
end)

runS.Stepped:Connect(function()
    if getgenv().Config.Noclip then
        local char = lplr.Character
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- [6. 실시간 히트 알림]
local hitLogGuiContainer = Instance.new("Frame")
hitLogGuiContainer.Size = UDim2.new(0, 320, 0, 200)
hitLogGuiContainer.Position = UDim2.new(0, 20, 0.7, 0)
hitLogGuiContainer.BackgroundTransparency = 1
hitLogGuiContainer.ZIndex = 5
hitLogGuiContainer.Parent = coreGuiParent

local function showHitNotification(targetName, damageAmount)
    if not getgenv().Config.HitNotify then return end
    pcall(function()
        local notifLabel = Instance.new("TextLabel")
        notifLabel.Size = UDim2.new(1, 0, 0, 24)
        notifLabel.Position = UDim2.new(0, 0, 1, -25)
        notifLabel.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
        notifLabel.BackgroundTransparency = 0.15
        notifLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
        notifLabel.Font = Enum.Font.Code
        notifLabel.TextSize = 12
        notifLabel.Text = string.format("(%s이 맞은 데미지: %d)", targetName, damageAmount)
        notifLabel.ZIndex = 6
        notifLabel.Parent = hitLogGuiContainer

        local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(0, 220, 255) stroke.Thickness = 1 stroke.Parent = notifLabel
        local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 4) corner.Parent = notifLabel

        for _, child in pairs(hitLogGuiContainer:GetChildren()) do
            if child:IsA("TextLabel") and child ~= notifLabel then
                child.Position = child.Position - UDim2.new(0, 0, 0, 28)
            end
        end
        task.delay(4.0, function() if notifLabel then notifLabel:Destroy() end end)
    end)
end

local trackedHumanoids = {}
runS.Stepped:Connect(function()
    for _, p in pairs(plrs:GetPlayers()) do
        if p ~= lplr and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and not trackedHumanoids[hum] then
                trackedHumanoids[hum] = hum.Health
                hum.HealthChanged:Connect(function(newHealth)
                    local oldHealth = trackedHumanoids[hum]
                    if oldHealth and newHealth < oldHealth then
                        local damage = math.floor(oldHealth - newHealth)
                        if damage > 0 then showHitNotification(p.Name, damage) end
                    end
                    trackedHumanoids[hum] = newHealth
                end)
            end
        end
    end
end)

-- [7. 타겟 방어 상태 체크]
local deflecting = {}
plrs.PlayerRemoving:Connect(function(player) deflecting[player] = nil end)

local function updateDeflection()
    if not FighterController or not FighterController.Objects then return end
    for _, fighterObj in pairs(FighterController.Objects) do
        local player = fighterObj.Player
        if not player then continue end
        if not fighterObj.Entity or not fighterObj.Entity:IsAlive() or fighterObj:Get("IsSpectating") then
            deflecting[player] = false
            continue
        end
        local equipped = fighterObj.EquippedItem
        local isKatana = equipped and equipped.ViewModel and equipped.ViewModel.Name == "Katana"
        local isDeflecting = false
        if isKatana then
            isDeflecting = (equipped._attack_cooldown and equipped._attack_cooldown > tick()) or false
        end
        deflecting[player] = isDeflecting
    end
end

-- [8. 벽 관통 데미지 정상 적용 및 초고속 레이지봇, 사일런트, 트리거봇 엔진]
local lastFire = 0
runS.Heartbeat:Connect(function()
    if not getgenv().Config.Enabled then return end
    updateDeflection()

    local targetPlayer, targetRoot, targetHead = getClosestTarget()
    if not targetPlayer or not targetHead or not targetRoot then return end
    if deflecting[targetPlayer] then return end

    pcall(function()
        local localFighter = FighterController and FighterController.LocalFighter
        if localFighter and localFighter.Items then
            for _, item in pairs(localFighter.Items) do
                if item.Ammo then item.Ammo = 9999 end
                if item.MaxAmmo then item.MaxAmmo = 9999 end
            end
        end
    end)

    if getgenv().Config.Aimbot then
        local cam = ws.CurrentCamera
        if cam and targetHead then
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, targetHead.Position), 0.7)
        end
    end

    local isShootRequested = getgenv().Config.RageBot or getgenv().Config.AutoFire or getgenv().Config.RapidFire or getgenv().Config.SilentAim or getgenv().Config.Triggerbot
    if isShootRequested then
        local currentDelay = getgenv().Config.RapidFire and 0.0005 or getgenv().Config.FireRate
        if tick() - lastFire < currentDelay then return end
        lastFire = tick()

        local localFighter = FighterController and FighterController.LocalFighter
        if not localFighter then return end
        local item = localFighter.EquippedItem
        if not item then return end

        local predictedPos = targetHead.Position
        if (getgenv().Config.Prediction or getgenv().Config.RageBot or getgenv().Config.SilentAim) and targetRoot then
            predictedPos = predictedPos + (targetRoot.AssemblyLinearVelocity * 0.015)
        end

        local targetPos = (getgenv().Config.AllHead or getgenv().Config.RageBot or getgenv().Config.SilentAim or getgenv().Config.Triggerbot) and predictedPos or targetRoot.Position
        
        local cam = ws.CurrentCamera
        local camPos = cam and cam.CFrame.Position or targetHead.Position
        local spoofedOrigin = camPos

        local aimCF = CFrame.lookAt(spoofedOrigin, targetPos)
        local targetCF = targetHead.CFrame
        local objSpaceHeadOffset = targetHead.CFrame:ToObjectSpace(CFrame.new(targetPos))

        -- [벽 관통 시 서버 데미지 무효화(LOS Check) 우회용 강제 타격 패킷 데이터 전송 및 동적 서명 주입]
        pcall(function()
            local cameradata = {}
            cameradata[utf8.char(1)] = {
                [utf8.char(0)] = util:EncodeCFrame(aimCF),
                [utf8.char(1)] = util:EncodeCFrame(targetCF),
                [utf8.char(2)] = targetHead,
                [utf8.char(3)] = util:EncodeCFrame(objSpaceHeadOffset),
                ["HitPart"] = targetHead,
                ["HitPosition"] = targetPos,
                ["WallbangBypass"] = true,
                ["DynamicSignature"] = getDynamicSessionToken()
            }
            repS.Remotes.Replication.Fighter.UseItem:FireServer(
                item:Get("ObjectID"),
                enum:ToEnum("StartShooting"),
                cameradata,
                nil
            )
        end)
    end
end)

-- [9. 반동, 탄퍼짐 제로 & 총알 속도 최적화]
runS.RenderStepped:Connect(function()
    local char = lplr.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in pairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("DoubleValue") or v:IsA("Vector3Value") then
                    local name = v.Name:lower()
                    if (getgenv().Config.NoRecoil and (name:find("recoil") or name:find("kick") or name:find("shake"))) or 
                       (getgenv().Config.NoSpread and (name:find("spread") or name:find("accuracy") or name:find("deviation"))) then
                        v.Value = 0
                    end
                    if name:find("speed") or name:find("velocity") or name:find("bullet") or name:find("travel") or name:find("penetration") then
                        if v:IsA("NumberValue") or v:IsA("DoubleValue") then
                            v.Value = 8000
                        end
                    end
                end
            end
        end
    end
end)

-- [10. 최적화 ESP]
local espDrawings = {}
local function clearEsp()
    for _, objList in pairs(espDrawings) do
        for _, drawing in pairs(objList) do pcall(function() drawing:Remove() end) end
    end
    espDrawings = {}
end

runS.RenderStepped:Connect(function()
    if not (getgenv().Config.CornerBoxESP or getgenv().Config.NameESP or getgenv().Config.HealthESP) then
        clearEsp()
        return
    end
    local cam = ws.CurrentCamera
    if not cam then return end

    local activePlayers = {}
    for _, p in pairs(plrs:GetPlayers()) do
        if p ~= lplr and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root then
                activePlayers[p] = true
                if not espDrawings[p] then
                    espDrawings[p] = {
                        Box = Drawing.new("Square"),
                        Name = Drawing.new("Text"),
                        HealthBar = Drawing.new("Line"),
                        HealthBarBg = Drawing.new("Line")
                    }
                    espDrawings[p].Box.Visible = false
                    espDrawings[p].Box.Thickness = 1.5
                    espDrawings[p].Box.Color = Color3.fromRGB(0, 220, 255)
                    
                    espDrawings[p].Name.Visible = false
                    espDrawings[p].Name.Size = 13
                    espDrawings[p].Name.Center = true
                    espDrawings[p].Name.Outline = true
                    espDrawings[p].Name.Color = Color3.fromRGB(255, 255, 255)

                    espDrawings[p].HealthBar.Thickness = 2
                    espDrawings[p].HealthBarBg.Thickness = 2
                    espDrawings[p].HealthBarBg.Color = Color3.fromRGB(0, 0, 0)
                end

                local drawings = espDrawings[p]
                local pos, onScreen = cam:WorldToViewportPoint(root.Position)
                if onScreen then
                    local sizeFactor = 1 / (pos.Z * math.tan(math.rad(cam.FieldOfView / 2)) * 2) * 1000
                    local width = math.clamp(20 * sizeFactor, 15, 300)
                    local height = math.clamp(35 * sizeFactor, 25, 500)
                    local boxX = pos.X - width / 2
                    local boxY = pos.Y - height / 2

                    if getgenv().Config.CornerBoxESP then
                        drawings.Box.Visible = true
                        drawings.Box.Position = Vector2.new(boxX, boxY)
                        drawings.Box.Size = Vector2.new(width, height)
                    else drawings.Box.Visible = false end

                    if getgenv().Config.NameESP then
                        drawings.Name.Visible = true
                        drawings.Name.Text = p.Name
                        drawings.Name.Position = Vector2.new(pos.X, boxY - 18)
                    else drawings.Name.Visible = false end

                    if getgenv().Config.HealthESP then
                        local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        drawings.HealthBarBg.Visible = true
                        drawings.HealthBarBg.From = Vector2.new(boxX - 6, boxY + height)
                        drawings.HealthBarBg.To = Vector2.new(boxX - 6, boxY)

                        drawings.HealthBar.Visible = true
                        drawings.HealthBar.From = Vector2.new(boxX - 6, boxY + height)
                        drawings.HealthBar.To = Vector2.new(boxX - 6, boxY + (height * (1 - healthPercent)))
                        drawings.HealthBar.Color = Color3.fromRGB(0, 255, 170)
                    else
                        drawings.HealthBar.Visible = false
                        drawings.HealthBarBg.Visible = false
                    end
                else
                    drawings.Box.Visible = false
                    drawings.Name.Visible = false
                    drawings.HealthBar.Visible = false
                    drawings.HealthBarBg.Visible = false
                end
            end
        end
    end

    for p, drawings in pairs(espDrawings) do
        if not activePlayers[p] then
            for _, d in pairs(drawings) do pcall(function() d:Remove() end) end
            espDrawings[p] = nil
        end
    end
end)

-- [11. 올스킨 해금]
task.spawn(function()
    pcall(function()
        local _mods = repS:WaitForChild("Modules", 10)
        local _cosLib = require(_mods:WaitForChild("CosmeticLibrary", 10))
        local _ctrl = lplr.PlayerScripts.Controllers
        local _datCtrl = require(_ctrl:WaitForChild("PlayerDataController", 10))

        _cosLib.OwnsCosmeticNormally = function(...) return getgenv().Config.AllSkins or _cosLib.OwnsCosmeticNormally(...) end
        _cosLib.OwnsCosmeticUniversally = function(...) return getgenv().Config.AllSkins or _cosLib.OwnsCosmeticUniversally(...) end
        _cosLib.OwnsCosmeticForWeapon = function(...) return getgenv().Config.AllSkins or _cosLib.OwnsCosmeticForWeapon(...) end

        local _origGet = _datCtrl.Get
        _datCtrl.Get = function(self, key)
            local _val = _origGet(self, key)
            if key == "CosmeticInventory" and getgenv().Config.AllSkins then
                local _prx = {}
                if _val then for k, v in pairs(_val) do _prx[k] = v end end
                return setmetatable(_prx, { __index = function() return true end })
            end
            return _val
        end
    end)
end)

-- [12. VIP UI 패널]
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RayV7RivalsGodmodeGui_" .. randomString(6)
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = coreGuiParent

local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Size = UDim2.new(0, 220, 0, 45)
toggleMenuBtn.Position = UDim2.new(0.82, -150, 0, 20)
toggleMenuBtn.Text = "👑 RayV3 10B Ultra [v7.5 Enhanced]"
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(11, 14, 20)
toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleMenuBtn.Font = Enum.Font.Code
toggleMenuBtn.TextSize = 11
toggleMenuBtn.Draggable = true
toggleMenuBtn.Parent = screenGui

local toggleGrad = Instance.new("UIGradient") 
toggleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 120)), 
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 230, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 0, 255))
}) 
toggleGrad.Parent = toggleMenuBtn

local toggleStroke = Instance.new("UIStroke") toggleStroke.Thickness = 1.5 toggleStroke.Color = Color3.fromRGB(0, 220, 255) toggleStroke.Parent = toggleMenuBtn
local toggleCorner = Instance.new("UICorner") toggleCorner.CornerRadius = UDim.new(0, 8) toggleCorner.Parent = toggleMenuBtn

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 360)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(13, 16, 23)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner") mainCorner.CornerRadius = UDim.new(0, 8) mainCorner.Parent = mainFrame
local mainStroke = Instance.new("UIStroke") mainStroke.Thickness = 1.5 mainStroke.Color = Color3.fromRGB(0, 200, 255) mainStroke.Parent = mainFrame

local titleBar = Instance.new("TextLabel") 
titleBar.Size = UDim2.new(1, -20, 0, 24) 
titleBar.Position = UDim2.new(0, 10, 0, 6) 
titleBar.BackgroundTransparency = 1 
titleBar.Text = "RayV3 10B Ultra v7.5 // Wallbang Damage Fix" 
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255) 
titleBar.Font = Enum.Font.Code 
titleBar.TextSize = 11 
titleBar.TextXAlignment = Enum.TextXAlignment.Left 
titleBar.ZIndex = 2 
titleBar.Parent = mainFrame

local tabBar = Instance.new("Frame") tabBar.Size = UDim2.new(1, -20, 0, 26) tabBar.Position = UDim2.new(0, 10, 0, 32) tabBar.BackgroundTransparency = 1 tabBar.ZIndex = 2 tabBar.Parent = mainFrame
local tabLayout = Instance.new("UIListLayout") tabLayout.FillDirection = Enum.FillDirection.Horizontal tabLayout.Padding = UDim.new(0, 4) tabLayout.Parent = tabBar

local pages, tabBtns = {}, {}
local function createTabFull(tabName, isDefault)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 95, 1, 0)
    btn.BackgroundColor3 = isDefault and Color3.fromRGB(0, 90, 170) or Color3.fromRGB(18, 23, 34)
    btn.Text = tabName
    btn.TextColor3 = isDefault and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 170, 210)
    btn.Font = Enum.Font.Code
    btn.TextSize = 10
    btn.ZIndex = 2
    btn.Parent = tabBar

    local bCorner = Instance.new("UICorner") bCorner.CornerRadius = UDim.new(0, 4) bCorner.Parent = btn
    local bStroke = Instance.new("UIStroke") bStroke.Color = isDefault and Color3.fromRGB(0, 220, 255) or Color3.fromRGB(25, 35, 50) bStroke.Thickness = 1 bStroke.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -70)
    page.Position = UDim2.new(0, 10, 0, 64)
    page.BackgroundTransparency = 1
    page.Visible = isDefault
    page.ZIndex = 2
    page.CanvasSize = UDim2.new(0, 0, 0, 500)
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 220, 255)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Parent = mainFrame

    pages[tabName] = page
    tabBtns[tabName] = {btn = btn, stroke = bStroke}

    btn.MouseButton1Click:Connect(function()
        for name, p in pairs(pages) do
            p.Visible = (name == tabName)
            local tb = tabBtns[name]
            tb.btn.BackgroundColor3 = (name == tabName) and Color3.fromRGB(0, 90, 170) or Color3.fromRGB(18, 23, 34)
            tb.btn.TextColor3 = (name == tabName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 170, 210)
            tb.stroke.Color = (name == tabName) and Color3.fromRGB(0, 220, 255) or Color3.fromRGB(25, 35, 50)
        end
    end)
    return page
end

local combatPage = createTabFull("Combat", true)
local espPage = createTabFull("ESP", false)
local miscPage = createTabFull("Misc", false)

local function createColumns(page)
    local left = Instance.new("Frame") left.Size = UDim2.new(0.485, 0, 1, 0) left.BackgroundTransparency = 1 left.ZIndex = 2 left.Parent = page
    local lList = Instance.new("UIListLayout") lList.Padding = UDim.new(0, 6) lList.SortOrder = Enum.SortOrder.LayoutOrder lList.Parent = left
    local right = Instance.new("Frame") right.Size = UDim2.new(0.485, 0, 1, 0) right.Position = UDim2.new(0.515, 0, 0, 0) right.BackgroundTransparency = 1 right.ZIndex = 2 right.Parent = page
    local rList = Instance.new("UIListLayout") rList.Padding = UDim.new(0, 6) rList.SortOrder = Enum.SortOrder.LayoutOrder rList.Parent = right
    return left, right
end

local cLeft, cRight = createColumns(combatPage)
local eLeft, eRight = createColumns(espPage)
local mLeft, mRight = createColumns(miscPage)

local function createSection(parent, title)
    local sec = Instance.new("Frame")
    sec.AutomaticSize = Enum.AutomaticSize.Y
    sec.Size = UDim2.new(1, 0, 0, 0)
    sec.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    sec.BackgroundTransparency = 0.2
    sec.BorderSizePixel = 0
    sec.ZIndex = 2
    sec.Parent = parent

    local secCorner = Instance.new("UICorner") secCorner.CornerRadius = UDim.new(0, 5) secCorner.Parent = sec
    local secStroke = Instance.new("UIStroke") secStroke.Color = Color3.fromRGB(0, 180, 255) secStroke.Thickness = 1 secStroke.Parent = sec
    local secTitle = Instance.new("TextLabel") secTitle.Size = UDim2.new(1, -10, 0, 20) secTitle.Position = UDim2.new(0, 5, 0, 2) secTitle.BackgroundTransparency = 1 secTitle.Text = title secTitle.TextColor3 = Color3.fromRGB(180, 230, 255) secTitle.Font = Enum.Font.Code secTitle.TextSize = 10 secTitle.TextXAlignment = Enum.TextXAlignment.Left secTitle.ZIndex = 2 secTitle.Parent = sec
    local line = Instance.new("Frame") line.Size = UDim2.new(1, -10, 0, 1) line.Position = UDim2.new(0, 5, 0, 22) line.BackgroundColor3 = Color3.fromRGB(0, 180, 255) line.BorderSizePixel = 0 line.ZIndex = 2 line.Parent = sec

    local container = Instance.new("Frame")
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Size = UDim2.new(1, -10, 0, 0)
    container.Position = UDim2.new(0, 5, 0, 25)
    container.BackgroundTransparency = 1
    container.ZIndex = 2
    container.Parent = sec

    local layout = Instance.new("UIListLayout") layout.Padding = UDim.new(0, 4) layout.SortOrder = Enum.SortOrder.LayoutOrder layout.Parent = container
    local pad = Instance.new("UIPadding") pad.PaddingBottom = UDim.new(0, 5) pad.Parent = sec
    return container
end

local combatSec1 = createSection(cLeft, "God RageBot & Silent Aim")
local combatSec2 = createSection(cRight, "Wallbang & Hitbox Separate")
local espSec1 = createSection(eLeft, "ESP Features")
local espSec2 = createSection(eRight, "Crosshair & Gun Tracer")
local miscSec1 = createSection(mLeft, "Notifications & Bypass")
local miscSec2 = createSection(mRight, "Skin Customization")
local miscSec3 = createSection(mRight, "Movement Control")

local function createToggle(parent, text, order, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 26)
    btn.BackgroundTransparency = 1
    btn.Text = (defaultState and "[✔] " or "[ ] ")..text
    btn.TextColor3 = defaultState and Color3.fromRGB(180, 230, 255) or Color3.fromRGB(130, 145, 170)
    btn.Font = Enum.Font.Code
    btn.TextSize = 10
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    btn.ZIndex = 2
    btn.Parent = parent

    btn.MouseButton1Click:Connect(function()
        defaultState = not defaultState
        btn.Text = (defaultState and "[✔] " or "[ ] ")..text
        btn.TextColor3 = defaultState and Color3.fromRGB(180, 230, 255) or Color3.fromRGB(130, 145, 170)
        callback(defaultState)
    end)
    return btn
end

createToggle(combatSec1, "God Rage Bot (Fast)", 1, getgenv().Config.RageBot, function(v) getgenv().Config.RageBot = v; getgenv().Config.Enabled = v end)
createToggle(combatSec1, "Snap Head Aimbot", 2, getgenv().Config.Aimbot, function(v) getgenv().Config.Aimbot = v end)
createToggle(combatSec1, "Silent Aim (Ultra High)", 3, getgenv().Config.SilentAim, function(v) getgenv().Config.SilentAim = v; getgenv().Config.Enabled = v end)
createToggle(combatSec1, "Triggerbot (Instant)", 4, getgenv().Config.Triggerbot, function(v) getgenv().Config.Triggerbot = v; getgenv().Config.Enabled = v end)
createToggle(combatSec1, "All-Head (Forced)", 5, getgenv().Config.AllHead, function(v) getgenv().Config.AllHead = v end)

createToggle(combatSec2, "Wallbang (벽 관통 극대화)", 1, getgenv().Config.Wallbang, function(v) getgenv().Config.Wallbang = v end)
createToggle(combatSec2, "Hitbox Separate (히트박스 분리)", 2, getgenv().Config.HitboxSeparate, function(v) getgenv().Config.HitboxSeparate = v end)
createToggle(combatSec2, "Body Teleport (적 몸 안 TP)", 3, getgenv().Config.BodyTeleport, function(v) getgenv().Config.BodyTeleport = v end)
createToggle(combatSec2, "Rapid Fire (Fast RPM)", 4, getgenv().Config.RapidFire, function(v) getgenv().Config.RapidFire = v; getgenv().Config.Enabled = v end)
createToggle(combatSec2, "Prediction (Moving Target)", 5, getgenv().Config.Prediction, function(v) getgenv().Config.Prediction = v end)
createToggle(combatSec2, "No Recoil & No Spread", 6, getgenv().Config.NoRecoil, function(v) getgenv().Config.NoRecoil = v; getgenv().Config.NoSpread = v end)

createToggle(espSec1, "Corner Box ESP", 1, getgenv().Config.CornerBoxESP, function(v) getgenv().Config.CornerBoxESP = v end)
createToggle(espSec1, "Name ESP", 2, getgenv().Config.NameESP, function(v) getgenv().Config.NameESP = v end)
createToggle(espSec1, "Health Bar ESP", 3, getgenv().Config.HealthESP, function(v) getgenv().Config.HealthESP = v end)

createToggle(espSec2, "Rainbow Rotating Crosshair", 1, getgenv().Config.RainbowCrosshair, function(v) getgenv().Config.RainbowCrosshair = v end)
createToggle(espSec2, "Gun to Target Tracer (실 연결)", 2, getgenv().Config.GunTracer, function(v) getgenv().Config.GunTracer = v end)

createToggle(miscSec1, "Hit Log Notification (4s)", 1, getgenv().Config.HitNotify, function(v) getgenv().Config.HitNotify = v end)
createToggle(miscSec1, "Anti-Cheat Bypass (Upgraded)", 2, getgenv().Config.AntiCheatBypass, function(v) getgenv().Config.AntiCheatBypass = v end)

createToggle(miscSec2, "All Skins", 1, getgenv().Config.AllSkins, function(v) getgenv().Config.AllSkins = v end)

createToggle(miscSec3, "Fly (Speed: 70)", 1, getgenv().Config.Fly, function(v) updateFly(v) end)
createToggle(miscSec3, "Noclip", 2, getgenv().Config.Noclip, function(v) getgenv().Config.Noclip = v end)

toggleMenuBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

print("RayV3 10B Ultra v7.5 Loaded Successfully! (Dynamic Signature & Wallbang Fix Applied)")
