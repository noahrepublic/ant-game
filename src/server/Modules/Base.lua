--[[ Base.lua 
    Handles base data, loading and saving + rebuilding
]]

-- Services --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables --

local Base = {}
Base.__index = Base

-- Functions --
--Private:

local function create_wall(position, rotation)
	local wall = Instance.new("Part")
	wall.Anchored = true
	wall.Size = Vector3.new(100, 10, 100)
	wall.Position = position
	wall.Rotation = rotation
	return wall
end

--Public:
--[[ Base.new
    Creates a new base object
    @param base_data: table { Floor_Size, Furniture_Data}
    @returns {Base :Model}
]]

function Base.new(base_data)
	local self = setmetatable({}, Base)

	self._data = base_data -- raw data

	self._base = Instance.new("Model")
	self._base.Name = "Base"

	self._floor = Instance.new("Part")
	self._floor.Name = "Floor"
	self._floor.Size = Vector3.new(base_data.Floor_Size.X * 5, 10, base_data.Floor_Size.Y * 5)
	self._floor.Anchored = true
	self._floor.Parent = self._base

	self._walls = {}

	for _, wall in pairs(self._walls) do
		wall.Parent = self._base
	end

	self._base.Parent = workspace

	return self
end

return Base
