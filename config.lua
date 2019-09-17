Config = {
	DiscordToken = "Token",
	GuildId = "354062777737936896",
	Loop = true, -- Should we automatically refresh perms incase someone loses a role?
	LoopDelay = 60000, -- How often to automatically refresh user permissions

	Roles = {
		["581644688138960897"] = "nitro" -- Will add user to "group.nitro"
		["615719228942712841"] = 'pvip6'
	}
}

--[[Citizen.CreateThread(function()
	for k, role in ipairs(Config.Roles) do
		ExecuteCommand('add_ace group.' .. role .. ' discord.' .. role .. ' allow')
	end
end)]]
