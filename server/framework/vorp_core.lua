local Core = exports.vorp_core:GetCore()

function GetPlayer(playerId)
    local user = Core.getUser(playerId)
    return user.getUsedCharacter
end

function GetCharacterId(player)
	return player.charIdentifier
end

function IsPlayerInGroup(player, filter)
    local type = type(filter)

    if type == 'string' then
        if player.job == filter then
            return player.job, player.jobGrade
        end
    else
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            local grade = filter[data.name]
            if grade and grade <= player.jobGrade then
                return player.job, player.jobGrade
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                local group = filter[i]

                if player.job == group then
                    return player.job, player.jobGrade
                end
            end
        end
    end
end
