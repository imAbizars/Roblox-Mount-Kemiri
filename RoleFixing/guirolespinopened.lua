-- RoleSpinClient (LocalScript di StarterPlayerScripts)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage:WaitForChild("ShowGui")

-- GUI di StarterGui
local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("RoleSpinGUI")

-- Fungsi buka GUI
local function openGUI()
	gui.Enabled = true
end

-- Saat server kirim event ? buka GUI
event.OnClientEvent:Connect(function()
	openGUI()
end)
