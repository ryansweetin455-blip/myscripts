
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "+1 Speed Bridge Building",
	LoadingTitle = "Rayfield UI",
	ConfigurationSaving = {
		Enabled = false
	}
})

-- Movement: button to run faster and input for speed
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

local desiredSpeed = 32 -- default value to run faster
local autoApply = true -- toggle to auto apply from input
local RunService = game:GetService("RunService")
local autoFarm = false
local maintainConn
local pendingTransactions = {} -- Track pending transactions

-- Create a movement tab
local MovementTab = Window:CreateTab("Movement")

-- Listen for server responses
local function setupResponseListener()
	pcall(function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local PostieReceived = ReplicatedStorage:WaitForChild("PostieReceived", 5)
        
		PostieReceived.OnClientEvent:Connect(function(transactionID, success, message)
			if pendingTransactions[transactionID] then
				if success then
					print("✅ CONFIRMED: " .. message)
				else
					print("❌ REJECTED: " .. message)
				end
				pendingTransactions[transactionID] = nil
			end
		end)
		print("✓ Server listener set up")
	end)
end

setupResponseListener()

-- Speed status label and utilities
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
			warn("Error applying speed: " .. tostring(err))
		end
		return success
	else
		warn("Humanoid not found. Try again in a moment.")
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

-- Slider to adjust speed easily
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
			-- If not applied, try again after a short delay
			task.wait(0.1)
			applySpeed()
			updateSpeedLabel()
		end
	end
})

MovementTab:CreateInput({
	Name = "Desired Speed",
	PlaceholderText = "Ex: 32",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		local n = tonumber(text)
		if n then
			desiredSpeed = clamp(n, 8, 500)
			if autoApply then
				applySpeed()
			end
			-- Sync the slider
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
	Name = "Run Faster",
	Callback = function()
		applySpeed()
		updateSpeedLabel()
	end
})

-- Button to reset to standard speed
MovementTab:CreateButton({
	Name = "Reset Speed (16)",
	Callback = function()
		desiredSpeed = 16
		applySpeed()
		-- Sync the slider
		pcall(function()
			if SpeedSlider and SpeedSlider.SetValue then
				SpeedSlider:SetValue(16)
			end
		end)
		updateSpeedLabel()
	end
})

-- Button to print the whole game structure in console
MovementTab:CreateButton({
	Name = "Print Full Game (Console)",
	Callback = function()
		local function printChildren(parent, indent)
			indent = indent or ""
			for _, child in ipairs(parent:GetChildren()) do
				print(indent .. "├─ " .. child.Name .. " (" .. child.ClassName .. ")")
			end
		end
        
		print("\n" .. string.rep("=", 50))
		print("GAME STRUCTURE")
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
        
		-- ServerStorage (may error if you don't have access)
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
		print("END OF STRUCTURE")
		print(string.rep("=", 50) .. "\n")
	end
})

-- Toggle to enable/disable infinite money and auto rebirth loop
local autoFarmActive = false
local autoFarmThread

MovementTab:CreateToggle({
	Name = "Auto Money & Rebirth (Loop)",
	CurrentValue = false,
	Callback = function(state)
		autoFarmActive = state
		if autoFarmActive then
			autoFarmThread = task.spawn(function()
				while autoFarmActive do
					pcall(function()
						game:GetService("ReplicatedStorage").Packages.Bridge.Remotes.BridgePurchase.RemoteEvent:FireServer(-9e100)
						game:GetService("ReplicatedStorage").Packages.Bridge.Remotes.Rebirth.RemoteEvent:FireServer()
					end)
					task.wait()
				end
			end)
		end
	end
})
