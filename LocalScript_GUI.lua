-- ========================================
-- CUSTOM SPAWN SYSTEM - LOCAL SCRIPT (GUI)
-- ========================================
-- Coloque este script em StarterPlayer > StarterCharacterScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Aguarda os RemoteEvents do servidor
local remoteFolder = game:GetService("ReplicatedStorage"):WaitForChild("SpawnSystemRemotes")
local createSpawnEvent = remoteFolder:WaitForChild("CreateSpawn")
local toggleSpawnEvent = remoteFolder:WaitForChild("ToggleSpawn")
local checkSpawnFunction = remoteFolder:WaitForChild("CheckSpawnEnabled")

-- Variáveis de controle
local spawnEnabled = false
local spawnBlockCreated = false
local selectedPosition = nil
local isSelectingPosition = false

-- ========================================
-- CRIAÇÃO DA INTERFACE GUI
-- ========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomSpawnGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame principal (painel)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainPanel"
mainFrame.Size = UDim2.new(0, 350, 0, 280)
mainFrame.Position = UDim2.new(0.5, -175, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Adiciona cantos arredondados (simulado com gradiente)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Sombra do painel
local shadow = Instance.new("UIStroke")
shadow.Color = Color3.fromRGB(0, 0, 0)
shadow.Thickness = 2
shadow.Parent = mainFrame

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "⚙️ Sistema de Spawn"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleLabel

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 60)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "❌ Spawn: DESATIVADO"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- Status do bloco
local blockStatusLabel = Instance.new("TextLabel")
blockStatusLabel.Name = "BlockStatus"
blockStatusLabel.Size = UDim2.new(1, -20, 0, 30)
blockStatusLabel.Position = UDim2.new(0, 10, 0, 90)
blockStatusLabel.BackgroundTransparency = 1
blockStatusLabel.Text = "⚠️ Bloco: NÃO CRIADO"
blockStatusLabel.TextColor3 = Color3.fromRGB(255, 180, 0)
blockStatusLabel.TextSize = 14
blockStatusLabel.Font = Enum.Font.Gotham
blockStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
blockStatusLabel.Parent = mainFrame

-- Botão 1: Ativar/Desativar Spawn
local button1 = Instance.new("TextButton")
button1.Name = "ToggleSpawnButton"
button1.Size = UDim2.new(1, -20, 0, 45)
button1.Position = UDim2.new(0, 10, 0, 130)
button1.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
button1.BorderSizePixel = 0
button1.Text = "🔴 Ativar Spawn Customizado"
button1.TextColor3 = Color3.fromRGB(255, 255, 255)
button1.TextSize = 15
button1.Font = Enum.Font.GothamBold
button1.Parent = mainFrame

local button1Corner = Instance.new("UICorner")
button1Corner.CornerRadius = UDim.new(0, 8)
button1Corner.Parent = button1

-- Efeito hover botão 1
local button1Hover = false
local button1DefaultColor = Color3.fromRGB(200, 50, 50)
local button1HoverColor = Color3.fromRGB(220, 70, 70)

button1.MouseEnter:Connect(function()
	button1Hover = true
	button1:TweenSize(UDim2.new(1, -20, 0, 48), "Out", "Quad", 0.2, true)
	button1.BackgroundColor3 = button1HoverColor
end)

button1.MouseLeave:Connect(function()
	button1Hover = false
	button1:TweenSize(UDim2.new(1, -20, 0, 45), "Out", "Quad", 0.2, true)
	if not spawnEnabled then
		button1.BackgroundColor3 = button1DefaultColor
	end
end)

-- Botão 2: Criar Bloco de Spawn
local button2 = Instance.new("TextButton")
button2.Name = "CreateSpawnButton"
button2.Size = UDim2.new(1, -20, 0, 45)
button2.Position = UDim2.new(0, 10, 0, 185)
button2.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
button2.BorderSizePixel = 0
button2.Text = "🟨 Criar Bloco de Spawn"
button2.TextColor3 = Color3.fromRGB(255, 255, 255)
button2.TextSize = 15
button2.Font = Enum.Font.GothamBold
button2.Parent = mainFrame

