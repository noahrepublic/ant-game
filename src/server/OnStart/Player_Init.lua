
--[[ Player_Init
    Controls Player Data and setting up player related things: attributes, tasks, tycoon/base
]]

-- Services --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Variables --

local Player_Init = {}

local Modules = ServerScriptService.Server.Modules

local Player_Service = require(Modules.Player_Registry)

local Bases = game.Workspace.Spawn.Borrows:GetChildren()

-- Functions --

local function find_available_base()
    for _, base in ipairs(Bases) do
        if not base:GetAttribute("Owned") and base:GetAttribute("Owner") == 0 or base:GetAttribute("Owner") == nil then return base end
    end
end

local function Player_Added(player)
    local player_data = Player_Service.AddPlayer(player)._data

    -- Find a base for the player
    local player_base = find_available_base()
    player_base:SetAttribute("Owned", true)
    player_base:SetAttribute("Owner", player.UserId)

    player_data.Attributes.Base_Owned = player_base

end

local function Player_Disconnecting(player)
    local player_data = Player_Service.GetPlayer(player)._data

    local base = player_data.Attributes.Base_Owned
    player_data.Attributes.Base_Owned = nil
    base:SetAttribute("Owned", false)
    base:SetAttribute("Owner", nil)
end

-- Connections --

Players.PlayerAdded:Connect(Player_Added)
Players.PlayerRemoving:Connect(Player_Disconnecting)

return Player_Init