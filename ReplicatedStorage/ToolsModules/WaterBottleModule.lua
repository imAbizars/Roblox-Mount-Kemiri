local module = {}

local lastDrinkTime = {}
local drinkCooldown = 2 

function module.EnsureWaterValue(tool)
	local waterValue = tool:FindFirstChild("WaterLevel")
	return waterValue
end

function module.Drink(player, tool, amount)
	local now = tick()

	if lastDrinkTime[player] and now - lastDrinkTime[player] < drinkCooldown then
		return false 
	end
	lastDrinkTime[player] = now

	local waterValue = module.EnsureWaterValue(tool)
	waterValue.Value = math.max(0, waterValue.Value - (amount or 10))
	return true
end

function module.Refill(tool)
	local waterValue = module.EnsureWaterValue(tool)
	waterValue.Value = 100
end

return module
