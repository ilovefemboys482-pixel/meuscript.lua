--[[
    ND ULTIMATE HUB + JOGOS EXTERNOS
    Sistema de Aimbot Completo para Mobile
    Compatível com: Arsenal, Counter Blox, Bad Business, etc.
]]

-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Mouse = LocalPlayer:GetMouse()
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

-- UI Modal
local Modal = loadstring(game:HttpGet("https://github.com/lxte/Modal/releases/latest/download/main.lua"))()
local Window = Modal:CreateWindow({
    Title = "🌪️ ND ULTIMATE HUB",
    SubTitle = "Natural Disaster + External Games",
    Size = UDim2.fromOffset(480, 550),
    MinimumSize = Vector2.new(300, 400),
    Transparency = 0,
    Icon = "rbxassetid://68073547",
})

-- ==================== VARIÁVEIS GLOBAIS ====================
-- Movement
local FlyEnabled = false
local FlySpeed = 100
local Flying = false
local FlyBodyVelocity = nil
local NoclipEnabled = false
local WalkspeedEnabled = false
local WalkspeedValue = 50
local JumpPowerEnabled = false
local JumpPowerValue = 100
local BHopEnabled = false
local InfiniteJumpEnabled = false

-- Spin Bot
local SpinBotEnabled = false
local SpinBotMode = "Normal"
local SpinBotSpeed = 20

-- ESP
local ESPEnabled = false
local ESPBoxEnabled = true
local ESPNameEnabled = true
local ESPDistanceEnabled = true
local ESPHealthEnabled = true
local ESPTracelineEnabled = false
local ESPObjects = {}

-- Move Blocks
local MoveBlocksEnabled = false
local SelectedBlock = nil
local BlockDragSpeed = 0.5
local BlockDragConnection = nil

-- ==================== AIMBOT COMPLETO (JOGOS EXTERNOS) ====================
-- Aimbot Variables
local AimbotEnabled = false
local AimbotType = "Default"
local SilentAimEnabled = false
local TriggerBotEnabled = false
local CurrentTarget = nil
local AimPart = "Head"
local AimbotFOV = 150
local AimbotSmoothness = 0.25
local AimbotPrediction = 0
local AimbotTeamCheck = true
local AimbotVisibleCheck = true
local AimbotWallbang = false
local AimbotRange = 500
local AimbotPriority = "Distance" -- Distance, Crosshair, Health

-- FOV Circle
local FOVCircleEnabled = false
local FOVCircle = nil

-- Hitbox
local HitboxExtenderEnabled = false
local HitboxScale = 1.5

-- Visuals
local ChamsEnabled = false
local ChamsObjects = {}
local GlowEnabled = false

-- Misc
local AntiAFKEnabled = false
local AutoCollectEnabled = false
local AutoRespawnEnabled = false

-- Mobile Buttons
local MobileButtons = {}
local MobileUI = nil

-- ==================== FUNÇÕES UTILITÁRIAS ====================

local function IsPlayerAlive(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function IsTeammate(player)
    if not AimbotTeamCheck then return false end
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team == player.Team
    end
    return false
end

local function IsVisible(player, part)
    if not AimbotVisibleCheck then return true end
    if not player or not player.Character then return false end
    
    local origin = Camera.CFrame.Position
    local target = part and part.Position or (player.Character:FindFirstChild(AimPart) and player.Character[AimPart].Position)
    if not target then return false end
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local ray = Workspace:Raycast(origin, (target - origin).unit * (origin - target).magnitude, params)
    return ray == nil or (ray.Instance and ray.Instance:IsDescendantOf(player.Character))
end

local function GetClosestPlayerToCursor()
    local closestDistance = math.huge
    local closestPlayer = nil
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsPlayerAlive(player) and not IsTeammate(player) then
            local targetChar = player.Character
            if targetChar then
                local aimPartObj = targetChar:FindFirstChild(AimPart) or targetChar:FindFirstChild("HumanoidRootPart")
                if aimPartObj then
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(aimPartObj.Position)
                    if onScreen then
                        local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).magnitude
                        if distance < closestDistance and distance <= AimbotFOV then
                            local range = (Camera.CFrame.Position - aimPartObj.Position).magnitude
                            if range <= AimbotRange then
                                if IsVisible(player, aimPartObj) or AimbotWallbang then
                                    closestDistance = distance
                                    closestPlayer = player
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function GetClosestPlayerByDistance()
    local closestDistance = math.huge
    local closestPlayer = nil
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsPlayerAlive(player) and not IsTeammate(player) then
            local targetChar = player.Character
            if targetChar then
                local aimPartObj = targetChar:FindFirstChild(AimPart) or targetChar:FindFirstChild("HumanoidRootPart")
                if aimPartObj then
                    local distance = (rootPart.Position - aimPartObj.Position).magnitude
                    if distance < closestDistance and distance <= AimbotRange then
                        if IsVisible(player, aimPartObj) or AimbotWallbang then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function GetPlayerByLowestHealth()
    local lowestHealth = math.huge
    local lowestPlayer = nil
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsPlayerAlive(player) and not IsTeammate(player) then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                local health = humanoid.Health
                if health < lowestHealth then
                    local range = (Camera.CFrame.Position - (player.Character:FindFirstChild(AimPart) or player.Character.HumanoidRootPart).Position).magnitude
                    if range <= AimbotRange then
                        if IsVisible(player, player.Character:FindFirstChild(AimPart)) or AimbotWallbang then
                            lowestHealth = health
                            lowestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return lowestPlayer
