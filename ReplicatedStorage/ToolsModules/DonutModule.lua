-- ReplicatedStorage/ToolModules/DonutModule
local DonutModule = {}

-- Pastikan DonutLevel
function DonutModule.EnsureDonutValue(tool)
	local donutValue = tool:FindFirstChild("DonutLevel")
	if not donutValue then
		donutValue = Instance.new("IntValue")
		donutValue.Name = "DonutLevel"
		donutValue.Value = 100 -- default penuh
		donutValue.Parent = tool
	end
	return donutValue 
end

-- Fungsi makan
function DonutModule.Eat(player, tool, amount)
	local donutValue = DonutModule.EnsureDonutValue(tool)

	if donutValue.Value <= 0 then
		return false
	end

	donutValue.Value = math.max(0, donutValue.Value - (amount or 25))

	-- Kalau donut habis, hapus dari Backpack & Character
	if donutValue.Value <= 0 then
		task.delay(0.2, function()
			if player.Backpack:FindFirstChild(tool.Name) then
				player.Backpack:FindFirstChild(tool.Name):Destroy()
			end
			if player.Character and player.Character:FindFirstChild(tool.Name) then
				player.Character:FindFirstChild(tool.Name):Destroy()
			end
		end)
	end

	return true
end

return DonutModule
