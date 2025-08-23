--ReplicatedStorage/MainModules/StatsModule
local StatsModule = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Config
local DECAY_HUNGRY_INTERVAL = 30
local DECAY_THIRSTY_INTERVAL = 25
local DECAY_HUNGRY_AMOUNT = 1
local DECAY_THIRSTY_AMOUNT = 1
local MIN_HUNGRY = 20
local MIN_THIRSTY = 20
local SLOW_WALK_SPEED = 8
local NORMAL_WALK_SPEED = 16
local HUNGRY_HEALTH_DAMAGE = 1

local UPDATE_EVENT = ReplicatedStorage:FindFirstChild("UpdateStats")
if not UPDATE_EVENT then
	UPDATE_EVENT = Instance.new("RemoteEvent")
	UPDATE_EVENT.Name = "UpdateStats"
	UPDATE_EVENT.Parent = ReplicatedStorage
end

function StatsModule.UpdateClient(player, humanoid, hungry, thirsty)
	if humanoid.Health <= 0 then
		return 
	end

	UPDATE_EVENT:FireClient(player, {
		Health = humanoid.Health,
		MaxHealth = humanoid.MaxHealth,
		Hungry = hungry.Value,
		MaxHungry = 100,
		Thirsty = thirsty.Value,
		MaxThirsty = 100
	})
end

function StatsModule.SetupPlayer(player)
	local statsFolder = Instance.new("Folder")
	statsFolder.Name = "Stats"
	statsFolder.Parent = player

	local hungry = Instance.new("IntValue")
	hungry.Name = "Hungry"
	hungry.Value = 100
	hungry.Parent = statsFolder

	local thirsty = Instance.new("IntValue")
	thirsty.Name = "Thirsty"
	thirsty.Value = 100
	thirsty.Parent = statsFolder

	player.CharacterAdded:Connect(function(char)
		local humanoid = char:WaitForChild("Humanoid")

		humanoid.Health = humanoid.MaxHealth
		hungry.Value = 100
		thirsty.Value = 100

		task.delay(0.15, function()
			if player and player.Parent then
				StatsModule.UpdateClient(player, humanoid, hungry, thirsty)
			end
		end)

		humanoid.HealthChanged:Connect(function()
			StatsModule.UpdateClient(player, humanoid, hungry, thirsty)
		end)

		-- Loop Hungry
		task.spawn(function()
			while player.Parent and humanoid and humanoid.Parent do
				if hungry.Value > 0 then
					hungry.Value -= DECAY_HUNGRY_AMOUNT
				end
				if hungry.Value <= MIN_HUNGRY then
					humanoid.Health = math.max(0, humanoid.Health - HUNGRY_HEALTH_DAMAGE)
				end
				StatsModule.UpdateClient(player, humanoid, hungry, thirsty)
				task.wait(DECAY_HUNGRY_INTERVAL)
			end
		end)

		-- Loop Thirsty
		task.spawn(function()
			while player.Parent and humanoid and humanoid.Parent do
				if thirsty.Value > 0 then
					thirsty.Value -= DECAY_THIRSTY_AMOUNT
				end
				if thirsty.Value <= MIN_THIRSTY then
					humanoid.WalkSpeed = SLOW_WALK_SPEED
				else
					humanoid.WalkSpeed = NORMAL_WALK_SPEED
				end
				StatsModule.UpdateClient(player, humanoid, hungry, thirsty)
				task.wait(DECAY_THIRSTY_INTERVAL)
			end
		end)
	end)
end

return StatsModule
