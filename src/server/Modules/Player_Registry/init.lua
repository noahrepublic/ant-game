--[[ Player Registry
	Stores custom Player Objects from the "Player" class
]]

--@noahrepublic
--@Written 08/12/2022

local Player_Registry = {}
Player_Registry.__index = Player_Registry

local Player = require(script:FindFirstChild("Player"))
local Players = {} -- Stores players

-- Functions --

function Player_Registry.AddPlayer(plr: Player)
	local player_class = Player.new(plr)
	Players[plr] = player_class
	return player_class
end

function Player_Registry.GetPlayer(plr: Player)
	return Players[plr]
end

function Player_Registry.RemovePlayer(plr: Player)
	local player_class = Player_Registry.GetPlayer(plr)
	assert(player_class ~= nil, "Passed player value is nil!")
	Players[plr] = nil
	player_class:Disconnect()
end

Player_Registry.Disconnect = Player_Registry.RemovePlayer

return Player_Registry
