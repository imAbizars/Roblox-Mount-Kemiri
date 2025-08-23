local Players = game:GetService("Players")

-- modules dari replicated storage
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local StatsModule = require(ReplicatedStorage.MainModules.StatsModule)
local RoleModule = require(ReplicatedStorage.MainModules.RoleModule)
local TimeModule = require(ReplicatedStorage.MainModules.TimeModule)
local NoRegenModule = require(ReplicatedStorage.MainModules.NoregenModule)
local WaterBottleModule = require(ReplicatedStorage.ToolModules.WaterBottleModule)
local DonutModule = require(ReplicatedStorage.ToolModules.DonutModule)

-- RemoteEvents
local UPDATE_EVENT = ReplicatedStorage:WaitForChild("UpdateStats") 
local MODIFY_STATS_EVENT = ReplicatedStorage:FindFirstChild("ModifyStats") or Instance.new("RemoteEvent")
MODIFY_STATS_EVENT.Name = "ModifyStats"
MODIFY_STATS_EVENT.Parent = ReplicatedStorage

local DrinkEvent = ReplicatedStorage:WaitForChild("WaterBottle_Remote")
local DonutEvent = ReplicatedStorage:WaitForChild("Donut_Remote")

local timeStarted = false
if not timeStarted then
	timeStarted = true
	TimeModule.StartCycle(12) 
end

-- player join
Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("Role", "User") 
	StatsModule.SetupPlayer(player)
	NoRegenModule.DisableRegenForPlayer(player)
	local waterBottle = ServerStorage.Tools:WaitForChild("Water Bottle"):Clone()
	WaterBottleModule.EnsureWaterValue(waterBottle) -- pasang WaterLevel sekarang
	waterBottle.Parent = player:WaitForChild("Backpack")
	player.CharacterAdded:Connect(function(char)
		char.ChildAdded:Connect(function(item)
			if item:IsA("Tool") then
				if item.Name == "Water Bottle" then
					WaterBottleModule.EnsureWaterValue(item)
				elseif item.Name == "Donut" then
					DonutModule.EnsureDonutValue(item)
				end
			end
		end)
	end)
end)


DrinkEvent.OnServerEvent:Connect(function(player)
	local char = player.Character
	if not char then return end

	local tool = char:FindFirstChild("Water Bottle")
	if not tool then return end

	local success = WaterBottleModule.Drink(player, tool, 10)
	if success then
		local stats = player:FindFirstChild("Stats")
		if stats then
			local thirsty = stats:FindFirstChild("Thirsty")
			if thirsty then
				thirsty.Value = math.min(100, thirsty.Value + 15)
				local humanoid = char:FindFirstChild("Humanoid")
				if humanoid then
					StatsModule.UpdateClient(player, humanoid, stats.Hungry, stats.Thirsty)
				end 
			end
		end
	end
end)

DonutEvent.OnServerEvent:Connect(function(player)
	local char = player.Character
	if not char then return end 
	
	local tool = char:FindFirstChild("Donut")
	if not tool then return end 
	
	local success = DonutModule.Eat(player,tool,100)
	if success then
		local stats = player:FindFirstChild("Stats")
		if stats then
			local hungry = stats:FindFirstChild("Hungry")
			if hungry then
				hungry.Value = math.min(100, hungry.Value + 50) 
				local humanoid = char:FindFirstChild("Humanoid")
				if humanoid then
					StatsModule.UpdateClient(player, humanoid, stats.Hungry, stats.Thirsty)
				end
			end
		end
	end
end)


-- Role khusus modify stats
MODIFY_STATS_EVENT.OnServerEvent:Connect(function(player, targetName, statName, newValue)
	if not RoleModule.HasPermission(player) then
		warn(player.Name .. " top up robux dulu yah kalo mau ganti role!?")
		return
	end

	local target = Players:FindFirstChild(targetName)
	if target and target:FindFirstChild("Stats") then
		local stat = target.Stats:FindFirstChild(statName)
		if stat then
			stat.Value = newValue
			local humanoid = target.Character and target.Character:FindFirstChild("Humanoid")
			if humanoid then
				StatsModule.UpdateClient(target, humanoid, target.Stats.Hungry, target.Stats.Thirsty)
			end
		end
	end
end)
