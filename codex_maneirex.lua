-- Serviços
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
 
-- Variáveis Globais
local AimbotFOV = 60
local AimbotKey = Enum.KeyCode.E
local AimbotKeyType = "KeyCode"
local ESPEnabled = true
local AimbotEnabled = true
local panelVisible = true
local MaxAimbotDistance = 200
local AimPartName = "Head"
local AimSpeed = 1
 
-- Whitelist — adicione os UserIds aqui
local Whitelist = {
    [2264936609] = true, -- iWhhhltc
    [1494188552] = true, -- Eu
    [516779350]  = true, -- Drimu
    [2995618552] = true, -- Will
    [1166530685] = true, -- Rafa
    [4981683349] = true, -- Ossos
    [7717762280] = true, -- Raya
}
 
-- Bloqueia quem não está na whitelist
if not Whitelist[LocalPlayer.UserId] then
    return
end
 
-- Funções locais
local function isWhitelisted(player)
    return Whitelist[player.UserId] == true
end
 
local function hasWallBetween(from, to, targetChar)
    local direction = to - from
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character, targetChar }
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(from, direction, rayParams)
    return result ~= nil
end
 
-- Desenho do FOVCircle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 2
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Radius = AimbotFOV
FOVCircle.Visible = AimbotEnabled and panelVisible
 
-- GUI Painel
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimAssistPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
 
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 490)
mainFrame.Position = UDim2.new(0, 20, 0.5, -245)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0, 0.5)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = panelVisible
mainFrame.Parent = screenGui
 
local function createButton(parent, posY, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 36)
    btn.Position = UDim2.new(0, 12, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Text = text
    btn.AutoButtonColor = true
    btn.ClipsDescendants = true
    btn.Parent = parent
 
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
 
    return btn
end
 
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 36)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.BorderSizePixel = 0
title.Text = "Configurações do Aim"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
 
local espToggle    = createButton(mainFrame, 48, "ESP: ON")
local aimbotToggle = createButton(mainFrame, 92, "Aimbot: ON")
 
-- FOV
local fovBox = Instance.new("TextBox", mainFrame)
fovBox.Size = UDim2.new(1, -24, 0, 36)
fovBox.Position = UDim2.new(0, 12, 0, 140)
fovBox.PlaceholderText = "FOV (ex: 120)"
fovBox.Text = tostring(AimbotFOV)
fovBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
fovBox.TextColor3 = Color3.fromRGB(230, 230, 230)
fovBox.Font = Enum.Font.Gotham
fovBox.TextSize = 16
fovBox.BorderSizePixel = 0
 
fovBox.FocusLost:Connect(function()
    local newFOV = tonumber(fovBox.Text)
    if newFOV then
        AimbotFOV = newFOV
        FOVCircle.Radius = newFOV
    else
        fovBox.Text = tostring(AimbotFOV)
    end
end)
 
-- Parte do corpo
local partDropdownLabel = Instance.new("TextLabel", mainFrame)
partDropdownLabel.Size = UDim2.new(1, -24, 0, 24)
partDropdownLabel.Position = UDim2.new(0, 12, 0, 182)
partDropdownLabel.BackgroundTransparency = 1
partDropdownLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
partDropdownLabel.Font = Enum.Font.Gotham
partDropdownLabel.TextSize = 14
partDropdownLabel.Text = "Prioridade de Parte do Corpo:"
 
local partDropdown = Instance.new("TextBox", mainFrame)
partDropdown.Size = UDim2.new(1, -24, 0, 30)
partDropdown.Position = UDim2.new(0, 12, 0, 206)
partDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
partDropdown.TextColor3 = Color3.fromRGB(230, 230, 230)
partDropdown.Font = Enum.Font.Gotham
partDropdown.TextSize = 16
partDropdown.Text = AimPartName
partDropdown.ClearTextOnFocus = false
 
partDropdown.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = partDropdown.Text
        local validParts = { Head = true, Torso = true, HumanoidRootPart = true }
        if validParts[val] then
            AimPartName = val
        else
            partDropdown.Text = AimPartName
        end
    else
        partDropdown.Text = AimPartName
    end
