--[[ Player_Init
    Controls Player Data and setting up player related things: attributes, tasks, tycoon/base
]]

-- Services --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Variables --

local Player_Init = {}

local Remotes = ReplicatedStorage.Remotes
local Modules = ServerScriptService.Server.Modules

local Player_Service = require(Modules.Player_Registry)
local Base = require(Modules.Base)

local Player_Remotes = Remotes.Player
local Player_Loaded_Remote = Player_Remotes.Player_Loaded

local Base_Entrances = game.Workspace.Spawn.Borrows:GetChildren()

-- Functions --

local function find_available_base()
	for _, base in ipairs(Base_Entrances) do
		if not base:GetAttribute("Owned") and base:GetAttribute("Owner") == 0 or base:GetAttribute("Owner") == nil then
			return base
		end
	end
end

local function Player_Added(player)
	local player_data = Player_Service.AddPlayer(player)._data

	-- Find a base for the player
	local base_entrance = find_available_base()
	base_entrance:SetAttribute("Owned", true)
	base_entrance:SetAttribute("Owner", player.UserId)

	player_data.Attributes.Base_Owned = base_entrance

	local base = Base.new(player_data.Base_Data)
	Player_Loaded_Remote:FireClient(player, base_entrance, ReplicatedStorage.Assets.Starter_Base:Clone()) -- temporary cloning starter base
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
