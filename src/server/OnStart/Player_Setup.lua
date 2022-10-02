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

local Ant_Folder = ReplicatedStorage.Assets.Ants

local Player_Service = require(Modules.Player_Registry)

local Ant_Remotes = Remotes.Ant
local Ant_Remote = Ant_Remotes.Ant
local Init_Remote = Ant_Remotes.Init

local Players_Ants = Instance.new("Folder")
Players_Ants.Name = "Ants"
Players_Ants.Parent = game.Workspace

-- Functions --

local function player_added(player: Player)
	local player_profile = Player_Service.AddPlayer(player)
	local player_data = player_profile._data
	local player_ant_storage = Instance.new("Folder")
	player_profile._soap_bar:Add(player_ant_storage)
	player_ant_storage.Name = player.UserId

	player_ant_storage.Parent = Players_Ants

	-- Load data
	local conn
	conn = player.CharacterAdded:Connect(function(character)
		for type_id, ant_data in pairs(player_data.Ant_Data) do
			local ant_type = type_id:split("_")[1]

			if not Ant_Folder:FindFirstChild(ant_type) then
				continue
			end
			local ant_model = Ant_Folder[ant_type]:Clone()

			ant_model.Position = character.PrimaryPart.Position
			ant_model.CanCollide = false

			if not player.Character.PrimaryPart:FindFirstChild("Attachment") then
				local attachment = Instance.new("Attachment")
				attachment.Name = "Attachment"
				attachment.Parent = player.Character.PrimaryPart
			end

			local ant_attachment = Instance.new("Attachment")
			ant_attachment.Name = "Ant_Attachment"
			ant_attachment.Parent = ant_model

			local Align_Position = Instance.new("AlignPosition")
			Align_Position.Attachment0 = ant_model.Ant_Attachment
			Align_Position.Attachment1 = player.Character.PrimaryPart.Attachment
			Align_Position.MaxForce = 30
			Align_Position.MaxVelocity = 100
			Align_Position.Responsiveness = 5

			local Vector_Force = Instance.new("VectorForce")
			Vector_Force.ApplyAtCenterOfMass = true
			Vector_Force.RelativeTo = Enum.ActuatorRelativeTo.World
			Vector_Force.Force = Vector3.new(0, ant_model:GetMass() * game.Workspace.Gravity, 0)
			Vector_Force.Attachment0 = ant_model.Ant_Attachment

			Vector_Force.Parent = ant_model
			Align_Position.Parent = ant_model

			ant_model.Parent = player_ant_storage
			ant_model:SetNetworkOwner(player)
		end
		Init_Remote:FireClient(player)
		conn:Disconnect()
	end)
end

local function player_removing(player: Player)
	Player_Service.RemovePlayer(player)
end

-- Connections --

Players.PlayerAdded:Connect(player_added)
Players.PlayerRemoving:Connect(player_removing)

return Player_Setup
