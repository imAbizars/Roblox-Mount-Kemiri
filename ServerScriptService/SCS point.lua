-- Leaderstats Setup and DataStore
local DataStoreService = game:GetService("DataStoreService")
local myDataStore = DataStoreService:GetDataStore("SummitData")

-- Function to create summit display above player's head
local function createSummitDisplay(player)
	local character = player.Character
	if not character then return end

	local head = character:FindFirstChild("Head")
	if not head then return end

	-- Remove existing display if it exists
	local existingDisplay = head:FindFirstChild("SummitDisplay")
	if existingDisplay then
		existingDisplay:Destroy()
	end

	-- Create BillboardGui
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "SummitDisplay"
	billboardGui.Size = UDim2.new(0,70, 0, 20) -- fixed size (px), konsisten
	billboardGui.StudsOffset = Vector3.new(0, 2, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Adornee = head
	billboardGui.Parent = head

	-- Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = billboardGui

	-- TextLabel
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "??? Summits: " .. (player.leaderstats.Summits.Value or 0)
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true -- auto scale biar "responsif"
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = frame


	-- Update display when summit count changes
	local function updateDisplay()
		if textLabel and textLabel.Parent then
			textLabel.Text = "??? Summits: " .. (player.leaderstats.Summits.Value or 0)
		end
	end

	-- Connect to summit value changes
	if player.leaderstats and player.leaderstats.Summits then
		player.leaderstats.Summits.Changed:Connect(updateDisplay)
	end

	return billboardGui
end
--Fungsi spawn di startpoint atau checkpoint (ini buat spawn ) 
local function spawnPlayerAtCheckpoint(player)
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local checkpoint = player:FindFirstChild("Checkpoint") and player.Checkpoint.Value
	local startPoint = workspace:FindFirstChild("StartPoint")
	if checkpoint then
		hrp.CFrame = checkpoint.CFrame + Vector3.new(0, 3, 0)
	elseif startPoint then
		hrp.CFrame = startPoint.CFrame + Vector3.new(0, 3, 0)
	end
end

game.Players.PlayerAdded:Connect(function(player)
	-- Buat leaderstats folder
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- Buat value Summit
	local summitStat = Instance.new("IntValue")
	summitStat.Name = "Summits"
	summitStat.Parent = leaderstats

	-- Data checkpoint
	local checkpointValue = Instance.new("ObjectValue")
	checkpointValue.Name = "Checkpoint"
	checkpointValue.Value = nil
	checkpointValue.Parent = player

	-- Data sudah summit atau belum (biar ga spam)
	local hasSummited = Instance.new("BoolValue")
	hasSummited.Name = "HasSummited"
	hasSummited.Value = false
	hasSummited.Parent = player

	-- Memuat data pemain
	local playerKey = "Player_" .. player.UserId
	local success, data = pcall(function()
		return myDataStore:GetAsync(playerKey)
	end)
	if success and data then
		summitStat.Value = data.Summits or 0
	else
		summitStat.Value = 0
	end

	-- Create summit display when character spawns
	player.CharacterAdded:Connect(function()
		wait(1) -- Wait a bit for character to fully load
		createSummitDisplay(player)
		-- Uncomment the line below if you have the spawn function
		spawnPlayerAtCheckpoint(player)
	end)

	-- If character already exists when player joins
	if player.Character then
		wait(1)
		createSummitDisplay(player)
	end
end)

-- Menyimpan data saat pemain keluar
game.Players.PlayerRemoving:Connect(function(player)
	local playerKey = "Player_" .. player.UserId
	local summits = player.leaderstats.Summits.Value
	local success,err = pcall(function()
		myDataStore:SetAsync(playerKey, {
			Summits = summits
		})
	end)
	if not success then
		warn("Gagal Menyimpan data untuk " .. player.Name .. ":" .. err)
	end
end)


-- Sistem checkpoint
for _, checkpoint in pairs(workspace:WaitForChild("Checkpoints"):GetChildren()) do
	if checkpoint:IsA("BasePart") then
		checkpoint.Touched:Connect(function(hit)
			local player = game.Players:GetPlayerFromCharacter(hit.Parent)
			if player and not player.HasSummited.Value then
				player.Checkpoint.Value = checkpoint
			end
		end)
	end
end

-- Sistem summit
local summitPart = workspace:WaitForChild("SummitPart") -- nama part summit
summitPart.Touched:Connect(function(hit)
	local character = hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		local player = game.Players:GetPlayerFromCharacter(character)
		if player and not player.HasSummited.Value then
			player.leaderstats.Summits.Value += 1
			player.HasSummited.Value = true
			player.Checkpoint.Value = nil
		end
	end
end)

-- Perbaikan di bagian StartPoint
local startPoint = workspace:FindFirstChild("StartPoint")
if startPoint and startPoint:IsA("BasePart") then
	startPoint.Touched:Connect(function(hit)
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			player.HasSummited.Value = false -- reset status summit saat menyentuh startpoint
		end
	end)
end