end)
 
-- Slider de velocidade
local speedLabel = Instance.new("TextLabel", mainFrame)
speedLabel.Size = UDim2.new(1, -24, 0, 24)
speedLabel.Position = UDim2.new(0, 12, 0, 244)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.Text = "Velocidade do Aimbot: " .. math.floor(AimSpeed * 100) .. "%"
 
local speedSlider = Instance.new("Frame", mainFrame)
speedSlider.Size = UDim2.new(1, -24, 0, 24)
speedSlider.Position = UDim2.new(0, 12, 0, 268)
speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
 
local fill = Instance.new("Frame", speedSlider)
fill.Size = UDim2.new(AimSpeed, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
 
local sliderDragging = false
speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
    end
end)
speedSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local relX = math.clamp(input.Position.X - speedSlider.AbsolutePosition.X, 0, speedSlider.AbsoluteSize.X)
        AimSpeed = relX / speedSlider.AbsoluteSize.X
        fill.Size = UDim2.new(AimSpeed, 0, 1, 0)
        speedLabel.Text = "Velocidade do Aimbot: " .. math.floor(AimSpeed * 100) .. "%"
    end
end)
 
-- Botão de tecla
local keyButton = createButton(mainFrame, 330, "Key: " .. AimbotKey.Name)
 
keyButton.MouseButton1Click:Connect(function()
    keyButton.Text = "Pressione uma tecla..."
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                AimbotKey = input.KeyCode
                AimbotKeyType = "KeyCode"
                keyButton.Text = "Key: " .. AimbotKey.Name
            elseif input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.MouseButton2 then
                AimbotKey = input.UserInputType
                AimbotKeyType = "MouseButton"
                keyButton.Text = "Key: " .. AimbotKey.Name
            end
            conn:Disconnect()
        end
    end)
end)
 
-- Alcance máximo
local distanceBox = Instance.new("TextBox", mainFrame)
distanceBox.Size = UDim2.new(1, -24, 0, 36)
distanceBox.Position = UDim2.new(0, 12, 0, 420)
distanceBox.PlaceholderText = "Alcance Máx (ex: 100)"
distanceBox.Text = tostring(MaxAimbotDistance)
distanceBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
distanceBox.TextColor3 = Color3.fromRGB(230, 230, 230)
distanceBox.Font = Enum.Font.Gotham
distanceBox.TextSize = 16
distanceBox.BorderSizePixel = 0
 
distanceBox.FocusLost:Connect(function()
    local newDist = tonumber(distanceBox.Text)
    if newDist then
        MaxAimbotDistance = newDist
    else
        distanceBox.Text = tostring(MaxAimbotDistance)
    end
end)
 
-- Botões de toggle
espToggle.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    espToggle.Text = "ESP: " .. (ESPEnabled and "ON" or "OFF")
end)
 
aimbotToggle.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    aimbotToggle.Text = "Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
    FOVCircle.Visible = AimbotEnabled and panelVisible
end)
 
-- Alternar visibilidade com Delete
local function togglePanelVisibility()
    panelVisible = not panelVisible
    mainFrame.Visible = panelVisible
    FOVCircle.Visible = AimbotEnabled and panelVisible
end
 
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Delete then
        togglePanelVisibility()
    end
end)
 
-- ESP
local ESPObjects = {}
 
local function createESP(player)
    if player == LocalPlayer then return end
    local nameTag = Drawing.new("Text")
    nameTag.Size = 16
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Font = 2
    nameTag.Color = Color3.fromRGB(0, 255, 0)
    nameTag.Visible = false
 
    local lines = {}
    for _ = 1, 4 do
        local ln = Drawing.new("Line")
        ln.Thickness = 1.5
        ln.Color = Color3.fromRGB(0, 255, 0)
        ln.Visible = false
        table.insert(lines, ln)
    end
 
    ESPObjects[player] = { Name = nameTag, Box = lines }
end
 
local function removeESP(player)
    local esp = ESPObjects[player]
    if esp then
        esp.Name:Remove()
        for _, ln in ipairs(esp.Box) do ln:Remove() end
        ESPObjects[player] = nil
    end
