--[[MetronomeService]
	This module is largely inspired by @Dynamese (Enduo) and the Overwatch developers. In an effort
	to give priority to some actions (or to set callbacks to only occurs a specific amount of
	times per frame).
--]]

local SETTINGS = {
	AutoStart = true,
}

-- Module table:
local MetronomeService = {}

----- Loaded Services -----
local HTTPService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

----- Private variables -----

-- frequency: [1, inf), 1 runs something once a second. inf runs every frame
local Frequencies = {
	--[[
	[frequency: number] = {
		LastTick = 0, -- default = 0
		NumTasks = 1,
		Tasks = {
			[callback: function],
			...
		}
	},
	...
	--]]
}

local Tasks = {
	--[[
	[id: number] = {
		Frequency = number,
		Callback = callback,
		Working = false
	}
	--]]
}

local Heartbeats = {
	--[[
	[id: number] = RunService.Heartbeat:Connect(callback),
	...
	--]]
}

------ Private functions -----
local function process(_, dt)
	for frequency, info in pairs(Frequencies) do
		--frequency = 1/frequency -- how frequently something should occur
		info.LastTick += dt

		if info.LastTick < frequency then
			continue
		end -- haven't reached freq. threshold yet
		local t = info.LastTick
		info.LastTick = 0

		for id, callback in pairs(info.Tasks) do
			if Tasks[id] == nil or Tasks[id].Working == true then
				continue
			end

			task.spawn(function()
				Tasks[id].Working = true
				callback(t)
				if Tasks[id] ~= nil then -- allows for for disconnecting during callback
					Tasks[id].Working = false
				end
			end)
		end
	end
end

----- Global methods -----
function MetronomeService.Start()
	if MetronomeService.Started == true then
		return
	end
	MetronomeService.Started = true

	RunService.Stepped:Connect(process)
end

function MetronomeService.CreateTask(frequency, callback)
	frequency = math.floor(frequency)

	local frequencyTasks = Frequencies[frequency]
	local id = HTTPService:GenerateGUID()

	if frequencyTasks == nil then
		frequencyTasks = { LastTick = 0, NumTasks = 1, Tasks = { [id] = callback } }
		Frequencies[frequency] = frequencyTasks
	else
		frequencyTasks.Tasks[id] = callback
		frequencyTasks.NumTasks += 1
	end

	Tasks[id] = {
		Frequency = frequency,
		Callback = callback,
		Working = false,
	}

	return id
end

function MetronomeService.RemoveTask(id)
	local task = Tasks[id]
	assert(task ~= nil, ("[MetronomeService] Cannot remove an id that does not exist: %s"):format(id))

	local frequency = task.Frequency

	Tasks[id] = nil

	Frequencies[frequency].Tasks[id] = nil
	Frequencies[frequency].NumTasks -= 1

	if Frequencies[frequency].NumTasks <= 0 then
		Frequencies[frequency] = nil
	end
end

function MetronomeService.BindToHeartbeat(callback)
	local id = HTTPService:GenerateGUID()
	Heartbeats[id] = RunService.Heartbeat:Connect(callback)
	return id
end

function MetronomeService.UnbindFromHeartbeat(id)
	local task = Heartbeats[id]
	assert(task ~= nil, ("[MetronomeService] Cannot remove an id that does not exist: %s"):format(id))

	Heartbeats[id] = nil
	task:Disconnect()
end

-- Initialize:
if SETTINGS.AutoStart == true then
	MetronomeService.Start()
end

return MetronomeService
