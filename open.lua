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
	local character = Player.Character or Player.CharacterAdded:Wait()
	humanoid = character:FindFirstChildOfClass("Humanoid")
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
	if not humanoid then
		resolveHumanoid()
	end
	if humanoid then
		humanoid.WalkSpeed = desiredSpeed
	end
end

local function updateSpeedLabel()
	if SpeedLabel and SpeedLabel.Set then
		SpeedLabel:Set("WALK SPEED: " .. tostring(desiredSpeed))
	end
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
		if not humanoid then
			resolveHumanoid()
		end
		if humanoid then
			humanoid.WalkSpeed = 16
			desiredSpeed = 16
			updateSpeedLabel()
		end
	end
})

-- ==========================
-- Pestaña educativa (local):
-- No toca datos del servidor
-- ==========================
local EducationalTab = Window:CreateTab("Educativo")

local rebirths = 0
local money = 0
local maxMoney = 1000000
local perClick = 1000

local NoteLabel = EducationalTab:CreateLabel("Modo educativo: local, sin afectar el servidor")
local RebirthLabel = EducationalTab:CreateLabel("Rebirths (local): 0")
local MoneyLabel = EducationalTab:CreateLabel("Money (local): 0")

local function updateEducationalUI()
	if RebirthLabel and RebirthLabel.Set then
		RebirthLabel:Set("Rebirths (local): " .. rebirths)
	end
	if MoneyLabel and MoneyLabel.Set then
		MoneyLabel:Set("Money (local): " .. money)
	end
end

EducationalTab:CreateInput({
	Name = "Incremento de dinero por click",
	PlaceholderText = "Ej: 1000",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		local n = tonumber(text)
		if n then
			perClick = clamp(math.floor(n), 1, 100000)
		end
	end
})

EducationalTab:CreateButton({
	Name = "Sumar dinero (local)",
	Callback = function()
		money = clamp(money + perClick, 0, maxMoney)
		updateEducationalUI()
	end
})

EducationalTab:CreateButton({
	Name = "Sumar 1 rebirth (local)",
	Callback = function()
		rebirths = clamp(rebirths + 1, 0, 100000)
		updateEducationalUI()
	end
})

EducationalTab:CreateButton({
	Name = "Reiniciar contadores (local)",
	Callback = function()
		money = 0
		rebirths = 0
		updateEducationalUI()
	end
})
