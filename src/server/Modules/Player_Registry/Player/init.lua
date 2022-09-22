--[[ Player Class
	Stores information about the player
]]

--@noahrepublic
--@Written 08/11/2022

-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables --

local Player = {}
Player.__index = Player

local Utils = ReplicatedStorage.Utils

local Soap = require(Utils.Soap)
local ProfileService = require(script.ProfileService)

local Data_Template = require(script.Data_Template)

local DataStore = ProfileService.GetProfileStore("Development_Data", Data_Template)

-- Functions --

--Private:

local function init(self)
	local player = self.Player

	self._soap_bar = Soap.new()

	do
		local profile = DataStore:LoadProfileAsync("Player_" .. player.UserId, "ForceLoad")

		if profile == nil then
			player:Kick()
			return
		end

		profile:AddUserId(player.UserId)
		profile:Reconcile() -- rebuild

		self._soap_bar:Add(profile:ListenToRelease(function()
			player:Kick()
		end))

		-- player left
		if not player:IsDescendantOf(Players) then
			profile:Release()
			return
		end

		self._data = profile.Data
		self._profile = profile
	end
end

--Public:
function Player.new(plr: Player)
	local player_class = setmetatable({}, Player)
	player_class.Player = plr
	player_class.Attributes = {}
	init(player_class)
	return player_class
end

function Player:Disconnect()
	self._soap_bar:Scrub() -- Disconnect everything
	self._profile:Release()
	self.Player:Kick() -- kick incase it was a custom :Disconnect() call
end

function Player:SetAttribute(name: string, value: any): any
	self.Attributes[name] = value
	return self.Attributes[name]
end

function Player:GetAttribute(name: string)
	return self.Attributes[name]
end

function Player:RemoveAttribute(name: string)
	self.Attributes[name] = nil
end

return Player