end

local function GetPlayerFromMouse()
    local mousePos = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    if LocalPlayer.Character then
        params.FilterDescendantsInstances = {LocalPlayer.Character}
    end
    
    local raycastResult = Workspace:Raycast(ray.Origin, ray.Direction * AimbotRange, params)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        local character = hitPart:FindFirstAncestorWhichIsA("Model")
        if character then
            local player = Players:GetPlayerFromCharacter(character)
            if player and player ~= LocalPlayer and IsPlayerAlive(player) and not IsTeammate(player) then
                return player
            end
        end
    end
    return nil
end

local function GetPredictedPosition(player)
    if not player or not player.Character then return nil end
    
    local aimPartObj = player.Character:FindFirstChild(AimPart) or player.Character:FindFirstChild("HumanoidRootPart")
    if not aimPartObj then return nil end
    
    local currentPos = aimPartObj.Position
    local velocity = aimPartObj.AssemblyLinearVelocity
    
    if velocity.Magnitude > 0 and AimbotPrediction > 0 then
        local distance = (Camera.CFrame.Position - currentPos).Magnitude
        local bulletSpeed = 2000 -- Velocidade da bala padrão
        local timeToImpact = distance / bulletSpeed
        return currentPos + (velocity * timeToImpact * AimbotPrediction)
    end
    
    return currentPos
end

local function SmoothCameraTo(targetCFrame)
    if not AimbotEnabled then return end
    
    local currentCFrame = Camera.CFrame
    local lerpedCFrame = currentCFrame:Lerp(targetCFrame, AimbotSmoothness)
    Camera.CFrame = lerpedCFrame
end

-- Aimbot Principal
local function UpdateAimbot()
    if not AimbotEnabled then return end
    
    local isShooting = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or 
                        (GuiService:IsTenFootInterface() and UserInputService:GetTouchEnabled())
    
    if isShooting or AimbotType == "Always" then
        if not CurrentTarget or not IsPlayerAlive(CurrentTarget) or IsTeammate(CurrentTarget) then
            if AimbotPriority == "Crosshair" then
                CurrentTarget = GetPlayerFromMouse() or GetClosestPlayerToCursor()
            elseif AimbotPriority == "Health" then
                CurrentTarget = GetPlayerByLowestHealth()
            else -- Distance
                CurrentTarget = GetClosestPlayerByDistance()
            end
        end
        
        if CurrentTarget and IsPlayerAlive(CurrentTarget) and not IsTeammate(CurrentTarget) then
            local targetChar = CurrentTarget.Character
            local aimPartObj = targetChar:FindFirstChild(AimPart) or targetChar:FindFirstChild("HumanoidRootPart")
            if aimPartObj then
                local targetPos = GetPredictedPosition(CurrentTarget)
                if targetPos then
                    local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                    
                    if AimbotType == "Silent" then
                        pcall(function()
                            Mouse.Hit = CFrame.new(Camera.CFrame.Position + (Camera.CFrame.LookVector * 1000), targetPos)
                        end)
                    elseif AimbotType == "Smooth" then
                        SmoothCameraTo(targetCFrame)
                    else -- Default
                        Camera.CFrame = targetCFrame
                    end
                end
            end
        else
            CurrentTarget = nil
        end
    else
        CurrentTarget = nil
    end
end

-- Trigger Bot
local function UpdateTriggerBot()
    if not TriggerBotEnabled then return end
    
    local target = GetPlayerFromMouse() or GetClosestPlayerToCursor()
    if target and IsPlayerAlive(target) and not IsTeammate(target) then
        pcall(function()
            mouse1press()
            task.wait(0.05)
            mouse1release()
        end)
    end
end

-- FOV Circle
local function CreateFOVCircle()
    if FOVCircle then
        FOVCircle:Remove()
    end
    
    if not FOVCircleEnabled then return end
    
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Radius = AimbotFOV
    FOVCircle.Thickness = 2
    FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    FOVCircle.Filled = false
    FOVCircle.NumSides = 64
    FOVCircle.Visible = true
    FOVCircle.Transparency = 0.5
end

local function UpdateFOVCircle()
    if FOVCircle and FOVCircleEnabled then
        FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        FOVCircle.Radius = AimbotFOV
    end
end

-- Hitbox Extender
local function UpdateHitboxExtender()
    if not HitboxExtenderEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    local originalSize = part.Size
                    part.Size = originalSize * HitboxScale
                end
            end
        end
    end
end

-- Chams
local function CreateChams(player)
    if not player or not player.Character then return end
    
    for _, part in ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local highlight = Instance.new("Highlight")
            highlight.Parent = part
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0.3
            
            if not ChamsObjects[player] then
                ChamsObjects[player] = {}
            end
            table.insert(ChamsObjects[player], highlight)
        end
    end
end

