for _, module in ipairs(script.OnStart:GetChildren()) do
	local succ, err = pcall(function()
		require(module)
	end)
	if not succ then
		warn("Error loading module: " .. module.Name .. "Error: " .. err)
	end
end
