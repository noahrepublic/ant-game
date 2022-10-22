--[[ Ant.lua
    Handles replication, movement and collection systems
]]

-- Services --

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables --

local Ant = {}

local Assets = ReplicatedStorage.Assets
local Remotes = ReplicatedStorage.Remotes
local Shared = ReplicatedStorage.Shared
local Utils = ReplicatedStorage.Utils

local Ant_Remotes = Remotes.Ant
local Ant_Remote = Ant_Remotes.Ant
local Init_Remote = Ant_Remotes.Init

local Promise = require(Utils.Promise)
local Soap = require(Utils.Soap)

local Metronome = require(Shared.Metronome)
local Settings = require(Shared.Settings)

local soap_bar = Soap.new()

local player = Players.LocalPlayer
local player_ant_folder

-- Functions --

local function on_respawn()
	Promise.new(function(resolve)
		if not player.Character:FindFirstChild("HumanoidRootPart") then
			repeat
				task.wait()
			until player.Character.HumanoidRootPart ~= nil
			resolve(player.Character.HumanoidRootPart)
		end
	end):andThen(function(root_part)
		for _, ant in pairs(player_ant_folder:GetChildren()) do
			if not root_part:FindFirstChild(ant.Name) then
				local attachment = Instance.new("Attachment")
				attachment.Name = ant.Name
				attachment.Parent = root_part
			end
			if ant.AlignPosition then
				ant.AlignPosition.Attachment1 = root_part[ant.Name]
			end
		end
	end)
end

local function on_server_init()
	soap_bar:Scrub()

	player_ant_folder = game.Workspace.Ants[player.UserId]
	player.CharacterAdded:Connect(on_respawn)

	Metronome.CreateTask(10, function()
		for _, attachment in pairs(CollectionService:GetTagged("Ant_Controller")) do
			attachment.WorldPosition = Vector3.new(
				player.Character.PrimaryPart.Position.X,
				player.Character.Head.Position.Y,
				player.Character.PrimaryPart.Position.Z
			) + Vector3.new(
				math.random(-Settings.Ant_Offset_Threshold, Settings.Ant_Offset_Threshold),
				0,
				math.random(-Settings.Ant_Offset_Threshold, Settings.Ant_Offset_Threshold)
			)
		end
	end)
end

-- Connections --

soap_bar:Add(Init_Remote.OnClientEvent:Connect(on_server_init))

return Ant