local function RemoveChams(player)
    if ChamsObjects[player] then
        for _, highlight in ipairs(ChamsObjects[player]) do
            if highlight then highlight:Destroy() end
        end
        ChamsObjects[player] = nil
    end
end

local function ToggleChams(state)
    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateChams(player)
            end
        end
    else
        for player, _ in pairs(ChamsObjects) do
            RemoveChams(player)
        end
    end
end

-- Glow Effect
local function UpdateGlow()
    if not GlowEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    local glow = part:FindFirstChild("Glow")
                    if not glow then
                        glow = Instance.new("BloomEffect")
                        glow.Name = "Glow"
                        glow.Intensity = 0.5
                        glow.Size = 16
                        glow.Parent = part
                    end
                end
            end
        end
    end
end

-- ==================== MOVIMENTAÇÃO (Natural Disaster) ====================

local function UpdateWalkspeed()
    if WalkspeedEnabled then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = WalkspeedValue
            end
        end
    end
end

local function UpdateJumpPower()
    if JumpPowerEnabled then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = JumpPowerValue
            end
        end
    end
end

local function StartFly()
    if Flying then return end
    Flying = true
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
    
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        FlyBodyVelocity.Parent = rootPart
    end
    
    local function updateFly()
        while Flying and FlyBodyVelocity and FlyBodyVelocity.Parent do
            local moveDirection = Vector3.new(
                (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
                (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0),
                (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
            )
            
            local cameraCFrame = Camera.CFrame
            moveDirection = cameraCFrame:VectorToWorldSpace(moveDirection)
            FlyBodyVelocity.Velocity = moveDirection * FlySpeed
            RunService.RenderStepped:Wait()
        end
    end
    
    coroutine.wrap(updateFly)()
end

local function StopFly()
    Flying = false
    if FlyBodyVelocity then
        FlyBodyVelocity:Destroy()
        FlyBodyVelocity = nil
    end
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

local function UpdateNoclip()
    if not NoclipEnabled then return end
    
    local character = LocalPlayer.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

local function UpdateBHop()
    if not BHopEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.05)
    end
end

local function UpdateInfiniteJump()
    if not InfiniteJumpEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end
    
    local connection
    connection = UserInputService.JumpRequest:Connect(function()
        if InfiniteJumpEnabled and humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- ==================== SPIN BOT ====================

local function UpdateSpinBot()
    if not SpinBotEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local angle = SpinBotSpeed
        if SpinBotMode == "Fast" then
            angle = SpinBotSpeed * 2
        elseif SpinBotMode == "Crazy" then
            angle = SpinBotSpeed * 3
        elseif SpinBotMode == "Backwards" then
            angle = -SpinBotSpeed
        elseif SpinBotMode == "Earthquake" then
            rootPart.CFrame = rootPart.CFrame * CFrame.Angles(math.rad(angle), math.rad(angle), 0)
            return
        end
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(angle), 0)
    end
end

-- ==================== MOVE BLOCKS ====================

local function GetNearestBlock()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local closestBlock = nil
    local closestDistance = math.huge
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" and obj.Parent ~= character then
            if not obj:IsDescendantOf(Players) then
                local distance = (rootPart.Position - obj.Position).magnitude
                if distance < closestDistance and distance < 50 then
                    closestDistance = distance
                    closestBlock = obj
                end
            end
        end
    end
    
    return closestBlock
end

local function StartMovingBlock(block)
    if not block then return end
    
    SelectedBlock = block
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "BlockHighlight"
    highlight.FillColor = Color3.fromRGB(255, 100, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Parent = block
    
    BlockDragConnection = RunService.RenderStepped:Connect(function()
        if not MoveBlocksEnabled or not SelectedBlock or not SelectedBlock.Parent then
            if BlockDragConnection then BlockDragConnection:Disconnect() end
            return
        end
        
        local mousePos = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = {LocalPlayer.Character, SelectedBlock}
        
        local raycastResult = Workspace:Raycast(ray.Origin, ray.Direction * 500, params)
        
        if raycastResult then
            local targetPos = raycastResult.Position
            local newPos = targetPos + Vector3.new(0, SelectedBlock.Size.Y / 2, 0)
            
            local tween = TweenService:Create(SelectedBlock, TweenInfo.new(BlockDragSpeed, Enum.EasingStyle.Quad), {
                Position = newPos
            })
            tween:Play()
        end
    end)
end

local function StopMovingBlock()
    if BlockDragConnection then
        BlockDragConnection:Disconnect()
        BlockDragConnection = nil
    end
    
    if SelectedBlock then
        local highlight = SelectedBlock:FindFirstChild("BlockHighlight")
        if highlight then highlight:Destroy() end
        SelectedBlock = nil
    end
end

local function TeleportBlockToPlayer(block)
    if not block or not LocalPlayer.Character then return end
    
    local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local tween = TweenService:Create(block, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Position = rootPart.Position + Vector3.new(0, 3, 0)
        })
        tween:Play()
    end
end

-- ==================== ESP ====================

local function CreateESP(player)
    if not player or not player.Character then return end
    
    local character = player.Character
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    local espFolder = Instance.new("Folder")
    espFolder.Name = "ESP_" .. player.UserId
    espFolder.Parent = head
    
    if ESPBoxEnabled then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "Box"
        box.Adornee = character:FindFirstChild("HumanoidRootPart") or head
        box.Size = Vector3.new(4, 5, 2)
        box.Color3 = Color3.fromRGB(255, 0, 0)
        box.Transparency = 0.5
        box.ZIndex = 10
        box.AlwaysOnTop = true
        box.Parent = espFolder
    end
    
    if ESPNameEnabled then
        local nameBillboard = Instance.new("BillboardGui")
        nameBillboard.Name = "Name"
        nameBillboard.Adornee = head
        nameBillboard.Size = UDim2.new(0, 200, 0, 30)
        nameBillboard.StudsOffset = Vector3.new(0, 2.5, 0)
        nameBillboard.AlwaysOnTop = true
        nameBillboard.Parent = espFolder
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Text = player.Name
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.Parent = nameBillboard
    end
    
    if ESPHealthEnabled then
        local healthBillboard = Instance.new("BillboardGui")
        healthBillboard.Name = "Health"
        healthBillboard.Adornee = head
        healthBillboard.Size = UDim2.new(0, 60, 0, 8)
        healthBillboard.StudsOffset = Vector3.new(0, 1.5, 0)
        healthBillboard.AlwaysOnTop = true
        healthBillboard.Parent = espFolder
        
        local healthBg = Instance.new("Frame")
        healthBg.Size = UDim2.new(1, 0, 1, 0)
        healthBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        healthBg.BackgroundTransparency = 0.5
        healthBg.BorderSizePixel = 0
        healthBg.Parent = healthBillboard
        
        local healthBar = Instance.new("Frame")
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthBar.BorderSizePixel = 0
        healthBar.Parent = healthBg
        
        ESPObjects[player] = ESPObjects[player] or {}
        ESPObjects[player].HealthBar = healthBar
        
        spawn(function()
            while ESPObjects[player] and player.Character do
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and ESPObjects[player].HealthBar then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    ESPObjects[player].HealthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
                    
                    if healthPercent > 0.6 then
                        ESPObjects[player].HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    elseif healthPercent > 0.3 then
                        ESPObjects[player].HealthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                    else
                        ESPObjects[player].HealthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
    
    if ESPDistanceEnabled then
        local distBillboard = Instance.new("BillboardGui")
        distBillboard.Name = "Distance"
        distBillboard.Adornee = head
        distBillboard.Size = UDim2.new(0, 100, 0, 20)
        distBillboard.StudsOffset = Vector3.new(0, -1, 0)
        distBillboard.AlwaysOnTop = true
        distBillboard.Parent = espFolder
        
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 1, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        distLabel.TextSize = 12
        distLabel.Font = Enum.Font.Gotham
        distLabel.Parent = distBillboard
        
        ESPObjects[player] = ESPObjects[player] or {}
        ESPObjects[player].DistanceLabel = distLabel
        
        spawn(function()
            while ESPObjects[player] and LocalPlayer.Character do
                local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart and targetRoot and ESPObjects[player].DistanceLabel then
                    local distance = math.floor((rootPart.Position - targetRoot.Position).magnitude)
                    ESPObjects[player].DistanceLabel.Text = distance .. "m"
                end
                task.wait(0.2)
            end
        end)
    end
    
    if ESPTracelineEnabled then
        local line = Instance.new("LineHandleAdornment")
        line.Name = "Traceline"
        line.Adornee = character:FindFirstChild("HumanoidRootPart") or head
        line.Thickness = 2
        line.Color3 = Color3.fromRGB(255, 0, 0)
        line.ZIndex = 10
        line.AlwaysOnTop = true
        line.Parent = espFolder
    end
    
    ESPObjects[player] = ESPObjects[player] or {}
    ESPObjects[player].Folder = espFolder
end

local function RemoveESP(player)
    if ESPObjects[player] and ESPObjects[player].Folder then
        ESPObjects[player].Folder:Destroy()
        ESPObjects[player] = nil
    end
end

local function ToggleESP(state)
    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESP(player)
            end
        end
    else
        for player, _ in pairs(ESPObjects) do
            RemoveESP(player)
        end
    end
end

-- ==================== ANTI AFK ====================

local function StartAntiAFK()
    while AntiAFKEnabled do
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        task.wait(60)
    end
end

-- ==================== MOBILE BUTTONS ====================

local function CreateMobileButtons()
    if MobileUI then return end
    
    MobileUI = Instance.new("ScreenGui")
    MobileUI.Name = "MobileButtons"
    MobileUI.Parent = game:GetService("CoreGui")
    MobileUI.Enabled = true
    
    local buttonSize = UDim2.new(0, 70, 0, 70)
    
    -- Aimbot Button
    local aimBtn = Instance.new("TextButton")
    aimBtn.Size = buttonSize
    aimBtn.Position = UDim2.new(0, 10, 1, -80)
    aimBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    aimBtn.Text = "🎯\nAIM"
    aimBtn.TextSize = 12
    aimBtn.TextWrapped = true
    aimBtn.Font = Enum.Font.GothamBold
    aimBtn.Parent = MobileUI
    
    aimBtn.MouseButton1Click:Connect(function()
        AimbotEnabled = not AimbotEnabled
        aimBtn.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(200, 50, 50)
        Window:Notify({
            Title = "Aimbot",
            Description = AimbotEnabled and "✅ Ativado" or "❌ Desativado",
            Duration = 2,
            Type = AimbotEnabled and "Success" or "Info"
        })
    end)
    
    -- Trigger Bot Button
    local triggerBtn = Instance.new("TextButton")
    triggerBtn.Size = buttonSize
    triggerBtn.Position = UDim2.new(0, 10, 1, -160)
    triggerBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    triggerBtn.Text = "🔫\nTRIGGER"
    triggerBtn.TextSize = 10
    triggerBtn.TextWrapped = true
    triggerBtn.Font = Enum.Font.GothamBold
    triggerBtn.Parent = MobileUI
    
    triggerBtn.MouseButton1Click:Connect(function()
        TriggerBotEnabled = not TriggerBotEnabled
        triggerBtn.BackgroundColor3 = TriggerBotEnabled and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(100, 100, 100)
    end)
    
    -- Fly Button
    local flyBtn = Instance.new("TextButton")
    flyBtn.Size = buttonSize
    flyBtn.Position = UDim2.new(1, -80, 1, -80)
    flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
    flyBtn.Text = "🕊️\nFLY"
    flyBtn.TextSize = 12
    flyBtn.TextWrapped = true
    flyBtn.Font = Enum.Font.GothamBold
    flyBtn.Parent = MobileUI
    
    flyBtn.MouseButton1Click:Connect(function()
        if FlyEnabled then
            StopFly()
            FlyEnabled = false
            flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
        else
            StartFly()
            FlyEnabled = true
            flyBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
        end
    end)
    
    -- Spin Button
    local spinBtn = Instance.new("TextButton")
    spinBtn.Size = buttonSize
    spinBtn.Position = UDim2.new(1, -80, 1, -160)
    spinBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    spinBtn.Text = "🌀\nSPIN"
    spinBtn.TextSize = 12
    spinBtn.TextWrapped = true
    spinBtn.Font = Enum.Font.GothamBold
    spinBtn.Parent = MobileUI
    
    spinBtn.MouseButton1Click:Connect(function()
        SpinBotEnabled = not SpinBotEnabled
        spinBtn.BackgroundColor3 = SpinBotEnabled and Color3.fromRGB(200, 100, 100) or Color3.fromRGB(150, 50, 50)
    end)
    
    -- Noclip Button
    local noclipBtn = Instance.new("TextButton")
    noclipBtn.Size = buttonSize
    noclipBtn.Position = UDim2.new(0.5, -35, 1, -80)
    noclipBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    noclipBtn.Text = "🧱\nNOCLIP"
    noclipBtn.TextSize = 12
    noclipBtn.TextWrapped = true
    noclipBtn.Font = Enum.Font.GothamBold
    noclipBtn.Parent = MobileUI
    
    noclipBtn.MouseButton1Click:Connect(function()
        NoclipEnabled = not NoclipEnabled
        noclipBtn.BackgroundColor3 = NoclipEnabled and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(100, 100, 100)
    end)
    
    MobileButtons = {
        Aimbot = aimBtn,
        Trigger = triggerBtn,
        Fly = flyBtn,
        Spin = spinBtn,
        Noclip = noclipBtn
    }
end

local function DestroyMobileButtons()
    if MobileUI then
        MobileUI:Destroy()
        MobileUI = nil
        MobileButtons = {}
    end
end

-- ==================== UI - JOGOS EXTERNOS (AIMBOT COMPLETO) ====================
local ExternalTab = Window:AddTab("🎮 JOGOS EXTERNOS")

ExternalTab:New("Title")({ Title = "🎯 AIMBOT COMPLETO" })

ExternalTab:New("Toggle")({
    Title = "🔒 Enable Aimbot",
    Description = "Ativa o aimbot para jogos de tiro",
    DefaultValue = false,
    Callback = function(Value)
        AimbotEnabled = Value
    end,
})

ExternalTab:New("Dropdown")({
    Title = "🎯 Aimbot Mode",
    Description = "Modo de funcionamento do aimbot",
    Options = { "Default", "Smooth", "Silent", "Always" },
    Default = "Default",
    Callback = function(Value)
        AimbotType = Value
    end,
})

ExternalTab:New("Dropdown")({
    Title = "🎯 Aim Priority",
    Description = "Critério para escolher o alvo",
    Options = { "Distance", "Crosshair", "Health" },
    Default = "Distance",
    Callback = function(Value)
        AimbotPriority = Value
    end,
})

ExternalTab:New("Dropdown")({
    Title = "🎯 Aim Part",
    Description = "Parte do corpo para mirar",
    Options = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Neck" },
    Default = "Head",
    Callback = function(Value)
        AimPart = Value
    end,
})

ExternalTab:New("Slider")({
    Title = "📏 Aimbot FOV",
    Description = "Campo de visão do aimbot (círculo)",
    Default = 150,
    Minimum = 30,
    Maximum = 300,
    Callback = function(Amount)
        AimbotFOV = Amount
        if FOVCircle then
            FOVCircle.Radius = Amount
        end
    end,
})

ExternalTab:New("Slider")({
    Title = "🎯 Aimbot Smoothness",
    Description = "Suavidade da mira (0 = instantâneo)",
    Default = 0.25,
    Minimum = 0,
    Maximum = 1,
    DecimalCount = 2,
    Callback = function(Amount)
        AimbotSmoothness = Amount
    end,
})

ExternalTab:New("Slider")({
    Title = "🔮 Prediction",
    Description = "Previsão de movimento do alvo",
    Default = 0,
    Minimum = 0,
    Maximum = 1,
    DecimalCount = 2,
    Callback = function(Amount)
        AimbotPrediction = Amount
    end,
})

ExternalTab:New("Slider")({
    Title = "📏 Aimbot Range",
    Description = "Distância máxima para mirar",
    Default = 500,
    Minimum = 100,
    Maximum = 1000,
    Callback = function(Amount)
        AimbotRange = Amount
    end,
})

ExternalTab:New("Title")({ Title = "⚙️ AIMBOT CONFIG" })

ExternalTab:New("Toggle")({
    Title = "🤫 Trigger Bot",
    Description = "Atira automaticamente quando mira no inimigo",
    DefaultValue = false,
    Callback = function(Value)
        TriggerBotEnabled = Value
    end,
})

ExternalTab:New("Toggle")({
    Title = "👥 Team Check",
    Description = "Não mira em companheiros de time",
    DefaultValue = true,
    Callback = function(Value)
        AimbotTeamCheck = Value
    end,
})

ExternalTab:New("Toggle")({
    Title = "👁️ Visibility Check",
    Description = "Só mira em inimigos visíveis",
    DefaultValue = true,
    Callback = function(Value)
        AimbotVisibleCheck = Value
    end,
})

ExternalTab:New("Toggle")({
    Title = "🧱 Wallbang",
    Description = "Permite mirar através de paredes",
    DefaultValue = false,
    Callback = function(Value)
        AimbotWallbang = Value
    end,
})

ExternalTab:New("Title")({ Title = "🎯 VISUAIS" })

ExternalTab:New("Toggle")({
    Title = "🎯 FOV Circle",
    Description = "Mostra círculo do campo de visão",
    DefaultValue = false,
    Callback = function(Value)
        FOVCircleEnabled = Value
        if Value then
            CreateFOVCircle()
        elseif FOVCircle then
            FOVCircle:Remove()
            FOVCircle = nil
        end
    end,
})

ExternalTab:New("Toggle")({
    Title = "💪 Hitbox Extender",
    Description = "Aumenta o tamanho da hitbox dos inimigos",
    DefaultValue = false,
    Callback = function(Value)
        HitboxExtenderEnabled = Value
    end,
})

ExternalTab:New("Slider")({
    Title = "📦 Hitbox Scale",
    Description = "Tamanho da hitbox (1 = normal)",
    Default = 1.5,
    Minimum = 1,
    Maximum = 3,
    DecimalCount = 1,
    Callback = function(Amount)
        HitboxScale = Amount
    end,
})

ExternalTab:New("Toggle")({
    Title = "✨ Chams (Glow)",
    Description = "Destaca os inimigos com cor",
    DefaultValue = false,
    Callback = function(Value)
        ChamsEnabled = Value
        ToggleChams(Value)
    end,
})

ExternalTab:New("Toggle")({
    Title = "🌟 Glow Effect",
    Description = "Efeito de brilho nos inimigos",
    DefaultValue = false,
    Callback = function(Value)
        GlowEnabled = Value
    end,
})

-- ==================== UI - NATURAL DISASTER ====================
local MainTab = Window:AddTab("🌪️ NATURAL DISASTER")

MainTab:New("Title")({ Title = "🌀 MOVEMENT" })

MainTab:New("Toggle")({
    Title = "🕊️ Fly Mode",
    Description = "Voe pelo mapa (WASD + Space/Ctrl)",
    DefaultValue = false,
    Callback = function(Value)
        if Value then
            StartFly()
        else
            StopFly()
        end
        FlyEnabled = Value
    end,
})

MainTab:New("Slider")({
    Title = "✈️ Fly Speed",
    Description = "Velocidade do voo",
    Default = 100,
    Minimum = 50,
    Maximum = 500,
    Callback = function(Amount)
        FlySpeed = Amount
    end,
})

MainTab:New("Toggle")({
    Title = "🧱 Noclip",
    Description = "Atravessa paredes",
    DefaultValue = false,
    Callback = function(Value)
        NoclipEnabled = Value
    end,
})

MainTab:New("Toggle")({
    Title = "⚡ Custom Walk Speed",
    Description = "Altera a velocidade de andar",
    DefaultValue = false,
    Callback = function(Value)
        WalkspeedEnabled = Value
        UpdateWalkspeed()
    end,
})

MainTab:New("Slider")({
    Title = "💨 Walk Speed Value",
    Description = "Velocidade de andar",
    Default = 50,
    Minimum = 16,
    Maximum = 350,
    Callback = function(Amount)
        WalkspeedValue = Amount
        UpdateWalkspeed()
    end,
})

MainTab:New("Toggle")({
    Title = "🦘 Custom Jump Power",
    Description = "Altera a altura do pulo",
    DefaultValue = false,
    Callback = function(Value)
        JumpPowerEnabled = Value
        UpdateJumpPower()
    end,
})

MainTab:New("Slider")({
    Title = "🦘 Jump Power Value",
    Description = "Altura do pulo",
    Default = 100,
    Minimum = 50,
    Maximum = 300,
    Callback = function(Amount)
        JumpPowerValue = Amount
        UpdateJumpPower()
    end,
})

MainTab:New("Toggle")({
    Title = "🐰 Bunny Hop",
    Description = "Pula automaticamente ao correr",
    DefaultValue = false,
    Callback = function(Value)
        BHopEnabled = Value
    end,
})

MainTab:New("Toggle")({
    Title = "∞ Infinite Jump",
    Description = "Pulos infinitos",
    DefaultValue = false,
    Callback = function(Value)
        InfiniteJumpEnabled = Value
        UpdateInfiniteJump()
    end,
})

-- ==================== UI - SPIN BOT ====================
local SpinTab = Window:AddTab("🌀 SPIN BOT")

SpinTab:New("Title")({ Title = "🌀 SPIN BOT CONFIG" })

SpinTab:New("Toggle")({
    Title = "🔄 Enable Spin Bot",
    Description = "Faz seu personagem girar",
    DefaultValue = false,
    Callback = function(Value)
        SpinBotEnabled = Value
    end,
})

SpinTab:New("Dropdown")({
    Title = "🌀 Spin Mode",
    Description = "Modo de rotação",
    Options = { "Normal", "Fast", "Crazy", "Backwards", "Earthquake" },
    Default = "Normal",
    Callback = function(Value)
        SpinBotMode = Value
    end,
})

SpinTab:New("Slider")({
    Title = "⚡ Spin Speed",
    Description = "Velocidade da rotação",
    Default = 20,
    Minimum = 5,
    Maximum = 60,
    Callback = function(Amount)
        SpinBotSpeed = Amount
    end,
})

-- ==================== UI - MOVE BLOCKS ====================
local BlocksTab = Window:AddTab("📦 MOVE BLOCKS")

BlocksTab:New("Title")({ Title = "📦 MOVE BLOCKS SYSTEM" })

BlocksTab:New("Button")({
    Title = "🔍 Select Nearest Block",
    Description = "Seleciona o bloco mais próximo",
    Callback = function()
        local block = GetNearestBlock()
        if block then
            SelectedBlock = block
            Window:Notify({
                Title = "Block Selected",
                Description = "Selected: " .. block.Name,
                Duration = 3,
                Type = "Success"
            })
        else
            Window:Notify({
                Title = "Error",
                Description = "No block nearby!",
                Duration = 2,
                Type = "Error"
            })
        end
    end,
})

BlocksTab:New("Toggle")({
    Title = "🎯 Move Selected Block",
    Description = "Arraste o bloco com o mouse/dedo",
    DefaultValue = false,
    Callback = function(Value)
        MoveBlocksEnabled = Value
        if Value then
            if not SelectedBlock then
                SelectedBlock = GetNearestBlock()
            end
            if SelectedBlock then
                StartMovingBlock(SelectedBlock)
            else
                Window:Notify({
                    Title = "Error",
                    Description = "No block selected!",
                    Duration = 2,
                    Type = "Error"
                })
                MoveBlocksEnabled = false
            end
        else
            StopMovingBlock()
        end
    end,
})

BlocksTab:New("Slider")({
    Title = "📦 Move Speed",
    Description = "Velocidade de movimentação do bloco",
    Default = 0.5,
    Minimum = 0.1,
    Maximum = 2,
    DecimalCount = 2,
    Callback = function(Amount)
        BlockDragSpeed = Amount
    end,
})

BlocksTab:New("Button")({
    Title = "📍 Teleport Block to You",
    Description = "Teleporta o bloco selecionado até você",
    Callback = function()
        if SelectedBlock then
            TeleportBlockToPlayer(SelectedBlock)
            Window:Notify({
                Title = "Teleport",
                Description = "Block teleported to you!",
                Duration = 2,
                Type = "Success"
            })
        else
            Window:Notify({
                Title = "Error",
                Description = "No block selected!",
                Duration = 2,
                Type = "Error"
            })
        end
    end,
})

-- ==================== UI - ESP ====================
local ESPTab = Window:AddTab("👁️ ESP")

ESPTab:New("Title")({ Title = "📦 ESP CONFIG" })

ESPTab:New("Toggle")({
    Title = "👁️ Enable ESP",
    Description = "Mostra informações dos jogadores",
    DefaultValue = false,
    Callback = function(Value)
        ESPEnabled = Value
        ToggleESP(Value)
    end,
})

ESPTab:New("Toggle")({
    Title = "📦 ESP Box",
    Description = "Mostra caixa ao redor do player",
    DefaultValue = true,
    Callback = function(Value)
        ESPBoxEnabled = Value
        if ESPEnabled then
            ToggleESP(false)
            ToggleESP(true)
        end
    end,
})

ESPTab:New("Toggle")({
    Title = "📝 ESP Name",
    Description = "Mostra o nome do player",
    DefaultValue = true,
    Callback = function(Value)
        ESPNameEnabled = Value
        if ESPEnabled then
            ToggleESP(false)
            ToggleESP(true)
        end
    end,
})

ESPTab:New("Toggle")({
    Title = "❤️ ESP Health",
    Description = "Mostra a barra de vida",
    DefaultValue = true,
    Callback = function(Value)
        ESPHealthEnabled = Value
        if ESPEnabled then
            ToggleESP(false)
            ToggleESP(true)
        end
    end,
})

ESPTab:New("Toggle")({
    Title = "📏 ESP Distance",
    Description = "Mostra a distância até o player",
    DefaultValue = true,
    Callback = function(Value)
        ESPDistanceEnabled = Value
        if ESPEnabled then
            ToggleESP(false)
            ToggleESP(true)
        end
    end,
})

ESPTab:New("Toggle")({
    Title = "📏 Traceline",
    Description = "Mostra linha do centro até o player",
    DefaultValue = false,
    Callback = function(Value)
        ESPTracelineEnabled = Value
        if ESPEnabled then
            ToggleESP(false)
            ToggleESP(true)
        end
    end,
})

-- ==================== UI - MISC ====================
local MiscTab = Window:AddTab("⚙️ MISC")

MiscTab:New("Title")({ Title = "🛡️ PROTECTION" })

MiscTab:New("Toggle")({
    Title = "💤 Anti AFK",
    Description = "Previne ser desconectado por inatividade",
    DefaultValue = false,
    Callback = function(Value)
        AntiAFKEnabled = Value
        if Value then
            coroutine.wrap(StartAntiAFK)()
        end
    end,
})

MiscTab:New("Toggle")({
    Title = "🔄 Auto Respawn",
    Description = "Respawna automaticamente ao morrer",
    DefaultValue = false,
    Callback = function(Value)
        AutoRespawnEnabled = Value
        if Value then
            LocalPlayer.CharacterAdded:Connect(function()
                Window:Notify({
                    Title = "Auto Respawn",
                    Description = "You respawned!",
                    Duration = 2,
                    Type = "Success"
                })
            end)
        end
    end,
})

MiscTab:New("Title")({ Title = "📱 MOBILE" })

MiscTab:New("Toggle")({
    Title = "📱 Mobile Buttons",
    Description = "Mostra botões na tela para mobile",
    DefaultValue = false,
    Callback = function(Value)
        if Value then
            CreateMobileButtons()
        else
            DestroyMobileButtons()
        end
    end,
})

MiscTab:New("Button")({
    Title = "🔄 Reset Character",
    Description = "Respawna o personagem",
    Callback = function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    end,
})

-- ==================== UI - SETTINGS ====================
local SettingsTab = Window:AddTab("🎨 SETTINGS")

SettingsTab:New("Title")({ Title = "🎨 THEMES" })

SettingsTab:New("Dropdown")({
    Title = "Theme",
    Description = "Escolha o tema da interface",
    Options = { "Light", "Dark", "Midnight", "Rose", "Emerald" },
    Callback = function(Theme)
        Window:SetTheme(Theme)
    end,
})

SettingsTab:New("Slider")({
    Title = "📊 UI Transparency",
    Description = "Transparência da interface",
    Default = 0,
    Minimum = 0,
    Maximum = 0.8,
    DecimalCount = 2,
    Callback = function(Amount)
        Window:SetTransparency(Amount)
    end,
})

-- ==================== RENDER LOOP ====================
RunService.RenderStepped:Connect(function()
    pcall(function()
        UpdateAimbot()
        UpdateTriggerBot()
        UpdateSpinBot()
        UpdateFOVCircle()
        UpdateWalkspeed()
        UpdateJumpPower()
        UpdateNoclip()
        UpdateBHop()
        UpdateHitboxExtender()
        UpdateGlow()
    end)
end)

-- Atualizar ESP quando players entram
Players.PlayerAdded:Connect(function(player)
    if ESPEnabled then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            CreateESP(player)
        end)
        if player.Character then
            CreateESP(player)
        end
    end
    
    if ChamsEnabled then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            CreateChams(player)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
    RemoveChams(player)
end)

-- Resetar variáveis quando o personagem local respawna
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)
    
    if WalkspeedEnabled then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = WalkspeedValue
        end
    end
    
    if JumpPowerEnabled then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = JumpPowerValue
        end
    end
    
    if NoclipEnabled then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    if Flying then
        StopFly()
        StartFly()
    end
end)

-- Ativar aba principal
Window:SetTab("🎮 JOGOS EXTERNOS")
Window:SetTheme("Dark")

-- Notificação inicial
Window:Notify({
    Title = "🌪️ ND ULTIMATE HUB",
    Description = "Aimbot Completo + Mobile Buttons Carregados!",
    Duration = 5,
    Type = "Success"
})

print("✅ ND ULTIMATE HUB CARREGADO!")
print("📌 Aimbot para jogos de tiro ativado na aba JOGOS EXTERNOS")
print("📱 Botões mobile disponíveis na aba MISC")
