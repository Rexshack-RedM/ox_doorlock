local RedEM = exports["redem_roleplay"]:RedEM()

function GetPlayer(playerId)
    local Player = RedEM.GetPlayer(playerId)
    return Player
end

function GetCharacterId(player)
	return player.citizenid
end

function IsPlayerInGroup(player, filter)
	local type = type(filter)

    if type == 'string' then
        if player.job == filter then
            return player.job, player.jobgrade
        end
        if player.gang == filter then
            return player.gang, player.ganggrade
        end
    else
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            local grade = filter[data.name]
            if grade and grade <= player.jobgrade then
                return player.job, player.jobgrade
            end
            if grade and grade <= player.ganggrade then
                return player.gang, player.ganggrade
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                local group = filter[i]

                if player.job == group then
                    return player.job, player.jobgrade
                end
                if player.gang == group then
                    return player.gang, player.ganggrade
                end
            end
        end
    end
end
