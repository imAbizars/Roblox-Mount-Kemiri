local HeightModule = {}

local SEA_LEVEL = 0

function HeightModule.GetPlayerHeight(player) 
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return 0
	end
	local yPos = player.Character.HumanoidRootPart.Position.Y
	local height = math.floor((yPos + 26) - SEA_LEVEL)
	return height
	
end

return HeightModule
