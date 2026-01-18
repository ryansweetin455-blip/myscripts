local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Example",
	LoadingTitle = "Rayfield UI",
	ConfigurationSaving = {
		Enabled = false
	}
})

-- Movimiento: botón para correr más rápido e input para velocidad
local Player = game.Players.LocalPlayer
local humanoid

local function resolveHumanoid()
	local success = pcall(function()
		local character = Player.Character
		if not character then
			character = Player.CharacterAdded:Wait()
		end
		if character then
			humanoid = character:WaitForChild("Humanoid", 5)
		end
	end)
	return success and humanoid
end

resolveHumanoid()
Player.CharacterAdded:Connect(resolveHumanoid)

local function clamp(n, min, max)
	return math.max(min, math.min(max, n))
end

local desiredSpeed = 32 -- valor por defecto para correr más rápido
local autoApply = true -- alterna aplicar automáticamente desde el input
local RunService = game:GetService("RunService")
local autoFarm = false
local maintainConn
local pendingTransactions = {} -- Rastrear transacciones pendientes

-- Crear una pestaña de movimiento
local MovementTab = Window:CreateTab("Movimiento")

-- Escuchar respuestas del servidor
local function setupResponseListener()
	pcall(function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local PostieReceived = ReplicatedStorage:WaitForChild("PostieReceived", 5)
		
		PostieReceived.OnClientEvent:Connect(function(transactionID, exito, mensaje)
			if pendingTransactions[transactionID] then
				if exito then
					print("✅ CONFIRMADO: " .. mensaje)
				else
					print("❌ RECHAZADO: " .. mensaje)
				end
				pendingTransactions[transactionID] = nil
			end
		end)
		print("✓ Listener de servidor configurado")
	end)
end

setupResponseListener()

-- Label de estado de velocidad y utilidades
local SpeedLabel = MovementTab:CreateLabel("WALK SPEED: " .. tostring(desiredSpeed))

local function applySpeed()
	if not humanoid or not humanoid.Parent then
		resolveHumanoid()
	end
	if humanoid and humanoid.Parent then
		local success, err = pcall(function()
			humanoid.WalkSpeed = desiredSpeed
		end)
		if not success then
			warn("Error al aplicar velocidad: " .. tostring(err))
		end
		return success
	else
		warn("Humanoid no encontrado. Intenta de nuevo en un momento.")
		return false
	end
end


local function updateSpeedLabel()
	pcall(function()
		if SpeedLabel and SpeedLabel.Set then
			SpeedLabel:Set("WALK SPEED: " .. tostring(desiredSpeed))
		end
	end)
end

-- Slider para ajustar la velocidad de forma cómoda
local SpeedSlider = MovementTab:CreateSlider({
	Name = "Walk Speed",
	Range = {8, 500},
	Increment = 1,
	CurrentValue = desiredSpeed,
	Callback = function(value)
		desiredSpeed = clamp(value, 8, 500)
		local applied = applySpeed()
		if applied then
			updateSpeedLabel()
		else
			-- Si no se pudo aplicar, intenta de nuevo después de un breve retraso
			task.wait(0.1)
			applySpeed()
			updateSpeedLabel()
		end
	end
})

MovementTab:CreateInput({
	Name = "Velocidad deseada",
	PlaceholderText = "Ej: 32",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		local n = tonumber(text)
		if n then
			desiredSpeed = clamp(n, 8, 500)
			if autoApply then
				applySpeed()
			end
			-- Sincronizar el slider
			pcall(function()
				if SpeedSlider and SpeedSlider.SetValue then
					SpeedSlider:SetValue(desiredSpeed)
				end
			end)
			updateSpeedLabel()
		end
	end
})

MovementTab:CreateButton({
	Name = "Correr más rápido",
	Callback = function()
		applySpeed()
		updateSpeedLabel()
	end
})

-- Botón de restablecimiento a velocidad estándar
MovementTab:CreateButton({
	Name = "Restablecer velocidad (16)",
	Callback = function()
		desiredSpeed = 16
		applySpeed()
		-- Sincronizar el slider
		pcall(function()
			if SpeedSlider and SpeedSlider.SetValue then
				SpeedSlider:SetValue(16)
			end
		end)
		updateSpeedLabel()
	end
})

