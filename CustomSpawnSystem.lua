-- ========================================
-- CUSTOM SPAWN SYSTEM - SCRIPT ÚNICO COMPLETO
-- ========================================
-- Coloque este script em: StarterPlayer > StarterCharacterScripts
-- Este é um LocalScript que funciona 100%

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Variáveis de controle
local spawnEnabled = false
local spawnBlockCreated = false
local selectedPosition = nil
local isSelectingPosition = false
local customSpawnBlock = nil

print("✅ Sistema de Spawn Customizado iniciando...")

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
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Cantos arredondados
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Sombra
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
button1.Text = "🔴 Ativar Spawn"
button1.TextColor3 = Color3.fromRGB(255, 255, 255)
button1.TextSize = 15
button1.Font = Enum.Font.GothamBold
button1.Parent = mainFrame

local button1Corner = Instance.new("UICorner")
button1Corner.CornerRadius = UDim.new(0, 8)
button1Corner.Parent = button1

-- Efeito hover botão 1
button1.MouseEnter:Connect(function()
	button1:TweenSize(UDim2.new(1, -20, 0, 48), "Out", "Quad", 0.2, true)
	if not spawnEnabled then
		button1.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
	else
		button1.BackgroundColor3 = Color3.fromRGB(70, 220, 70)
	end
end)

button1.MouseLeave:Connect(function()
	button1:TweenSize(UDim2.new(1, -20, 0, 45), "Out", "Quad", 0.2, true)
	if not spawnEnabled then
		button1.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	else
		button1.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	end
end)

-- Botão 2: Criar Bloco de Spawn
local button2 = Instance.new("TextButton")
button2.Name = "CreateSpawnButton"
button2.Size = UDim2.new(1, -20, 0, 45)
button2.Position = UDim2.new(0, 10, 0, 185)
button2.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
button2.BorderSizePixel = 0
button2.Text = "🟨 Criar Bloco"
button2.TextColor3 = Color3.fromRGB(255, 255, 255)
button2.TextSize = 15
button2.Font = Enum.Font.GothamBold
button2.Parent = mainFrame

local button2Corner = Instance.new("UICorner")
button2Corner.CornerRadius = UDim.new(0, 8)
button2Corner.Parent = button2

-- Efeito hover botão 2
button2.MouseEnter:Connect(function()
	button2:TweenSize(UDim2.new(1, -20, 0, 48), "Out", "Quad", 0.2, true)
	button2.BackgroundColor3 = Color3.fromRGB(70, 170, 220)
end)

button2.MouseLeave:Connect(function()
	button2:TweenSize(UDim2.new(1, -20, 0, 45), "Out", "Quad", 0.2, true)
	button2.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
end)

-- Info text
local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "Info"
infoLabel.Size = UDim2.new(1, -20, 0, 25)
infoLabel.Position = UDim2.new(0, 10, 0, 245)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "💡 Clique no botão azul e depois na posição"
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
infoLabel.TextSize = 11
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextWrapped = true
infoLabel.Parent = mainFrame

-- ========================================
-- FUNÇÕES
-- ========================================

local function updateButton1Visual()
	if spawnEnabled then
		button1.Text = "✅ Spawn Ativado"
		button1.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		statusLabel.Text = "✅ Spawn: ATIVADO"
		statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	else
		button1.Text = "🔴 Ativar Spawn"
		button1.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		statusLabel.Text = "❌ Spawn: DESATIVADO"
		statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end

local function updateButton2Visual()
	if spawnBlockCreated then
		button2.Text = "✅ Bloco Criado"
		blockStatusLabel.Text = "✅ Bloco: CRIADO"
		blockStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		button2.BackgroundColor3 = Color3.fromRGB(100, 180, 100)
	else
		button2.Text = "🟨 Criar Bloco"
		blockStatusLabel.Text = "⚠️ Bloco: NÃO CRIADO"
		blockStatusLabel.TextColor3 = Color3.fromRGB(255, 180, 0)
		button2.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
	end
