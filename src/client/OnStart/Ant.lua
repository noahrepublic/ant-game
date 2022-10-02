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

local Promises = require(Utils.Promise)
local Soap = require(Utils.Soap)

local soap_bar = Soap.new()

local player = Players.LocalPlayer

return Ant
