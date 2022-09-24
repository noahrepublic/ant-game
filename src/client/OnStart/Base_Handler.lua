--[[ Base_Handler
    Handles entering and exiting bases
]]

-- Services --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables --

local Base_Handler = {}

local Remotes = ReplicatedStorage.Remotes
local Utils = ReplicatedStorage.Utils

local Player_Remotes = Remotes.Player
local Player_Loaded = Player_Remotes.Player_Loaded

local Promise = require(Utils.Promise)
local Signal = require(Utils.Signal)
local Soap = require(Utils.Soap)

local soap_bar = Soap.new()

local player = Players.LocalPlayer

local player_base

-- Functions --

local function enter_base()
	player_base.Parent = game.Workspace
	print("Entered base")
end

local function exit_base() end -- call when we have an exit feature :skull:

-- Connections --

player_base = Promise.new(function(resolve, reject)
	soap_bar:Add(Player_Loaded.OnClientEvent:Connect(function(entrance, base)
		(entrance and base and resolve or reject)(entrance, base)
	end))
end)
	:andThen(function(entrance, base)
		soap_bar:Scrub()
		player_base = base

		entrance.Touched:Connect(function(hit)
			if hit:IsDescendantOf(player.Character) then
				enter_base()
			end
		end)
	end)
	:catch(function()
		warn("Failed to load base, no base param.")
		soap_bar:Scrub()
	end)

return Base_Handler
