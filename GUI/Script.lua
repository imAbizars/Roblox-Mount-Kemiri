-- ServerScriptService/RoleSpin.server.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvents (dibuat di server, diakses client dengan :WaitForChild)
local SpinRequest = ReplicatedStorage:FindFirstChild("SpinRequest")
if not SpinRequest then
	SpinRequest = Instance.new("RemoteEvent")
	SpinRequest.Name = "SpinRequest"
	SpinRequest.Parent = ReplicatedStorage
end

local SpinResult = ReplicatedStorage:FindFirstChild("SpinResult")
if not SpinResult then
	SpinResult = Instance.new("RemoteEvent")
	SpinResult.Name = "SpinResult"
	SpinResult.Parent = ReplicatedStorage
end

-- RoleModule
local RoleModule = require(ReplicatedStorage.RoleModule)

-- Atur chance di SERVER saja (supaya client tidak bisa curang)
-- Total bebas (otomatis dinormalisasi)
local ROLES_WITH_CHANCE = {
	{ Role = "Explorer", Chance = 50 }, -- 50%
	{ Role = "Medis",    Chance = 30 }, -- 30%
	{ Role = "Rescue",   Chance = 20 }, -- 20%
}

local function chooseRoleWeighted()
	local total = 0
	for _, r in ipairs(ROLES_WITH_CHANCE) do
		total += r.Chance
	end
	if total <= 0 then
		return "Explorer"
	end
	local rng = Random.new() -- seed internal; cukup untuk keperluan game
	local pick = rng:NextInteger(1, total)
	local cum = 0
	for _, r in ipairs(ROLES_WITH_CHANCE) do
		cum += r.Chance
		if pick <= cum then
			return r.Role
		end
	end
	return "Explorer"
end

-- Cooldown biar gak spam spin
local COOLDOWN_SECONDS = 3
local lastSpinAt = {} -- [player] = tick()

Players.PlayerAdded:Connect(function(player)
	-- Role default + sinkron warna saat respawn
	RoleModule.SetupPlayer(player)
	player.CharacterAdded:Connect(function()
		local roleNow = RoleModule.GetPlayerRole(player)
		RoleModule.UpdateNametagColor(player, roleNow)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	lastSpinAt[player] = nil
end)

SpinRequest.OnServerEvent:Connect(function(player)
	local now = tick()
	if lastSpinAt[player] and (now - lastSpinAt[player]) < COOLDOWN_SECONDS then
		-- Masih cooldown: cukup kirim info role sekarang tanpa mengubah
		local currentRole = RoleModule.GetPlayerRole(player)
		SpinResult:FireClient(player, currentRole, true) -- true = onCooldown
		return
	end
	lastSpinAt[player] = now

	-- Pilih role dengan weighted chance (server-side)
	local chosen = chooseRoleWeighted()
	-- Validasi terhadap RoleModule
	if not RoleModule.Roles[chosen] then
		chosen = "Explorer"
	end

	-- Set role di server
	RoleModule.SetPlayerRole(player, chosen)

	-- Kirim hasil ke client (untuk hentikan animasi tepat di role)
	SpinResult:FireClient(player, chosen, false) -- false = bukan cooldown
end)
