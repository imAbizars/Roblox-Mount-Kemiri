local NoRegenModule = {}



local function disableHealthRegen(humanoid)

	-- hapus script Health bawaan Roblox

	local function removeHealthScript()

		local healthScript = humanoid:FindFirstChild("Health")

		if healthScript then

			healthScript:Destroy()

		end

	end



	-- hapus health langsung

	removeHealthScript()



	-- apus lagi kalo muncul

	humanoid.ChildAdded:Connect(function(child)

		if child.Name == "Health" then

			child:Destroy()

		end

	end)

	-- opsional

--	local lastHealth = humanoid.Health

--	humanoid.HealthChanged:Connect(function(newHealth)

--		if newHealth > lastHealth then

--			humanoid.Health = lastHealth

--		else

--			lastHealth = newHealth

--		end

--	end)

--end



function NoRegenModule.DisableRegenForPlayer(player)

	player.CharacterAdded:Connect(function(char)

		local humanoid = char:WaitForChild("Humanoid", 5)

		if humanoid then

			disableHealthRegen(humanoid)

		end

	end)

end
end


return NoRegenModule