end
 
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)
for _, plr in ipairs(Players:GetPlayers()) do
    createESP(plr)
end
 
-- Aimbot: alvo mais próximo
local function getClosestTarget(centerX, centerY)
    local closestDist = math.huge
    local closestPlayer = nil
 
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isWhitelisted(player) then
            local char = player.Character
            local part = char and char:FindFirstChild(AimPartName)
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
 
            if char and part and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist   = Vector2.new(screenPos.X - centerX, screenPos.Y - centerY).Magnitude
                    local dist3D = (Camera.CFrame.Position - part.Position).Magnitude
                    if dist < AimbotFOV and dist < closestDist and dist3D <= MaxAimbotDistance then
                        closestDist = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end
 
    return closestPlayer
end
 
-- Loop principal unificado
RunService.RenderStepped:Connect(function()
    local size      = Camera.ViewportSize
    local centerX   = size.X / 2
    local centerY   = size.Y / 2
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
 
    -- FOV circle
    FOVCircle.Position = Vector2.new(centerX, centerY)
 
    -- Aimbot
    if AimbotEnabled then
        local isPressed = false
        if AimbotKeyType == "KeyCode" then
            isPressed = UserInputService:IsKeyDown(AimbotKey)
        elseif AimbotKeyType == "MouseButton" then
            isPressed = UserInputService:IsMouseButtonPressed(AimbotKey)
        end
 
        if isPressed then
            local target = getClosestTarget(centerX, centerY)
            if target and target.Character then
                local part = target.Character:FindFirstChild(AimPartName)
                if part then
                    local camPos    = Camera.CFrame.Position
                    local direction = (part.Position - camPos).Unit
                    Camera.CFrame   = Camera.CFrame:Lerp(CFrame.new(camPos, camPos + direction), AimSpeed)
                end
            end
        end
    end
 
    -- ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isWhitelisted(player) then
            local char = player.Character
            local head = char and char:FindFirstChild("Head")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local esp  = ESPObjects[player]
 
            if esp then
                if ESPEnabled and char and head and root and hum and hum.Health > 0 then
                    local v1, on1 = Camera:WorldToViewportPoint(head.Position)
                    local v2, on2 = Camera:WorldToViewportPoint(root.Position)
 
                    if on1 or on2 then
                        local origin     = Camera.CFrame.Position
                        local behindWall = hasWallBetween(origin, root.Position, char)
 
                        local color
                        if behindWall then
                            color = Color3.fromRGB(255, 165, 0) -- laranja = atrás de parede
                        else
                            local dist = localRoot and (localRoot.Position - root.Position).Magnitude or 0
                            local t    = math.clamp(dist / 300, 0, 1)
                            color = Color3.fromRGB(255 * (1 - t), 0, 255 * t)
                        end
 
                        -- Nome
                        esp.Name.Position = Vector2.new(v1.X, v1.Y - 25)
                        esp.Name.Text     = player.Name
                        esp.Name.Color    = color
                        esp.Name.Visible  = true
 
                        -- Caixa
                        local height = math.abs(v1.Y - v2.Y) * 2
                        local width  = height / 2
                        local x, y   = v2.X, v2.Y
                        local hw     = width / 2
 
                        local ln = esp.Box
                        ln[1].From, ln[1].To = Vector2.new(x - hw, y - height), Vector2.new(x + hw, y - height)
                        ln[2].From, ln[2].To = Vector2.new(x + hw, y - height), Vector2.new(x + hw, y)
                        ln[3].From, ln[3].To = Vector2.new(x + hw, y),          Vector2.new(x - hw, y)
                        ln[4].From, ln[4].To = Vector2.new(x - hw, y),          Vector2.new(x - hw, y - height)
 
                        for _, l in ipairs(ln) do
                            l.Color   = color
                            l.Visible = true
                        end
                    else
                        esp.Name.Visible = false
                        for _, l in ipairs(esp.Box) do l.Visible = false end
                    end
                else
                    esp.Name.Visible = false
                    for _, l in ipairs(esp.Box) do l.Visible = false end
                end
            end
        end
    end
end)
