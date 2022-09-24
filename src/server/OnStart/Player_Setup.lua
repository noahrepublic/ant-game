--[[ Player_Setup.lua
    Saves and manages player related data for other scripts
]]

-- Services --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Variables --

local Player_Setup = {}

local Modules = ServerScriptService.Server.Modules
local Remotes = ReplicatedStorage.Remotes
local Utils = ReplicatedStorage.Utils

local Player_Service = require(Modules.Player_Registry)

local Ant_Remotes = Remotes.Ant
local Replicate_All_Remote = Ant_Remotes.Replicate
local Private_Replicate = Ant_Remotes.Ant

local Players_Ants = Instance.new("Folder")
Players_Ants.Name = "Ants"
Players_Ants.Parent = game.Workspace

-- Functions --

local function player_added(player :Player)
    local player_data = Player_Service.AddPlayer(player)

    local players_storage_folder = Instance.new("Folder")
    players_storage_folder.Name = player.Name .. "_Storage"

    players_storage_folder.Parent = ReplicatedStorage

    Private_Replicate:FireClient(player, player.Ant_Data)
    Replicate_All_Remote:FireAllClients(player, player_data.Ant_Data)
end

local function player_removing(player :Player)
end

-- Connections --

Players.PlayerAdded:Connect(player_added)
Players.PlayerRemoving:Connect(player_removing)

return Player_Setup