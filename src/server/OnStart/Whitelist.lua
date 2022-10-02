local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

Players.PlayerAdded:Connect(function(player)
	if not player:GetRankInGroup(14750392) >= 50 and not RunService:IsStudio() then
		player:Kick("Closed testing. Please wait for the game to be released.")
	end
end)
