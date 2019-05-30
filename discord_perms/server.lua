local FormattedToken = "Bot "..Config.DiscordToken

function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
		data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = FormattedToken})

    while data == nil do
        Citizen.Wait(0)
    end
	
    return data
end

function GetRoles(user)
	local discordId = nil
	for _, id in ipairs(GetPlayerIdentifiers(user)) do
		if string.match(id, "discord:") then
			discordId = string.gsub(id, "discord:", "")
			print("Found discord id: "..discordId)
			break
		end
	end

	if discordId then
		local endpoint = ("guilds/%s/members/%s"):format(Config.GuildId, discordId)
		local member = DiscordRequest("GET", endpoint, {})
		if member.code == 200 then
			local data = json.decode(member.data)
			local roles = data.roles
			local found = true
			return roles
		else
			print("An error occured, maybe they arent in the discord? Error: "..member.data)
			return false
		end
	else
		print("missing identifier")
		return false
	end
end

function IsRolePresent(user, role)
	local discordId = nil
	for _, id in ipairs(GetPlayerIdentifiers(user)) do
		if string.match(id, "discord:") then
			discordId = string.gsub(id, "discord:", "")
			print("Found discord id: "..discordId)
			break
		end
	end

	local theRole = nil
	if type(role) == "number" then
		theRole = tostring(role)
	else
		theRole = Config.Roles[role].id
	end

	if discordId then
		local endpoint = ("guilds/%s/members/%s"):format(Config.GuildId, discordId)
		local member = DiscordRequest("GET", endpoint, {})
		if member.code == 200 then
			local data = json.decode(member.data)
			local roles = data.roles
			local found = true
			for i=1, #roles do
				if roles[i] == theRole then
					print("Found role")
					return true
				end
			end
			print("Not found!")
			return false
		else
			print("An error occured, maybe they arent in the discord? Error: "..member.data)
			return false
		end
	else
		print("missing identifier")
		return false
	end
end

RegisterNetEvent('discord_perms:FetchRoles')
AddEventHandler('discord_perms:FetchRoles', function()
	local target = source
	local license = GetIdentifier(target, 'license')
	for k, v in pairs(Config.Roles) do
		RoleToPrincipal(target, k, license)
	end
end)

function RoleToPrincipal(user, role, license)
	if IsRolePresent(user, role) then
		local group = Config.Roles[role].group
		ExecuteCommand('remove_principal identifier.' .. license .. " group." .. group ) --removing principal prevents any possible duplicates
		ExecuteCommand('add_principal identifier.' .. license .. " group." .. group )
		print('Added principal to ' .. group)
    end
end

function GetIdentifier(serverId, search)
	for i,identifier in ipairs(GetPlayerIdentifiers(serverId)) do
		if string.find(identifier, search) then
			return identifier
		end
	end
end

Citizen.CreateThread(function()
	local guild = DiscordRequest("GET", "guilds/"..Config.GuildId, {})
	if guild.code == 200 then
		local data = json.decode(guild.data)
		print("Permission system guild set to: "..data.name.." ("..data.id..")")
	else
		print("An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code)) 
	end
end)
