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

local Ant_Remotes = Remotes.Ant
local Ant_Remote = Ant_Remotes.Ant
local Init_Remote = Ant_Remotes.Init

local Promise = require(Utils.Promise)
local Soap = require(Utils.Soap)

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
		if not root_part:FindFirstChild("Attachment") then
			local attachment = Instance.new("Attachment")
			attachment.Name = "Attachment"
			attachment.Parent = root_part
		end
		for _, ant in pairs(player_ant_folder:GetDescendants()) do
			if ant:IsA("AlignPosition") then
				ant.Attachment1 = root_part:FindFirstChild("Attachment")
			end
		end
	end)
end

local function on_server_init()
	soap_bar:Scrub()

	player_ant_folder = game.Workspace.Ants[player.UserId]
	player.CharacterAdded:Connect(on_respawn)
end

-- Connections --

soap_bar:Add(Init_Remote.OnClientEvent:Connect(on_server_init))

return Ant
