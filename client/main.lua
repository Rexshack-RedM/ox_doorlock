if not LoadResourceFile(cache.resource, 'web/build/index.html') then
    error('Unable to load UI. Build ox_doorlock or download the latest release.\n    ^3https://github.com/overextended/ox_doorlock/releases/latest/download/ox_doorlock.zip^0')
end

if not lib.checkDependency('ox_lib', '3.14.0', true) then return end

local ZoneList = {
    [2025841068] = 'Bayou Nwa',
    [822658194] = 'Big Valley',
    [1308232528] = 'Bluewater Marsh',
    [-108848014] = 'Cholla Springs',
    [1835499550] = 'Cumberland',
    [426773653] = 'DiezCoronas',
    [-2066240242] = 'Gaptooth Ridge',
    [476637847] = 'Great Plains',
    [-120156735] = 'Grizzlies East',
    [1645618177] = 'Grizzlies West',
    [-512529193] = 'Guarma',
    [131399519] = 'Heartlands',
    [892930832] = 'Hennigans Stead',
    [-1319956120] = 'Perdido',
    [1453836102] = 'Punta Orgullo',
    [-2145992129] = 'Rio Bravo',
    [178647645] = 'Roanoke',
    [-864275692] = 'Scarlett Meadows',
    [1684533001] = 'Tall Trees',
}

local function getEntityCenterCoords(entity)
    local min, max = GetModelDimensions(GetEntityModel(entity))
    local pad = 0.001

    local box = {
        GetOffsetFromEntityInWorldCoords(entity, min.x - pad, min.y - pad, min.z - pad),
        GetOffsetFromEntityInWorldCoords(entity, max.x + pad, min.y - pad, min.z - pad),
        GetOffsetFromEntityInWorldCoords(entity, max.x + pad, max.y + pad, min.z - pad),
        GetOffsetFromEntityInWorldCoords(entity, min.x - pad, max.y + pad, min.z - pad),
        GetOffsetFromEntityInWorldCoords(entity, min.x - pad, min.y - pad, max.z + pad),
        GetOffsetFromEntityInWorldCoords(entity, max.x + pad, min.y - pad, max.z + pad),
        GetOffsetFromEntityInWorldCoords(entity, max.x + pad, max.y + pad, max.z + pad),
        GetOffsetFromEntityInWorldCoords(entity, min.x - pad, max.y + pad, max.z + pad)
    }

    local sum = vec3(0, 0, 0)
    for i = 1, 8 do
        sum = sum + box[i]
    end
    return sum / 8
end

local function getDoorHandPoint(entity)
    local boneIndex = GetEntityBoneIndexByName(entity, 'door_hand_point')
    if boneIndex == -1 then
        boneIndex = GetEntityBoneIndexByName(entity, 'doorknob_bone')
    end
    boneIndex = boneIndex == -1 and 1 or boneIndex
    return GetWorldPositionOfEntityBone(entity, boneIndex)
end

local function createDoor(door)
    local double = door.doors
    door.zone = ZoneList[GetMapZoneAtCoords(door.coords.x, door.coords.y, door.coords.z, 10)]
    if double then
        for i = 1, 2 do
            -- AddDoorToSystem(double[i].hash, double[i].model, double[i].coords.x, double[i].coords.y, double[i].coords.z, false, false, false)
            AddDoorToSystemNew(double[i].hash, true, true, false, 0, 0, false)
            DoorSystemSetDoorState(double[i].hash, 4, false, false)
            DoorSystemSetDoorState(double[i].hash, door.state, false, false)

            if door.doorRate or not door.auto then
                DoorSystemSetAutomaticRate(double[i].hash, door.doorRate or 10.0, false, false)
            end
        end
    else
        -- AddDoorToSystem(door.hash, door.model, door.coords.x, door.coords.y, door.coords.z, false, false, false)
        AddDoorToSystemNew(door.hash, true, true, false, 0, 0, false)
        DoorSystemSetDoorState(door.hash, 4, false, false)
        DoorSystemSetDoorState(door.hash, door.state, false, false)

        if door.doorRate or not door.auto then
            DoorSystemSetAutomaticRate(door.hash, door.doorRate or 10.0, false, false)
        end
    end
end

local nearbyDoors = {}
-- Entity state doesn't work, it keeps throwing an error for some reason. 0x3BB78F05
-- local Entity = Entity
DoorEntity = {}

