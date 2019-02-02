local FirstTime = true
AddEventHandler("playerSpawned", function()
    if FirstTime then FirstTime = false TriggerServerEvent("DiscordPerms:RegisterMe") end
end)