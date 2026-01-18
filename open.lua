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
	pcall(function()
		local character = Player.Character or Player.CharacterAdded:Wait()
		if character then
			humanoid = character:FindFirstChildOfClass("Humanoid")
		end
	end)
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

-- Crear una pestaña de movimiento
local MovementTab = Window:CreateTab("Movimiento")

-- Label de estado de velocidad y utilidades
local SpeedLabel = MovementTab:CreateLabel("WALK SPEED: " .. tostring(desiredSpeed))

local function applySpeed()
	if not humanoid or not humanoid.Parent then
		resolveHumanoid()
	end
	if humanoid and humanoid.Parent then
		pcall(function()
			humanoid.WalkSpeed = desiredSpeed
		end)
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
		applySpeed()
		updateSpeedLabel()
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

-- Toggle para activar/desactivar la auto-aplicación desde el input
MovementTab:CreateToggle({
	Name = "Auto-aplicar velocidad",
	CurrentValue = true,
	Callback = function(value)
		autoApply = value
	end
})

-- Toggle para mantener la velocidad (legit auto-farm)
MovementTab:CreateToggle({
	Name = "LEGIT AUTO-FARM",
	CurrentValue = false,
	Callback = function(value)
		autoFarm = value
		if maintainConn then
			maintainConn:Disconnect()
			maintainConn = nil
		end
		if autoFarm then
			maintainConn = RunService.Heartbeat:Connect(function()
				if not humanoid or not humanoid.Parent then
					resolveHumanoid()
				end
				if humanoid and humanoid.WalkSpeed ~= desiredSpeed then
					applySpeed()
				end
			end)
		end
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
