--[[
    KEY MENU SYSTEM PARA DELTA EXECUTOR
    Chave correta: 2026lol
    Ao inserir a chave correta, executa o script principal.
--]]

-- Variáveis globais
local keyCorrect = "2026lol"
local userInput = ""
local authenticated = false

-- Função para executar o script principal
local function executeMainScript()
    -- Mensagem de confirmação
    print("[KEY SYSTEM] ✅ Chave correta! Executando script...")
    
    -- Executa o script solicitado
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ilovefemboys482-pixel/meuscript.lua/refs/heads/main/meuscript.lua"))()
end

-- Função para criar o menu (GUI estilo macOS)
local function createKeyMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeyMenuGUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    -- Verificar se já existe e remover
    if game.CoreGui:FindFirstChild("KeyMenuGUI") then
        game.CoreGui:FindFirstChild("KeyMenuGUI"):Destroy()
    end
    
    screenGui.Parent = game.CoreGui
    
    -- Frame principal (estilo macOS - vidro)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 420, 0, 320)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Efeito blur (vidro)
    local blur = Instance.new("BlurEffect")
    blur.Size = 12
    blur.Parent = mainFrame
    
    -- Bordas arredondadas com corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)
    corner.Parent = mainFrame
    
    -- Sombra (stroke)
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(255, 255, 255)
    shadow.Transparency = 0.85
    shadow.Thickness = 0.5
    shadow.Parent = mainFrame
    
    -- Título da janela (barra estilo macOS)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 44)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    titleBar.BackgroundTransparency = 0.3
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 24)
    titleCorner.Parent = titleBar
    
    -- Botões de controle (macOS)
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(0, 70, 1, 0)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Position = UDim2.new(0, 12, 0, 0)
    controlsFrame.Parent = titleBar
    
    -- Botão fechar (vermelho)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 14, 0, 14)
    closeBtn.Position = UDim2.new(0, 0, 0.5, -7)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = ""
    closeBtn.Parent = controlsFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Botão minimizar (amarelo)
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 14, 0, 14)
    minBtn.Position = UDim2.new(0, 20, 0.5, -7)
    minBtn.BackgroundColor3 = Color3.fromRGB(255, 189, 46)
    minBtn.BorderSizePixel = 0
    minBtn.Text = ""
    minBtn.Parent = controlsFrame
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(1, 0)
    minCorner.Parent = minBtn
    
    minBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
    
    -- Botão maximizar (verde)
    local maxBtn = Instance.new("TextButton")
    maxBtn.Size = UDim2.new(0, 14, 0, 14)
    maxBtn.Position = UDim2.new(0, 40, 0.5, -7)
    maxBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 64)
    maxBtn.BorderSizePixel = 0
    maxBtn.Text = ""
    maxBtn.Parent = controlsFrame
    
    local maxCorner = Instance.new("UICorner")
    maxCorner.CornerRadius = UDim.new(1, 0)
    maxCorner.Parent = maxBtn
    
    local maximized = false
    local originalSize = mainFrame.Size
    local originalPos = mainFrame.Position
    
    maxBtn.MouseButton1Click:Connect(function()
        if not maximized then
            originalSize = mainFrame.Size
            originalPos = mainFrame.Position
            mainFrame.Size = UDim2.new(1, -40, 1, -80)
            mainFrame.Position = UDim2.new(0, 20, 0, 40)
            maximized = true
        else
            mainFrame.Size = originalSize
            mainFrame.Position = originalPos
            maximized = false
        end
    end)
    
    -- Título do app
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.new(0, 80, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🔐 KEY MENU · Delta Executor"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 14
    titleText.Font = Enum.Font.SFProText
    titleText.TextXAlignment = Enum.TextXAlignment.Center
    titleText.Parent = titleBar
    
    -- Conteúdo principal
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -40, 1, -80)
    contentFrame.Position = UDim2.new(0, 20, 0, 60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Ícone de cadeado / segurança
    local lockIcon = Instance.new("TextLabel")
    lockIcon.Size = UDim2.new(0, 80, 0, 80)
    lockIcon.Position = UDim2.new(0.5, -40, 0, 20)
    lockIcon.BackgroundTransparency = 1
    lockIcon.Text = "🔒"
    lockIcon.TextSize = 48
    lockIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    lockIcon.Font = Enum.Font.SFProText
    lockIcon.Parent = contentFrame
    
    -- Título da key
    local keyTitle = Instance.new("TextLabel")
    keyTitle.Size = UDim2.new(1, 0, 0, 30)
    keyTitle.Position = UDim2.new(0, 0, 0, 110)
    keyTitle.BackgroundTransparency = 1
    keyTitle.Text = "INSIRA A CHAVE DE ACESSO"
    keyTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
    keyTitle.TextSize = 16
    keyTitle.Font = Enum.Font.SFProTextBold
    keyTitle.TextXAlignment = Enum.TextXAlignment.Center
    keyTitle.Parent = contentFrame
    
    -- Subtítulo
    local subTitle = Instance.new("TextLabel")
    subTitle.Size = UDim2.new(1, 0, 0, 20)
    subTitle.Position = UDim2.new(0, 0, 0, 140)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = "Digite a chave para ativar o script"
    subTitle.TextColor3 = Color3.fromRGB(150, 150, 170)
    subTitle.TextSize = 12
    subTitle.Font = Enum.Font.SFProText
    subTitle.TextXAlignment = Enum.TextXAlignment.Center
    subTitle.Parent = contentFrame
    
    -- Campo de entrada (input box)
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0, 260, 0, 48)
    inputBox.Position = UDim2.new(0.5, -130, 0, 180)
    inputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    inputBox.BackgroundTransparency = 0.2
    inputBox.BorderSizePixel = 0
    inputBox.PlaceholderText = "••••••••"
    inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextSize = 18
    inputBox.Font = Enum.Font.SFProText
    inputBox.TextXAlignment = Enum.TextXAlignment.Center
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = contentFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 14)
    inputCorner.Parent = inputBox
    
    -- Efeito de borda no input
    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = Color3.fromRGB(80, 80, 100)
    inputStroke.Thickness = 1
    inputStroke.Transparency = 0.6
    inputStroke.Parent = inputBox
    
    -- Botão de verificar / executar
    local verifyBtn = Instance.new("TextButton")
    verifyBtn.Size = UDim2.new(0, 200, 0, 48)
    verifyBtn.Position = UDim2.new(0.5, -100, 0, 250)
    verifyBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    verifyBtn.BackgroundTransparency = 0.15
    verifyBtn.BorderSizePixel = 0
    verifyBtn.Text = "VERIFICAR CHAVE"
    verifyBtn.TextColor3 = Color3.fromRGB(0, 122, 255)
    verifyBtn.TextSize = 16
    verifyBtn.Font = Enum.Font.SFProTextBold
    verifyBtn.Parent = contentFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 14)
    btnCorner.Parent = verifyBtn
    
    -- Efeito hover
    verifyBtn.MouseEnter:Connect(function()
        verifyBtn.BackgroundTransparency = 0.25
        verifyBtn.TextColor3 = Color3.fromRGB(50, 150, 255)
    end)
    
    verifyBtn.MouseLeave:Connect(function()
        verifyBtn.BackgroundTransparency = 0.15
        verifyBtn.TextColor3 = Color3.fromRGB(0, 122, 255)
    end)
    
    -- Label de status / mensagem
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -40, 0, 30)
    statusLabel.Position = UDim2.new(0, 20, 0, 315)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Aguardando chave..."
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.SFProText
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.Parent = mainFrame
    
    -- Função para animação de sucesso
    local function showSuccessAnimation()
        lockIcon.Text = "🔓"
        lockIcon.TextColor3 = Color3.fromRGB(52, 199, 89)
        
        -- Animação de pulso no botão
        verifyBtn.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
        verifyBtn.BackgroundTransparency = 0.3
        verifyBtn.Text = "✓ EXECUTADO COM SUCESSO"
        verifyBtn.TextColor3 = Color3.fromRGB(52, 199, 89)
        
        -- Desabilitar input e botão
        inputBox.Text = ""
        inputBox.PlaceholderText = "✅ Acesso concedido"
        inputBox.TextTransparency = 0.5
        verifyBtn.Active = false
        verifyBtn.AutoButtonColor = false
        
        -- Mudar status
        statusLabel.Text = "✅ Chave correta! Script executado com sucesso."
        statusLabel.TextColor3 = Color3.fromRGB(52, 199, 89)
        
        -- Pequeno delay e depois pode fechar automaticamente após 3 segundos
        task.wait(3)
        screenGui:Destroy()
    end
    
    -- Função para erro
    local function showError()
        statusLabel.Text = "❌ Chave incorreta! Tente novamente."
        statusLabel.TextColor3 = Color3.fromRGB(255, 69, 58)
        
        lockIcon.Text = "⚠️"
        lockIcon.TextColor3 = Color3.fromRGB(255, 149, 0)
        
        -- Efeito de shake no input
        local originalPosX = inputBox.Position.X.Scale
        local originalOffset = inputBox.Position.X.Offset
        for i = 1, 3 do
            inputBox.Position = UDim2.new(originalPosX, originalOffset + 5, inputBox.Position.Y.Scale, inputBox.Position.Y.Offset)
            task.wait(0.03)
            inputBox.Position = UDim2.new(originalPosX, originalOffset - 5, inputBox.Position.Y.Scale, inputBox.Position.Y.Offset)
            task.wait(0.03)
        end
        inputBox.Position = UDim2.new(originalPosX, originalOffset, inputBox.Position.Y.Scale, inputBox.Position.Y.Offset)
        
        -- Limpar mensagem de erro após 2 segundos
        task.wait(2)
        if not authenticated then
            statusLabel.Text = "Aguardando chave..."
            statusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
            lockIcon.Text = "🔒"
            lockIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    
    -- Função principal de verificação
    local function verifyKey()
        local enteredKey = inputBox.Text:gsub("%s+", "") -- Remove espaços
        
        if enteredKey == "" then
            statusLabel.Text = "⚠️ Digite uma chave para continuar."
            statusLabel.TextColor3 = Color3.fromRGB(255, 149, 0)
            task.wait(1.5)
            if not authenticated then
                statusLabel.Text = "Aguardando chave..."
                statusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
            end
            return
        end
        
        if enteredKey == "2026lol" then
            authenticated = true
            showSuccessAnimation()
            
            -- Executar o script principal
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/ilovefemboys482-pixel/meuscript.lua/refs/heads/main/meuscript.lua"))()
            end)
            
            if not success then
                warn("[KEY SYSTEM] Erro ao executar script: " .. tostring(err))
                statusLabel.Text = "⚠️ Erro ao carregar script. Verifique sua conexão."
                statusLabel.TextColor3 = Color3.fromRGB(255, 69, 58)
            else
                print("[KEY SYSTEM] Script executado com sucesso!")
            end
        else
            showError()
            inputBox.Text = ""
            inputBox:CaptureFocus()
        end
    end
    
    -- Conectar botão ao evento
    verifyBtn.MouseButton1Click:Connect(verifyKey)
    
    -- Permitir pressionar Enter no campo de texto
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            verifyKey()
        end
    end)
    
    -- Foco automático no input
    task.wait(0.1)
    inputBox:CaptureFocus()
    
    -- Tornar a janela arrastável (macOS style)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Animação de entrada (fade in)
    mainFrame.BackgroundTransparency = 0.25
    mainFrame:TweenSizeAndPosition(mainFrame.Size, mainFrame.Position, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    task.wait(0.1)
    mainFrame.BackgroundTransparency = 0.15
end

-- Verificar se o jogo está carregado
local function waitForGame()
    local startTime = tick()
    while not game:IsLoaded() and tick() - startTime < 10 do
        task.wait(0.1)
    end
    return true
end

-- Executar criação do menu
waitForGame()
createKeyMenu()

-- Mensagem no console
print("========================================")
print("  🔐 KEY MENU SYSTEM v2.0 - DELTA")
print("  Chave correta: 2026lol")
print("  Insira a chave na interface para ativar")
print("========================================")
