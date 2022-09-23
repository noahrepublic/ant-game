--@https://github.com/noahrepublic/EngineFramework/blob/main/src/Replicated/Utilities/Soap.lua

-- @noahrepublic
-- @version 1.0
-- @date 2022-06-21

--[[
    TODO: 
    - Add support to link to objects
]]

local Soap = {}
Soap.__index = Soap

-- Functions --

function Soap.new() -- init
	return setmetatable({
		_Tasks = {
			_High = {},
			_Default = {}
		}
	}, Soap)
end

function Soap:Add(job, priority)
	local tasks = self._Tasks
	if priority == "High" then 
        priority = tasks._High else 
        priority = tasks._Default 
    end
	table.insert(priority, job)
	return job
end

function Soap:Scrub(r)
	local tasks = self._Tasks._Default
	if r then
		tasks = self._Tasks._High
	end

	for index, step in pairs(tasks) do
		if typeof(step) == "RBXScriptConnection" then
			step:Disconnect()
		elseif typeof(step) == "Tween" then
			step:Stop()
		elseif type(step) == "function" then
			step()
		elseif type(step) == "thread" then
			task.cancel(step)
		elseif step.Destroy then
			step:Destroy() -- custom modules can be used
		elseif type(step) == "table" then
			for i, _ in pairs(step) do
				step[i] = nil
			end
		end
		tasks[index] = nil
	end
end

return Soap