end

local function createSpawnBlock(position)
	-- Remove bloco antigo se existir
	if customSpawnBlock then
		customSpawnBlock:Destroy()
	end

	-- Cria novo bloco - POSITIONED CORRETAMENTE NO CHÃO
	customSpawnBlock = Instance.new("Part")
	customSpawnBlock.Name = "CustomSpawnBlock"
	customSpawnBlock.Shape = Enum.PartType.Block
	customSpawnBlock.Size = Vector3.new(6, 1, 6)
	customSpawnBlock.Position = Vector3.new(position.X, position.Y + 0.5, position.Z) -- Posiciona no chão
	customSpawnBlock.BrickColor = BrickColor.new("Bright yellow")
	customSpawnBlock.Material = Enum.Material.Neon
	customSpawnBlock.CanCollide = false -- NÃO colide com nada
	customSpawnBlock.Transparency = 0.3
	customSpawnBlock.TopSurface = Enum.SurfaceType.Smooth
	customSpawnBlock.BottomSurface = Enum.SurfaceType.Smooth
	customSpawnBlock.Parent = workspace

	print("✅ Bloco de spawn criado em:", Vector3.new(position.X, position.Y, position.Z))
	return customSpawnBlock
end

local function spawnPlayerOnBlock()
	if not spawnBlockCreated or not customSpawnBlock then return end

	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart then
		-- Spawna no topo do bloco, não teleporta imediatamente
		local spawnPosition = customSpawnBlock.Position + Vector3.new(0, 2, 0)
		humanoidRootPart.CFrame = CFrame.new(spawnPosition)
		print("🎯 Jogador spawned no bloco customizado!")
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
	updateButton1Visual()
	
	print("Spawn:", spawnEnabled and "ATIVADO" or "DESATIVADO")
end)

-- Botão 2: Selecionar posição
button2.MouseButton1Click:Connect(function()
	if isSelectingPosition then
		print("⚠️ Já está selecionando posição!")
		return
	end

	isSelectingPosition = true
	print("🎯 Clique na posição onde deseja criar o bloco!")
	infoLabel.Text = "🎯 Clique na posição onde deseja criar o bloco!"
	button2.BackgroundColor3 = Color3.fromRGB(150, 150, 50)
end)

-- ========================================
-- RAYCASTING PARA SELECIONAR POSIÇÃO
-- ========================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not isSelectingPosition then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local unitRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		raycastParams.FilterDescendantsInstances = {player.Character}

		local rayResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)

		if rayResult then
			selectedPosition = rayResult.Position
			print("✅ Posição selecionada:", selectedPosition)

			-- Cria o bloco NA POSIÇÃO CORRETA
			createSpawnBlock(selectedPosition)

			spawnBlockCreated = true
			isSelectingPosition = false

			updateButton2Visual()
			infoLabel.Text = "💡 Bloco criado! Clique no vermelho para ativar"
			button2.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
		end
	end
end)

-- ========================================
-- QUANDO O JOGADOR MORRE E RESPAWNA
-- ========================================

local function onCharacterAdded(newCharacter)
	print("🔄 Personagem adicionado - aguardando Humanoid...")
	
	local humanoid = newCharacter:WaitForChild("Humanoid")
	
	-- Aguarda um pouco para o jogador estar completamente spawnado
	wait(0.1)
	
	-- SÓ teleporta se o spawn estiver ativado E o bloco existir
	if spawnEnabled and spawnBlockCreated and customSpawnBlock then
		spawnPlayerOnBlock()
	end
end

-- Conecta ao evento de novo personagem
player.CharacterAdded:Connect(onCharacterAdded)

-- ========================================
-- INICIALIZAÇÃO
-- ========================================

updateButton1Visual()
updateButton2Visual()

print("✅ Interface de Spawn Customizado carregada com sucesso!")
print("📍 Clique no botão azul para criar seu spawn customizado")
print("💡 O spawn funciona APENAS quando você morre/respawna com o botão ativado")
