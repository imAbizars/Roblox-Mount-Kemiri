local SCSModule = {}
local DataStoreService = game:GetService("DataStoreService")
local myDataStore = DataStoreService:GetDataStore("SummitData")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local changeColorEvent = ReplicatedStorage:WaitForChild("ChangeCheckpointColor")

 --Spawn player di checkpoint atau start
--local function spawnPlayerAtCheckpoint(player)
--	local char = player.Character
--	if not char then return end
--	local hrp = char:WaitForChild("HumanoidRootPart")
--	local checkpoint = player:FindFirstChild("Checkpoint") and player.Checkpoint.Value
--	local startPoint = workspace:FindFirstChild("StartPoint")
--	if checkpoint then
--		hrp.CFrame = checkpoint.CFrame + Vector3.new(0, 3, 0)
--	elseif startPoint and startPoint:IsA("BasePart") then
--		hrp.CFrame = startPoint.CFrame + Vector3.new(0, 3, 0)
--	end
--end

-- Setup untuk player baru join
function SCSModule.SetupPlayer(player)
	
	-- Leaderstats folder
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- Summits value
	local summitStat = Instance.new("IntValue")
	summitStat.Name = "Summits"
	summitStat.Parent = leaderstats

	-- Checkpoint data
	local checkpointValue = Instance.new("ObjectValue")
	checkpointValue.Name = "Checkpoint"
	checkpointValue.Value = nil
	checkpointValue.Parent = player

	-- Sudah summit atau belum
	local hasSummited = Instance.new("BoolValue")
	hasSummited.Name = "HasSummited"
	hasSummited.Value = false
	hasSummited.Parent = player

	-- Load data dari DataStore
	local playerKey = "Player_" .. player.UserId
	local success, data = pcall(function()
		return myDataStore:GetAsync(playerKey)
	end)
	if success and data then
		summitStat.Value = data.Summits or 0
	else
		summitStat.Value = 0
	end

	-- Respawn handling
	player.CharacterAdded:Connect(function()
		spawnPlayerAtCheckpoint(player)
	end)
end

-- Save data saat keluar
function SCSModule.SavePlayer(player)
	local playerKey = "Player_" .. player.UserId
	local summits = player.leaderstats.Summits.Value
	local success, err = pcall(function()
		myDataStore:SetAsync(playerKey, {
			Summits = summits
		})
	end)
	if not success then
		warn("Gagal menyimpan data untuk " .. player.Name .. ":" .. err)
	end
end

-- Fungsi baru untuk mereset warna semua checkpoint
function SCSModule.ResetCheckpoints()
	local checkpointsFolder = workspace:WaitForChild("Checkpoints")
	for _, checkpointPart in pairs(checkpointsFolder:GetChildren()) do
		if checkpointPart:IsA("BasePart") then
			-- Kirim sinyal ke SEMUA klien untuk mereset warna
			changeColorEvent:FireAllClients(checkpointPart, false) -- 'false' berarti reset
		end
	end
end

-- Setup checkpoints
function SCSModule.SetupCheckpoints()
	local checkpointsFolder = workspace:WaitForChild("Checkpoints")

	for _, mainCheckpointPart in pairs(checkpointsFolder:GetChildren()) do
		if mainCheckpointPart:IsA("BasePart") then
			-- Atur warna awal saat game dimulai, kirim sinyal ke SEMUA klien
			changeColorEvent:FireAllClients(mainCheckpointPart, false)

			mainCheckpointPart.Touched:Connect(function(hit)
				local player = game.Players:GetPlayerFromCharacter(hit.Parent)

				if player and not player.HasSummited.Value then
					-- SERVER: Kirim sinyal ke klien untuk mengubah warna
					changeColorEvent:FireClient(player, mainCheckpointPart, true) -- 'true' berarti aktif

					-- SERVER: Simpan checkpoint (logika ini tetap di server)
					player.Checkpoint.Value = mainCheckpointPart
				end
			end)
		end
	end
end

-- Setup summit system
function SCSModule.SetupSummit()
	local summitPart = workspace:WaitForChild("SummitPart")
	summitPart.Touched:Connect(function(hit)
		local character = hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			local player = game.Players:GetPlayerFromCharacter(character)
			if player and not player.HasSummited.Value then
				player.leaderstats.Summits.Value += 1
				player.HasSummited.Value = true
				player.Checkpoint.Value = nil

				-- Mereset checkpoint setelah summit
				SCSModule.ResetCheckpoints()
			end
		end
	end)

	-- Reset HasSummited di StartPoint
	local startPoint = workspace:FindFirstChild("StartPoint")
	if startPoint and startPoint:IsA("BasePart") then
		startPoint.Touched:Connect(function(hit)
			local player = game.Players:GetPlayerFromCharacter(hit.Parent)
			if player then
				player.HasSummited.Value = false

				-- Mereset checkpoint saat pemain kembali ke start point
				SCSModule.ResetCheckpoints()
			end
		end)
	end
end

return SCSModule