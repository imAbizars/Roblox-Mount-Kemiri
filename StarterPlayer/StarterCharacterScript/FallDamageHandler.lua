-- Script untuk StarterCharacterScripts: Memberi damage saat jatuh
local character = script.Parent
local humanoid = character:FindFirstChildOfClass("Humanoid")
local hrp = character:FindFirstChild("HumanoidRootPart")

if not humanoid or not hrp then return end

local lastY = hrp.Position.Y
local falling = false
local fallStartY = lastY
local minFallSpeed = 50 -- Minimum kecepatan jatuh untuk mulai kena damage
local damageMultiplier = 1.5 -- Semakin besar, semakin sakit jatuhnya

game:GetService("RunService").Heartbeat:Connect(function()
    if humanoid.Health <= 0 then return end
    local currentY = hrp.Position.Y
    local velocityY = hrp.Velocity.Y

    if velocityY < -minFallSpeed and not falling then
        -- Mulai jatuh
        falling = true
        fallStartY = currentY
    elseif velocityY >= -2 and falling then
        -- Mendarat
        local fallDistance = fallStartY - currentY
        if fallDistance > 10 then
            local damage = (fallDistance - 10) * damageMultiplier
            humanoid.Health = math.max(0, humanoid.Health - damage)
        end
        falling = false
    end
    lastY = currentY
end)

