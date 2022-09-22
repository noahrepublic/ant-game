for _, module in ipairs(script.OnStart:GetChildren()) do
	require(module)
end