-- Botón para ver todo el juego en consola
MovementTab:CreateButton({
	Name = "Ver Todo el Juego (Consola)",
	Callback = function()
		local function printChildren(parent, indent)
			indent = indent or ""
			for _, child in ipairs(parent:GetChildren()) do
				print(indent .. "├─ " .. child.Name .. " (" .. child.ClassName .. ")")
			end
		end
		
		print("\n" .. string.rep("=", 50))
		print("ESTRUCTURA DEL JUEGO")
		print(string.rep("=", 50))
		
		-- Workspace
		print("\n[WORKSPACE]")
		printChildren(workspace, "  ")
		
		-- ReplicatedStorage
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		print("\n[REPLICATED STORAGE]")
		printChildren(ReplicatedStorage, "  ")
		
		-- ReplicatedFirst
		local ReplicatedFirst = game:GetService("ReplicatedFirst")
		print("\n[REPLICATED FIRST]")
		printChildren(ReplicatedFirst, "  ")
		
		-- ServerStorage (puede dar error si no tienes acceso)
		pcall(function()
			local ServerStorage = game:GetService("ServerStorage")
			print("\n[SERVER STORAGE]")
			printChildren(ServerStorage, "  ")
		end)
		
		-- StarterGui
		local StarterGui = game:GetService("StarterGui")
		print("\n[STARTER GUI]")
		printChildren(StarterGui, "  ")
		
		-- StarterPack
		local StarterPack = game:GetService("StarterPack")
		print("\n[STARTER PACK]")
		printChildren(StarterPack, "  ")
		
		-- Lighting
		local Lighting = game:GetService("Lighting")
		print("\n[LIGHTING]")
		printChildren(Lighting, "  ")
		
		-- Players
		local Players = game:GetService("Players")
		print("\n[PLAYERS]")
		for _, player in ipairs(Players:GetPlayers()) do
			print("  ├─ " .. player.Name .. " (Player)")
		end
		
		print("\n" .. string.rep("=", 50))
		print("FIN DE LA ESTRUCTURA")
		print(string.rep("=", 50) .. "\n")
	end
})
-- Botón para activar MoneyWeather
MovementTab:CreateButton({
	Name = "Activar MoneyWeather",
	Callback = function()
		pcall(function()
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local moneyWeather = ReplicatedStorage:FindFirstChild("MoneyWeather")
			if moneyWeather then
				print("✓ MoneyWeather encontrado en ReplicatedStorage")
				-- Hacerlo visible si estaba invisible
				if moneyWeather:IsA("BasePart") or moneyWeather:IsA("Model") then
					moneyWeather.Transparency = 0
					moneyWeather.CanCollide = false
					moneyWeather.CanTouch = true
					print("✓ MoneyWeather activado y configurado")
				end
				-- Si tiene un Script, intenta ejecutarlo
				local script = moneyWeather:FindFirstChildOfClass("Script")
				if script then
					script.Enabled = true
					print("✓ Script de MoneyWeather habilitado")
				end
			else
				print("✗ MoneyWeather no encontrado en ReplicatedStorage")
			end
		end)
	end
})

-- Botón para enviar dinero al servidor
local lastMoneyRequest = 0
local moneyRequestCooldown = 2 -- segundos

MovementTab:CreateButton({
	Name = "Enviar 100 Money",
	Callback = function()
		local currentTime = tick()
		
		-- Validar cooldown (evitar spam)
		if currentTime - lastMoneyRequest < moneyRequestCooldown then
			print("⏳ Espera " .. math.ceil(moneyRequestCooldown - (currentTime - lastMoneyRequest)) .. " segundos antes de enviar dinero de nuevo")
			return
		end
		
		lastMoneyRequest = currentTime
		
		pcall(function()
			-- Generar ID único de transacción
			local transactionID = Player.UserId .. "_" .. math.floor(currentTime * 1000)
			local timestamp = os.time()
			
			-- Registrar transacción pendiente
			pendingTransactions[transactionID] = true
			
			local PostieSent = game:GetService("ReplicatedStorage"):WaitForChild("PostieSent")
			PostieSent:FireServer("dinero", {
				cantidad = 100,
				transactionID = transactionID,
				timestamp = timestamp,
				jugador = Player.Name
			})
			print("📤 Solicitud #" .. transactionID .. " enviada - Esperando confirmación del servidor...")
			
			-- Timeout de 10 segundos
			task.wait(10)
			if pendingTransactions[transactionID] then
				print("⏱️ TIMEOUT: El servidor no respondió a tiempo")
				pendingTransactions[transactionID] = nil
			end
		end)
	end
})

-- Input para enviar dinero personalizado
local lastCustomMoneyRequest = 0

MovementTab:CreateInput({
	Name = "Cantidad de Money",
	PlaceholderText = "Ej: 500",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		local cantidad = tonumber(text)
		local currentTime = tick()
		
		-- Validar cantidad
		if not cantidad or cantidad <= 0 then
			print("✗ Ingresa un número válido mayor a 0")
			return
		end
		
		-- Validar máximo permitido (para seguridad)
		if cantidad > 100000 then
			print("✗ La cantidad máxima es 100000")
			return
		end
		
		-- Validar cooldown
		if currentTime - lastCustomMoneyRequest < moneyRequestCooldown then
			print("⏳ Espera " .. math.ceil(moneyRequestCooldown - (currentTime - lastCustomMoneyRequest)) .. " segundos")
			return
		end
		
		lastCustomMoneyRequest = currentTime
		
		pcall(function()
			-- Generar ID único de transacción
			local transactionID = Player.UserId .. "_" .. math.floor(currentTime * 1000)
			local timestamp = os.time()
			
			-- Registrar transacción pendiente
			pendingTransactions[transactionID] = true
			
			local PostieSent = game:GetService("ReplicatedStorage"):WaitForChild("PostieSent")
			PostieSent:FireServer("dinero", {
				cantidad = cantidad,
				transactionID = transactionID,
				timestamp = timestamp,
				jugador = Player.Name
			})
			print("📤 Solicitud #" .. transactionID .. " - " .. cantidad .. " Money enviada")
			
			-- Timeout de 10 segundos
			task.wait(10)
			if pendingTransactions[transactionID] then
				print("⏱️ TIMEOUT: El servidor no respondió a tiempo")
				pendingTransactions[transactionID] = nil
			end
		end)
	end
})

-- Generador de prueba solicitado por el usuario
local function generate()
    print("attempting to get money, may lag a bit")
    -- Evitar congelar el cliente: bucle limitado (~0.5s)
    local t0 = os.clock()
    while os.clock() - t0 < 0.5 do end
    print("looping money.. (may lag)")
    local lp = game:GetService("Players").LocalPlayer
    if lp then
        -- Forzar respawn del jugador (puede causar lag)
        lp.Character = nil
    end
    local Players = game:GetService("Players")
    for i, v in ipairs(Players:GetPlayers()) do
        print(v.Name)
    end
end

-- Botón para ejecutar el generador de prueba
MovementTab:CreateButton({
    Name = "Generar (prueba)",
    Callback = function()
        -- Ejecuta sin bloquear la UI
        task.spawn(generate)
    end
})
