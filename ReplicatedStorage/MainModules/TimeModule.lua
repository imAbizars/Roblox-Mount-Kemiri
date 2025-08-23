local TimeModule = {}

local Lighting = game:GetService("Lighting")
local totalMinutesInDay = 24 * 60

function TimeModule.StartCycle(dayLength)
	dayLength = dayLength or 12
	if dayLength <= 0 then dayLength = 1 end

	local cycleTime = dayLength * 60 
	local timeRatio = totalMinutesInDay / cycleTime

	-- waktu awal jam 6 pagi
	Lighting:SetMinutesAfterMidnight(6 * 60)

	-- Loop siklus waktu global
	task.spawn(function()
		while true do
			local minutes = (Lighting:GetMinutesAfterMidnight() + timeRatio * (1/15)) % totalMinutesInDay
			Lighting:SetMinutesAfterMidnight(minutes)
			task.wait(1/15)
		end
	end)
end

return TimeModule
