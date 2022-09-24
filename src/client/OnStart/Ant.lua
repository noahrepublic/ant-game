
--[[ Ant.lua
    Handles replication, movement and collection systems
]]

-- Services --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables --

local Ant = {}

local Assets = ReplicatedStorage.Assets
local Remotes = ReplicatedStorage.Remotes
local Utils = ReplicatedStorage.Utils

local Ant_Folder = Assets.Ants

local Ant_Remotes = Remotes.Ant
local Private_Replication = Ant_Remotes.Ant
local Ant_Replication = Ant_Remotes.Replicate

local Promises = require(Utils.Promise)
local Soap = require(Utils.Soap)

local soap_bar = Soap.new()

local player = Players.LocalPlayer
local Ant_Storage

local last_update = {} -- [player] = {[ant_id] = {positional_data}}

-- Functions --

local function private_replication(ant_data) -- handles only the client's ant
    for id_type, data in ipairs(ant_data) do
        local ant_type = id_type:split("_")[2]
        local ant_model = Ant_Folder[ant_type]:Clone()

        ant_model:SetAttribute("Level", ant_data.Level)
        ant_model:SetAttribute("Backpack_Max", ant_data.Backpack_Max)

        ant_model.Parent = Ant_Storage
    end
end

local function replicate_ants(ant_owner, ant_data)
    if ant_owner == player then return end
    for id_type, data in ipairs(ant_data) do
        local ant_type = id_type:split("_")[2]
        if not ant_data.Position then
            -- player just joined, replicate, no position needed
        end
    end
end

-- Connections --

Promises.new(function(resolve)
    soap_bar:Add(Private_Replication.OnClientEvent(resolve))
end):andThen(function()
    soap_bar:Scrub()
    Ant_Storage = Instance.new("Folder")
    Ant_Storage.Name = player.Name .. "_Ants"
    Ant_Storage.Parent = game.Workspace.Ants
end)

Private_Replication.OnClientEvent:Connect(private_replication)
Ant_Replication.OnClientEvent:Connect(replicate_ants)

return Ant