# discord_perms
<<<<<<< HEAD
Link discord roles to in game permission thingies. Now with ace permission support!
=======
Link discord roles to in game permission thingies


# IMPORTANT!

Ensure you add
```cfg
add_ace resource.discord_perms command.add_principal allow
add_ace resource.discord_perms command.remove_principal allow
```
To your .cfg file, else this system will not work

If you want to use these ace groups (E.G `IsPlayerAceAllowed(player, "fren.kick")`) make sure that you set this in your config too:
```
add_ace group.fren fren allow
```
along with the other permissions for the other roles.
>>>>>>> a7bf1be5c4c032c720923c238af9c0101798c334
