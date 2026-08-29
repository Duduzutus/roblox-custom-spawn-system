-- ========================================
-- DISABLE DEFAULT SPAWNS - SERVER SCRIPT
-- ========================================
-- Coloque este script em: ServerScriptService
-- Desabilita TODOS os spawns padrão do jogo

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

print("🔍 Procurando spawns padrão para desabilitar...")

-- Função para desabilitar spawns
local function disableDefaultSpawns()
	-- Procura por qualquer parte com tipo SpawnLocation
	for _, child in pairs(workspace:GetDescendants()) do
		if child:IsA("SpawnLocation") then
			-- Desabilita a spawn location completamente
			child.CanCollide = false
			child.Transparency = 1
			child.CanTouch = false
			
			-- Remove o script de spawn se tiver
			local humanoidOnTouch = child:FindFirstChildOfClass("Script")
			if humanoidOnTouch then
				humanoidOnTouch:Destroy()
			end
			
			print("✅ Spawn padrão desabilitado:", child.Name)
		end
	end
end

-- Desabilita os spawns quando o jogo inicia
wait(0.5)
disableDefaultSpawns()

-- Também desabilita qualquer novo spawn que for criado
workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("SpawnLocation") then
		wait(0.1)
		descendant.CanCollide = false
		descendant.Transparency = 1
		descendant.CanTouch = false
		print("✅ Novo spawn padrão foi desabilitado:", descendant.Name)
	end
end)

print("✅ Sistema de desativação de spawns padrão ativado!")