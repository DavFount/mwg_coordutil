local VORPcore = {}

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

local GatheredCoords = {
    ambarino = {},
    upper_west_elizabeth = {},
    west_elizabeth = {},
    lower_west_elizabeth = {},
    new_hanover = {},
    lemoyne = {},
    new_austin = {},
    nuevo_paraiso = {},
    guarma = {}
}

local Key = Config.Key
local isCoordsGathered = false
local totalCount = 0

Citizen.CreateThread(function()
    while true do
        if IsControlJustPressed(0, Key) then
            print('Key detected')
            GetCoord()
        end
        Citizen.Wait(10)
    end
end)

function GetCoord()
    local player = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(player))

    local town_hash = Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, 1)
    local district_hash = Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, 10)
    local state_hash = Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, 0)
    local print_hash = Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, 12)
    local written_hash = Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, 13)

    local state_name = ""
    local value = ""

    if state_hash then
        state_name = Config.ZoneData.states[state_hash].state
        value = 'State'
    elseif district_hash then
        state_name = Config.ZoneData.districts[district_hash].state
        value = 'Distrcit'
    elseif town_hash then
        state_name = Config.ZoneData.towns[town_hash].state
        value = 'Town'
    else
        state_name = "Unable to find state by district or town."
        print(string.format("Town: %s"), town_hash)
        print(string.format("District: %s"), district_hash)
        print(string.format("State: %s"), state_hash)
        print(string.format("Print: %s"), print_hash)
        print(string.format("Written: %s"), written_hash)
        return
    end

    local coords = {
        x = x,
        y = y,
        z = z
    }

    table.insert(GatheredCoords[state_name], coords)
    local msg = string.format("Coord Saved for region %s.", state_name)
    VORPcore.NotifyRightTip(msg, 4000)

    totalCount = totalCount + 1
    isCoordsGathered = true
end

RegisterCommand("export_coords", function(source, args, rawCommand)
    if isCoordsGathered then
        TriggerServerEvent("mwg_coordutil:export", GatheredCoords)
    end
end)
