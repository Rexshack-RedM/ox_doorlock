local Core = exports.vorp_core:GetCore()

function GetPlayer(playerId)
    local user = Core.getUser(playerId)
    return user.getUsedCharacter
end

function GetCharacterId(player)
	return player.charIdentifier
end

function IsPlayerInGroup(player, filter)
    return player.job
end
