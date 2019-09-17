local ActiveUsers = {}
local FormattedToken = "Bot "..Config.DiscordToken

local function DiscordRequest(method, endpoint, jsondata)
	local data = nil
	PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
		data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = FormattedToken})

    while data == nil do
        Citizen.Wait(0)
	end
	
    return data
end

local function GetUserRoles(user)
    local DiscordId = nil
    for _, id in ipairs(GetPlayerIdentifiers(user)) do
        if string.match(id, "discord:") then
            DiscordId = string.gsub(id, "discord:", "")
            break
        end
    end
    if not DiscordId then print("No discord id found") return false end
    local MemberInfo = DiscordRequest("GET", "guilds/"..Config.GuildId.."/members/"..DiscordId, {})
    if MemberInfo.code == 200 then
        local UserRoles = json.decode(MemberInfo.data).roles
        return UserRoles
    else
        return false
    end
end

local function RemoveUserPermissions(user)
    if ActiveUsers[user] then
        local UserRoles = ActiveUsers[user]
        for i=1, #UserRoles do
            local role = UserRoles[i]
            if Config.Roles[role] then
                ExecuteCommand("remove_principal identifier."..GetPlayerIdentifier(user, 0).." group."..Config.Roles[role])
                TriggerClientEvent("DiscordPerms:RemoveRole", user, Config.Roles[role])
            end
        end
    end
end

local function UpdateUserPermissions(user)
    if ActiveUsers[user] then
        RemoveUserPermissions(user)
        local UserRoles = GetUserRoles(user)
        ActiveUsers[user] = UserRoles
        for i=1, #UserRoles do
            local role = UserRoles[i]
            if Config.Roles[role] then
                ExecuteCommand("add_principal identifier."..GetPlayerIdentifier(user, 0).." group."..Config.Roles[role])
                TriggerClientEvent("DiscordPerms:LoadRole", user, Config.Roles[role])
            end
        end
    end
end

local function UpdateAllPerms()
    for user, roles in ipairs(ActiveUsers) do
        UpdateUserPermissions(user)
    end
    if Config.Loop then
        SetTimeout(Config.LoopDelay, UpdateAllPerms)
    end
end

SetTimeout(1000, UpdateAllPerms)

RegisterNetEvent("DiscordPerms:RegisterMe")
AddEventHandler("DiscordPerms:RegisterMe", function()
    local s = source
    if not ActiveUsers[s] then
        ActiveUsers[s] = {}
        UpdateUserPermissions(s)
    end
end)

--[[RegisterNetEvent("DiscordPerms:CheckRole")
AddEventHandler("DiscordPerms:CheckRole", function(role)
    if ExecuteCommand(IsPlayerAceAllowed(source, 'discord.' .. role)) then
        --return true
    else
        --return false
    end
end)]]

AddEventHandler("playerDropped", function(player, disconnectReason)
    if ActiveUsers[player] then
        RemoveUserPermissions(player)
        ActiveUsers[player] = nil
    end
end)

Citizen.CreateThread(function()
	local guild = DiscordRequest("GET", "guilds/"..Config.GuildId, {})
	if guild.code == 200 then
		local data = json.decode(guild.data)
		print("Permission system guild set to: "..data.name.." ("..data.id..")")
	else
		print("An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code))
	end
end)