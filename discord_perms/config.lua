Config = {
	DiscordToken = "Bot Discord Token Here",
	GuildId = "Guild ID Here",

	-- Format: ["Role Nickname"] = { id = "Role ID", group = "Principal Group" } You can get role id by doing \@RoleName
	Roles = {
		['TestRole'] = { id = '1234567890', group = 'group.Test' },-- This could be checked by doing exports.discord_perms:IsRolePresent(user, "TestRole")
		['TestRole2'] = { id = '0987654321', group = 'group.Test2' }, -- Users with this role will also be added to the specified group automatically
	},
}
