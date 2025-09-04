-- RoleModule.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RoleModule = {}

RoleModule.Roles = {
	Explorer = {
		Name = "Explorer",
		Color =Color3.fromRGB(66, 108, 54),
		Permissions = {}
	},
	Medis = {
		Name = "Medis",
		Color =Color3.fromRGB(108, 30, 30),
		Permissions = {}
	},
	Rescue = {
		Name = "Rescue",
		Color =Color3.fromRGB(171, 156, 44),
		Permissions = {}
	}
}

-- Tool mapping
local RoleTools = {
	Medis = { "Medical Kit" }, -- tool di ServerStorage
	Rescue = { "Rope" },      -- tool di ServerStorage
	Explorer = {}             -- tidak ada tool
}

-- Setup player role (default Explorer)
function RoleModule.SetupPlayer(player)
	local roleValue = Instance.new("StringValue")
	roleValue.Name = "Role"
	roleValue.Value = "Explorer"
	roleValue.Parent = player
end

-- Tambahkan tool sesuai role
function RoleModule.GiveToolsForRole(player, roleName)
	local backpack = player:WaitForChild("Backpack")
	local starterGear = player:WaitForChild("StarterGear")

	-- Bersihkan tool lama
	for _, item in ipairs(backpack:GetChildren()) do
		item:Destroy()
	end
	for _, item in ipairs(starterGear:GetChildren()) do
		item:Destroy()
	end

	local toolNames = RoleTools[roleName]
	if toolNames then
		for _, toolName in ipairs(toolNames) do
			local tool = ServerStorage:FindFirstChild(toolName)
			if tool then
				tool:Clone().Parent = backpack
				tool:Clone().Parent = starterGear
			else
				warn("Tool '"..toolName.."' tidak ditemukan di ServerStorage. Yang ada: ")
				for _, child in ipairs(ServerStorage:GetChildren()) do
					print("-", child.Name)
				end
			end
		end
	end
end


-- Set player role
function RoleModule.SetPlayerRole(player, roleName)
	local roleValue = player:FindFirstChild("Role")
	if roleValue and RoleModule.Roles[roleName] then
		roleValue.Value = roleName

		-- Update nametag color
		local character = player.Character or player.CharacterAdded:Wait()
		if character then
			RoleModule.UpdateNametagColor(player, roleName)
		end

		-- Tambahkan tool sesuai role
		RoleModule.GiveToolsForRole(player, roleName)

		print(player.Name .. " role set to: " .. roleName)
	end
end

-- Update nametag color
function RoleModule.UpdateNametagColor(player, roleName)
	local character = player.Character
	if not character then return end

	local role = RoleModule.Roles[roleName]
	if role then
		task.wait(0.1)
		local head = character:FindFirstChild("Head")
		if head then
			local billboardGui = head:FindFirstChild("NametagGui")
			if billboardGui then
				local nameLabel = billboardGui:FindFirstChild("NameLabel")
				if nameLabel then
					-- warna bisa diset sesuai role kalau mau
					nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
				end
			end
		end
	end
end

-- Get player role
function RoleModule.GetPlayerRole(player)
	local roleValue = player:FindFirstChild("Role")
	if roleValue then
		return roleValue.Value
	end
	return "Explorer"
end

-- Check permission
function RoleModule.HasPermission(player, permission)
	local roleName = RoleModule.GetPlayerRole(player)
	local role = RoleModule.Roles[roleName]
	if role and role.Permissions then
		return role.Permissions[permission] == true
	end
	return false
end

return RoleModule