lib.callback('ox_doorlock:getDoors', false, function(data)
    doors = data

    for _, door in pairs(data) do
        createDoor(door)
    end

    while true do
        table.wipe(nearbyDoors)
        local coords = GetEntityCoords(cache.ped)

        for _, door in pairs(doors) do
            local double = door.doors
            door.distance = #(coords - door.coords)

            if double then
                if door.distance < 80 then
                    for i = 1, 2 do
                        if not double[i].entity and IsModelValid(double[i].model) then
                            -- local entity = GetClosestObjectOfType(double[i].coords.x, double[i].coords.y, double[i].coords.z, 1.0, double[i].model, false, false, false)
                            local entity = GetEntityByDoorhash(double[i].hash)
                            if entity ~= 0 then
                                double[i].entity = entity
                                -- Entity(entity).state.doorId = door.id
                                if not DoorEntity[entity] then
                                    DoorEntity[entity] = {}
                                end
                                DoorEntity[entity].doorId = door.id
                            end
                        end
                    end

                    if door.distance < 20 then
                        nearbyDoors[#nearbyDoors + 1] = door
                    end
                else
                    for i = 1, 2 do
                        double[i].entity = nil
                    end
                end
            elseif door.distance < 80 then
                if not door.entity and IsModelValid(door.model) then
                    -- local entity = GetClosestObjectOfType(door.coords.x, door.coords.y, door.coords.z, 1.0, door.model, false, false, false)
                    local entity = GetEntityByDoorhash(door.hash)

                    if entity ~= 0 then
                        door.coords = getEntityCenterCoords(entity)
                        door.entity = entity
                        -- Entity(entity).state.doorId = door.id
                        if not DoorEntity[entity] then
                            DoorEntity[entity] = {}
                        end
                        DoorEntity[entity].doorId = door.id
                    end
                end

                if door.distance < 20 then
                    nearbyDoors[#nearbyDoors + 1] = door
                end
            elseif door.entity then
                door.entity = nil
            end
        end

        Wait(500)
    end
end)

RegisterNetEvent('ox_doorlock:setState', function(id, state, source, data)
    if not doors then return end

    if data then
        doors[id] = data
        createDoor(data)

        if NuiHasLoaded then
            SendNuiMessage(json.encode({
                action = 'updateDoorData',
                data = data
            }))
        end
    end

    if Config.Notify and source == cache.serverId then
        if state == 0 then
            lib.notify({
                type = 'success',
                icon = 'unlock',
                description = locale('unlocked_door')
            })
        else
            lib.notify({
                type = 'success',
                icon = 'lock',
                description = locale('locked_door')
            })
        end
    end

    local door = data or doors[id]
    local double = door.doors
    door.state = state

    if double then
        DoorSystemSetDoorState(double[1].hash, door.state, false, false)
        DoorSystemSetDoorState(double[2].hash, door.state, false, false)

        if door.holdOpen then
            DoorSystemSetHoldOpen(double[1].hash, door.state == 0)
            DoorSystemSetHoldOpen(double[2].hash, door.state == 0)
        end

        while door.state == 1 and (not IsDoorClosed(double[1].hash) or not IsDoorClosed(double[2].hash)) do Wait(0) end
    else
        DoorSystemSetDoorState(door.hash, door.state, false, false)

        if door.holdOpen then DoorSystemSetHoldOpen(door.hash, door.state == 0) end
        while door.state == 1 and not IsDoorClosed(door.hash) do Wait(0) end
    end

    if door.state == state and door.distance and door.distance < 20 then
        if Config.NativeAudio then
            RequestScriptAudioBank('dlc_oxdoorlock/oxdoorlock', false)
            local sound = state == 0 and door.unlockSound or door.lockSound or 'door_bolt'
            local soundId = GetSoundId()

            PlaySoundFromCoord(soundId, sound, door.coords.x, door.coords.y, door.coords.z, 'DLC_OXDOORLOCK_SET', false, 0, false)
            ReleaseSoundId(soundId)
            ReleaseNamedScriptAudioBank('dlc_oxdoorlock/oxdoorlock')
        else
            -- local volume = (0.01 * GetProfileSetting(300)) / (door.distance / 2)
            local volume = 0.3 / (door.distance / 2)
            if volume > 1 then volume = 1 end
            local sound = state == 0 and door.unlockSound or door.lockSound or 'door-bolt-4'

            SendNUIMessage({
                action = 'playSound',
                data = {
                    sound = sound,
                    volume = volume
                }
            })
        end
    end
end)

RegisterNetEvent('ox_doorlock:editDoorlock', function(id, data)
    if source == '' then return end

    local door = doors[id]
    local double = door.doors
    local doorState = data and data.state or 0

    if data then
        data.zone = door.zone or ZoneList[GetMapZoneAtCoords(door.coords.x, door.coords.y, door.coords.z, 10)]
            
        if door.distance < 20 then door.distance = 80 end
    elseif ClosestDoor?.id == id then
        ClosestDoor = nil
    end

    if double then
        for i = 1, 2 do
            local doorHash = double[i].hash

            if data then
                if data.doorRate or door.doorRate or not data.auto then
                    DoorSystemSetAutomaticRate(doorHash, data.doorRate or door.doorRate and 0.0 or 10.0, false, false)
                end

                DoorSystemSetDoorState(doorHash, doorState, false, false)

                if data.holdOpen then DoorSystemSetHoldOpen(doorHash, doorState == 0) end
            else
                DoorSystemSetDoorState(doorHash, 4, false, false)
                DoorSystemSetDoorState(doorHash, 0, false, false)

                if double[i].entity then
                    -- Entity(double[i].entity).state.doorId = nil
                    DoorEntity[double[i].entity].doorId = nil
                end
            end
        end
    else
        if data then
            if data.doorRate or door.doorRate or not data.auto then
                DoorSystemSetAutomaticRate(door.hash, data.doorRate or door.doorRate and 0.0 or 10.0, false, false)
            end

            DoorSystemSetDoorState(door.hash, doorState, false, false)

            if data.holdOpen then DoorSystemSetHoldOpen(door.hash, doorState == 0) end
        else
            DoorSystemSetDoorState(door.hash, 4, false, false)
            DoorSystemSetDoorState(door.hash, 0, false, false)

            if door.entity then
                -- Entity(door.entity).state.doorId = nil
                DoorEntity[door.entity].doorId = nil
            end
        end
    end

    doors[id] = data

    if NuiHasLoaded then
        SendNuiMessage(json.encode({
            action = 'updateDoorData',
            data = data or id
        }))
    end
end)

ClosestDoor = nil

lib.callback.register('ox_doorlock:inputPassCode', function()
    return ClosestDoor?.passcode and lib.inputDialog(locale('door_lock'), {
        {
            type = 'input',
            label = locale('passcode'),
            password = true,
            icon = 'lock'
        },
    })?[1]
end)

local lastTriggered = 0

local function useClosestDoor()
    if not ClosestDoor then return false end

    local gameTimer = GetGameTimer()

    if gameTimer - lastTriggered > 500 then
        lastTriggered = gameTimer
        TriggerServerEvent('ox_doorlock:setState', ClosestDoor.id, ClosestDoor.state == 1 and 0 or 1)
    end
end

CreateThread(function()
    local lockDoor = locale('lock_door')
    local unlockDoor = locale('unlock_door')
    local showUI

    RequestStreamedTextureDict('generic_textures', false)
    RequestStreamedTextureDict('inventory_items', false)
    while not HasStreamedTextureDictLoaded('generic_textures') or not HasStreamedTextureDictLoaded('inventory_items') do
        Wait(0)
    end
    while true do
        Wait(0)
        ClosestDoor = nil
        local num = #nearbyDoors
        if num > 0 then
            for i = 1, num do
                local door = nearbyDoors[i]
                if door.distance < door.maxDistance then
                    if not ClosestDoor or door.distance < ClosestDoor.distance then
                        ClosestDoor = door
                    end
                end
            end
        end

        if ClosestDoor and ClosestDoor.distance < ClosestDoor.maxDistance then
            local onScreen, sx, sy = GetScreenCoordFromWorldCoord(ClosestDoor.coords.x,ClosestDoor.coords.y - 0.2,ClosestDoor.coords.z)
            if Config.DrawTextUI and not ClosestDoor.hideUi then
                if ClosestDoor.state ~= showUI then
                    lib.showTextUI(ClosestDoor.state == 0 and lockDoor or unlockDoor)
                    showUI = ClosestDoor.state
                end
            end

            if not Config.DrawTextUI and not ClosestDoor.hideUi and onScreen then
                if ClosestDoor.state == 1 then
                    DrawSprite("generic_textures", "lock", sx, sy + 0.0125, 0.02, 0.02, 0.1, 255, 0, 0, 255)
                else
                    DrawSprite("inventory_items", "consumable_lock_breaker", sx, sy + 0.0125, 0.02, 0.02, 0.1, 0, 255, 0, 255)
                end
            end
            if not PickingLock and IsDisabledControlJustReleased(0, `INPUT_LOOT`) then
                useClosestDoor()
            end
        else
            if showUI then
                lib.hideTextUI()
                showUI = nil
            end
        end
    end
end)

exports('useClosestDoor', useClosestDoor)
exports('getClosestDoor', function() return ClosestDoor end)