local button2Corner = Instance.new("UICorner")
button2Corner.CornerRadius = UDim.new(0, 8)
button2Corner.Parent = button2

-- Efeito hover botão 2
local button2Hover = false
local button2DefaultColor = Color3.fromRGB(50, 150, 200)
local button2HoverColor = Color3.fromRGB(70, 170, 220)

button2.MouseEnter:Connect(function()
	button2Hover = true
	button2:TweenSize(UDim2.new(1, -20, 0, 48), "Out", "Quad", 0.2, true)
	button2.BackgroundColor3 = button2HoverColor
end)

button2.MouseLeave:Connect(function()
	button2Hover = false
	button2:TweenSize(UDim2.new(1, -20, 0, 45), "Out", "Quad", 0.2, true)
	button2.BackgroundColor3 = button2DefaultColor
end)

-- Info text no rodapé
local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "Info"
infoLabel.Size = UDim2.new(1, -20, 0, 25)
infoLabel.Position = UDim2.new(0, 10, 0, 245)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "💡 Clique no botão azul e depois na posição desejada"
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
infoLabel.TextSize = 11
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextWrapped = true
infoLabel.Parent = mainFrame

-- ========================================
-- FUNÇÕES DA INTERFACE
-- ========================================

-- Função para atualizar visual do botão 1
local function updateButton1Visual()
	if spawnEnabled then
		button1.Text = "🟢 Spawn Ativado"
		button1.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		statusLabel.Text = "✅ Spawn: ATIVADO"
		statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	else
		button1.Text = "🔴 Ativar Spawn Customizado"
		button1.BackgroundColor3 = button1DefaultColor
		statusLabel.Text = "❌ Spawn: DESATIVADO"
		statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end

-- Função para atualizar visual do botão 2
local function updateButton2Visual()
	if spawnBlockCreated then
		button2.Text = "✅ Bloco Criado"
		blockStatusLabel.Text = "✅ Bloco: CRIADO"
		blockStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		button2.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
	else
		button2.Text = "🟨 Criar Bloco de Spawn"
		blockStatusLabel.Text = "⚠️ Bloco: NÃO CRIADO"
		blockStatusLabel.TextColor3 = Color3.fromRGB(255, 180, 0)
		button2.BackgroundColor3 = button2DefaultColor
	end
end

-- ========================================
-- EVENTOS DOS BOTÕES
-- ========================================

-- Botão 1: Ativar/Desativar Spawn
button1.MouseButton1Click:Connect(function()
	if not spawnBlockCreated then
		print("⚠️ Crie um bloco de spawn primeiro!")
		return
	end

	spawnEnabled = not spawnEnabled
	toggleSpawnEvent:FireServer(spawnEnabled)
	updateButton1Visual()
end)

-- Botão 2: Selecionar posição para criar bloco
button2.MouseButton1Click:Connect(function()
	if isSelectingPosition then
		print("⚠️ Já está selecionando posição!")
		return
	end

	isSelectingPosition = true
	print("🎯 Clique na posição onde deseja criar o bloco de spawn!")
	infoLabel.Text = "🎯 Clique na posição onde deseja criar o bloco!"
	button2.BackgroundColor3 = Color3.fromRGB(150, 150, 50)
end)

-- ========================================
-- RAYCASTING PARA SELECIONAR POSIÇÃO
-- ========================================

local UserInputService = game:GetService("UserInputService")
local mouse = player:GetMouse()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not isSelectingPosition then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local camera = workspace.CurrentCamera
		local mousePosition = mouse.Hit

		if mousePosition then
			selectedPosition = mousePosition.Position
			print("✅ Posição selecionada:", selectedPosition)

			-- Envia para o servidor criar o bloco
			createSpawnEvent:FireServer(selectedPosition)
			
			spawnBlockCreated = true
			isSelectingPosition = false
			
			updateButton2Visual()
			infoLabel.Text = "💡 Bloco criado! Agora ative o spawn com o botão vermelho"
			button2.BackgroundColor3 = button2DefaultColor
		end
	end
end)

-- ========================================
-- INICIALIZAÇÃO
-- ========================================

updateButton1Visual()
updateButton2Visual()

print("✅ Interface de Spawn Customizado carregada!")
