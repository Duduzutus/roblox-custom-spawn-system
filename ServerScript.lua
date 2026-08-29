-- ========================================
-- CUSTOM SPAWN SYSTEM - SERVER SCRIPT
-- ========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Configuração Global
local SPAWN_STORAGE = Instance.new("Folder")
SPAWN_STORAGE.Name = "CustomSpawns"
SPAWN_STORAGE.Parent = workspace

-- Tabela para armazenar dados de spawn por jogador
local playerSpawns = {}
local spawnEnabled = {}

-- Função para desabilitar todos os spawns padrão
local function disableDefaultSpawns()
	local spawns = workspace:FindFirstChild("Spawns")
	if spawns then
		for _, spawn in pairs(spawns:GetChildren()) do
			spawn:Destroy()
		end
	end
end

-- Função para criar bloco de spawn customizado
local function createSpawnBlock(player, position)
	-- Remove spawn antigo se existir
	if playerSpawns[player.UserId] then
		playerSpawns[player.UserId]:Destroy()
	end

	-- Cria novo bloco de spawn
	local spawnBlock = Instance.new("Part")
	spawnBlock.Name = "CustomSpawnBlock_" .. player.Name
	spawnBlock.Shape = Enum.PartType.Block
	spawnBlock.Size = Vector3.new(6, 1, 6)
	spawnBlock.Position = position
	spawnBlock.BrickColor = BrickColor.new("Bright yellow")
	spawnBlock.Material = Enum.Material.Neon
	spawnBlock.CanCollide = false
	spawnBlock.Transparency = 0.3
	spawnBlock.TopSurface = Enum.SurfaceType.Smooth
	spawnBlock.BottomSurface = Enum.SurfaceType.Smooth
	spawnBlock.CFrame = CFrame.new(position) + Vector3.new(0, 3, 0) -- Levanta um pouco acima do chão
	spawnBlock.Parent = SPAWN_STORAGE

	-- Armazena referência
	playerSpawns[player.UserId] = spawnBlock

	-- Retorna a posição do topo do bloco para spawn
	return spawnBlock.Position + Vector3.new(0, spawnBlock.Size.Y / 2 + 3, 0)
end

-- Função para teletransportar jogador para spawn customizado
local function teleportToCustomSpawn(player)
	if not spawnEnabled[player.UserId] then return end
	if not playerSpawns[player.UserId] then return end

	local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart then
		local spawnBlock = playerSpawns[player.UserId]
		local spawnPosition = spawnBlock.Position + Vector3.new(0, 5, 0)
		humanoidRootPart.CFrame = CFrame.new(spawnPosition)
	end
end

-- Função para ativar/desativar spawn customizado
local function setSpawnEnabled(player, enabled)
	spawnEnabled[player.UserId] = enabled

	if enabled then
		-- Desabilita spawns padrão
		disableDefaultSpawns()
		-- Teleporta para spawn customizado
		wait(0.1)
		teleportToCustomSpawn(player)
	end
end

-- Função para resetar jogador (morrer e respawnar)
local function onCharacterAdded(player, character)
	wait(0.5)
	
	-- Se spawn customizado está ativado, teleporta para lá
	if spawnEnabled[player.UserId] and playerSpawns[player.UserId] then
		teleportToCustomSpawn(player)
	end
end

-- Função para limpar dados ao jogador sair
local function onPlayerRemoving(player)
	if playerSpawns[player.UserId] then
		playerSpawns[player.UserId]:Destroy()
	end
	playerSpawns[player.UserId] = nil
	spawnEnabled[player.UserId] = nil
end

-- Eventos de Conexão
Players.PlayerAdded:Connect(function(player)
	spawnEnabled[player.UserId] = false
	
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end)

Players.PlayerRemoving:Connect(onPlayerRemoving)

-- RemoteEvents para comunicação com LocalScript
local remoteEvents = Instance.new("Folder")
remoteEvents.Name = "SpawnSystemRemotes"
remoteEvents.Parent = game:GetService("ReplicatedStorage")

-- RemoteEvent: Criar bloco de spawn
local createSpawnEvent = Instance.new("RemoteEvent")
createSpawnEvent.Name = "CreateSpawn"
createSpawnEvent.Parent = remoteEvents

createSpawnEvent.OnServerEvent:Connect(function(player, position)
	createSpawnBlock(player, position)
end)

-- RemoteEvent: Toggle spawn ativado/desativado
local toggleSpawnEvent = Instance.new("RemoteEvent")
toggleSpawnEvent.Name = "ToggleSpawn"
toggleSpawnEvent.Parent = remoteEvents

toggleSpawnEvent.OnServerEvent:Connect(function(player, enabled)
	setSpawnEnabled(player, enabled)
end)

-- RemoteEvent: Obter posição do spawn customizado
local getSpawnEvent = Instance.new("RemoteEvent")
getSpawnEvent.Name = "GetSpawnPosition"
getSpawnEvent.Parent = remoteEvents

getSpawnEvent.OnServerEvent:Connect(function(player)
	if playerSpawns[player.UserId] then
		getSpawnEvent:FireClient(player, playerSpawns[player.UserId].Position)
	end
end)

-- RemoteFunction: Verificar se spawn está ativado
local checkSpawnFunction = Instance.new("RemoteFunction")
checkSpawnFunction.Name = "CheckSpawnEnabled"
checkSpawnFunction.Parent = remoteEvents

function checkSpawnFunction.OnServerInvoke(player)
	return spawnEnabled[player.UserId] or false
end

print("✓ Custom Spawn System iniciado com sucesso!")
