local FirstTime = true
AddEventHandler("playerSpawned", function()
    if FirstTime then FirstTime = false TriggerServerEvent("DiscordPerms:RegisterMe") end
end)

local myRoles = {}

RegisterNetEvent("DiscordPerms:LoadRole")
AddEventHandler("DiscordPerms:LoadRole", function(role)
    table.insert(myRoles, role)
end)

RegisterNetEvent("DiscordPerms:RemoveRole")
AddEventHandler("DiscordPerms:RemoveRole", function(role)
    for k, v in ipairs (myRoles) do 
        if (v == role) then
          myRoles[k] = nil
        end
    end
end)

local blacklistedVehicles = {
    { group = 'nitro', vehicles = {
        --'Police',
        --'Police2',
    } },

    { group = 'pvip6', vehicles = {
        --'Police3',
        --'Police4',
    } },
    
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(400)

        local ped = PlayerPedId()
        local veh = nil
        if IsPedInAnyVehicle(ped, false) then
            veh = GetVehiclePedIsUsing(ped)
        else
            veh = GetVehiclePedIsTryingToEnter(ped)
        end
            
        if veh and DoesEntityExist(veh) then
            local model = GetEntityModel(veh)
            if GetPedInVehicleSeat(veh, -1) == ped then
                for k, role in ipairs(blacklistedVehicles) do
                    for i, name in ipairs(role.vehicles) do
                        if model == GetHashKey(name) then --vehicle is blacklisted
                            --do you have this role?
                            local hasRole = false
                            for index, value in ipairs(myRoles) do
                                if value == role.group then hasRole = true end
                            end
                            if not hasRole then--if perms fail
                                ShowNotification("~r~You are not allowed to drive this vehicle.")
                                DeleteEntity(veh)
                                ClearPedTasksImmediately(ped)
                            end
                        end
                    end
                end
            end
        end
        
    end
end)


function ShowNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentSubstringPlayerName(text)
	DrawNotification(false, false)
end