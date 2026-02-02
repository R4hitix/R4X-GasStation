--[[
    R4x Gas Station - Client Script
    Modern fuel system for FiveM with ESX
    
    Features:
    - Gasoline, Diesel, Electric vehicle support
    - Jerry can refueling
    - Modern NUI interface
    - ox_lib integration for progress bars
]]

-- ============================================================
-- DEPENDENCIES CHECK
-- ============================================================
if not lib.checkDependency('ox_lib', '3.0.0', true) then return end

lib.locale()

-- ============================================================
-- LOCAL VARIABLES
-- ============================================================
local isFueling = false           -- Is player currently refueling
local isCharging = false          -- Is electric vehicle charging
local nearestGasStation = nil     -- Current nearby station data
local nearestDistance = 30        -- Detection radius for stations
local currentPercentage = 0       -- Current charging percentage
local lastVehicle = cache.vehicle or GetPlayersLastVehicle()
local playerLoaded = false

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

--- Get fuel type from vehicle (checks state bag first, then config)
---@param vehicle number Vehicle entity
---@return string Fuel type ("Petrol", "Diesel", or "Electro")
local function getVehicleFuelType(vehicle)
    if not DoesEntityExist(vehicle) then return "Petrol" end
    
    -- Check state bag first
    local state = Entity(vehicle).state
    if state and state.fuelType then
        return state.fuelType
    end
    
    -- Fallback: check config for model
    local vehicleModel = GetEntityModel(vehicle)
    for category, models in pairs(Vehicles) do
        for _, model in pairs(models) do
            if vehicleModel == GetHashKey(model) then
                return category
            end
        end
    end
    
    return "Petrol"
end

--- Round number to nearest integer
---@param number number Number to round
---@return number Rounded integer
local function round(number)
    local fractionalPart = number - math.floor(number)
    if fractionalPart < 0.5 then
        return math.floor(number)
    else
        return math.ceil(number)
    end
end

--- Set fuel level for vehicle
---@param state table Entity state bag
---@param vehicle number Vehicle entity
---@param fuel number Fuel amount (0-100)
local function setFuel(state, vehicle, fuel)
    if DoesEntityExist(vehicle) then
        if fuel < 0 then fuel = 0 end
        SetVehicleFuelLevel(vehicle, fuel)
        if state.fuel then state:set('fuel', fuel) end
    end
end

-- ============================================================
-- BLIP CREATION
-- ============================================================

--- Create map blip for gas station
---@param loc vector3 Station coordinates
---@param isGas boolean True for gas, false for electric
---@return number Blip handle
local function createBlip(loc, isGas)
    local blip = AddBlipForCoord(loc)
    SetBlipSprite(blip, 361)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.6)
    SetBlipColour(blip, isGas and 6 or 3) -- Yellow for gas, Blue for electric
    SetBlipAsShortRange(blip, true)
    
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(locale(isGas and 'fuel_station_blip' or 'electro_station_blip'))
    EndTextCommandSetBlipName(blip)
    
    return blip
end

-- Create blips on resource start
if Config.ShowBlips then
    for coords, data in pairs(GasStations) do
        createBlip(coords, data.fType == 'gas')
    end
end

-- ============================================================
-- TEXT DRAWING FUNCTIONS
-- ============================================================

--- Draw 3D text at world position
---@param coords vector3 World coordinates
---@param text string Text to display
---@param size number Optional text size (default 1)
---@param font number Optional font ID (default 0)
local function Text3D(coords, text, size, font)
    local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
    local camCoords = GetFinalRenderedCamCoord()
    local distance = #(vector - camCoords)

    size = size or 1
    font = font or 0

    local scale = (size / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(0.0, 0.55 * scale)
    SetTextFont(font)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(vector.xyz, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

--- Draw text on screen (HUD style)
---@param text string Text to display
---@param scale number Text scale
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@param a number Alpha (0-255)
function DrawTextOnScreen(text, scale, r, g, b, a)
    SetTextFont(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.45, 0.85)
end

-- ============================================================
-- FUEL CONSUMPTION MANAGEMENT
-- ============================================================

--- Handle fuel consumption based on RPM
---@param state table Vehicle state bag
---@param veh number Vehicle entity
local function manageFuel(state, veh)
    local fuel = state.fuel
    local fuelType = state.fuelType
    
    if GetIsVehicleEngineRunning(veh) then
        local currentRpm = GetVehicleCurrentRpm(veh)
        local roundedRpm = math.floor(currentRpm * 10) / 10
        local consumption = Fuel_Consumption[fuelType][roundedRpm] or 0.1
        local newFuel = fuel - consumption * 1.0
        setFuel(state, veh, newFuel)
    end
end

-- ============================================================
-- FUELING PROCESS
-- ============================================================

--- Start fueling process with progress bar
---@param liters number Amount of fuel to add
local function fuelingProcess(liters)
    isFueling = true
    TaskTurnPedToFaceEntity(cache.ped, lastVehicle, 500)
    Wait(500)
    
    CreateThread(function()
        lib.progressCircle({
            duration = liters * 100,
            label = locale('fueling'),
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
                combat = true,
            },
            anim = {
                dict = 'timetable@gardener@filling_can',
                clip = 'gar_ig_5_filling_can',
            },
        })

        isFueling = false
        local vehicle = cache.vehicle or GetPlayersLastVehicle()
        local fuel = Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle)
        TriggerServerEvent('r4x_gas.fuelingDone', fuel, liters, NetworkGetNetworkIdFromEntity(vehicle))
    end)
end

-- ============================================================
-- ELECTRIC CHARGING
-- ============================================================

--- Start charging process for electric vehicle
---@param kWh number Current battery percentage
local function ChargeVehicle(kWh)
    lib.notify({
        type = 'success',
        label = locale('fuel_station_notify_label'),
        description = locale('veh_charge_start')
    })
    
    isCharging = true
    FreezeEntityPosition(lastVehicle, true)
    currentPercentage = round(kWh)
    local chargeAmount = 100 - currentPercentage

    -- Progress circle with charging animation
    if lib.progressCircle({
        duration = chargeAmount * 1000,
        label = '⚡ Charging... ' .. currentPercentage .. '% → 100%',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = true,
            combat = true,
        },
    }) then
        -- Completed successfully
        currentPercentage = 100
        lib.notify({
            type = 'success',
            label = locale('fuel_station_notify_label'),
            description = locale('veh_charge_done')
        })
        local vehicle = cache.vehicle or GetPlayersLastVehicle()
        TriggerServerEvent("r4x_gas.vehicleCharged", NetworkGetNetworkIdFromEntity(vehicle))
    else
        -- Cancelled by player
        lib.notify({
            type = 'error',
            label = locale('fuel_station_notify_label'),
            description = 'Ricarica annullata'
        })
    end
    
    isCharging = false
    FreezeEntityPosition(lastVehicle, false)
end

-- ============================================================
-- NUI INITIALIZATION
-- ============================================================

CreateThread(function()
    while not playerLoaded do
        Wait(500)
        SendNUIMessage({
            action = 'init',
            data = {
                petrolPrice = Config.PetrolPrice,
                dieselPrice = Config.DieselPrice,
                petrolCanPrice = Config.PetrolCanPrice,
                dieselCanPrice = Config.DieselCanPrice
            }
        })
        playerLoaded = true
    end
end)

-- ============================================================
-- NUI CALLBACKS
-- ============================================================

--- Handle fuel payment from NUI
RegisterNUICallback('payment', function(data, cb)
    local paymentMethod = data._paymentType
    local tankValue = tonumber(data._tankValue)
    local fuelType = data._fuelType
    
    -- Check if fuel type matches vehicle
    if fuelType == Entity(lastVehicle).state.fuelType then
        lib.callback('r4x_gas.checkMoney', false, function(done)
            hideNui()
            if done then
                fuelingProcess(tankValue)
            end
        end, paymentMethod, tankValue, fuelType)
    else
        hideNui()
        lib.notify({
            type = 'error',
            label = locale('fuel_station_notify_label'),
            description = locale('not_same_fuel_type', Entity(lastVehicle).state.fuelType)
        })
    end
    cb({})
end)

--- Handle electric payment from NUI
RegisterNUICallback('epayment', function(data, cb)
    local paymentMethod = data.paymentMethod
    local tankValue = round(100 - data._tankValue)

    if tankValue == 0 then 
        hideNui() 
        lib.notify({
            type = 'error',
            label = locale('fuel_station_notify_label'),
            description = locale('veh_100%')
        })
        return
    end

    lib.callback('r4x_gas.canCharge', false, function(done)
        hideNui()
        if done then
            ChargeVehicle(tankValue)
        end
    end, paymentMethod, tankValue)
    
    cb({})
end)

--- Handle jerry can purchase from NUI
RegisterNUICallback('jerrycan', function(data, cb)
    local jerryCanType = data
    lib.callback('r4x_gas.buyJerryCan', false, function(success)
        hideNui()
    end, jerryCanType)
    cb({})
end)

-- ============================================================
-- VEHICLE TRACKING
-- ============================================================

-- Track last vehicle when player changes seat
lib.onCache('seat', function(seat)
    if cache.vehicle then
        lastVehicle = cache.vehicle
    end
end)

-- ============================================================
-- STATION DETECTION LOOPS
-- ============================================================

--- Find nearest gas station every 2 seconds
CreateThread(function()
    while true do
        Wait(2000)
        local pCoords = GetEntityCoords(cache.ped)
        
        for coords, gasStationData in pairs(GasStations) do
            local distance = #(pCoords - coords)
            if distance < nearestDistance then
                nearestGasStation = gasStationData
                break
            else
                nearestGasStation = nil
            end
        end
    end
end)

--- Handle pump interaction when near station
CreateThread(function()
    while true do
        if nearestGasStation then
            local pumpCoords = nearestGasStation.PumpObjectsCoords
            local pumpType = nearestGasStation.fType
            local pCoords = GetEntityCoords(cache.ped)
            local closestPumpDist = math.huge
            local closestPumpCoords = nil
            
            -- Find closest pump
            for _, coords in pairs(pumpCoords) do
                local distance = #(pCoords - coords)
                if distance < closestPumpDist then
                    closestPumpDist = distance
                    closestPumpCoords = coords
                end
            end
            
            -- Process if close to pump
            if closestPumpDist < 10 and closestPumpCoords then
                local vehicleInRange = lastVehicle 
                    and DoesEntityExist(lastVehicle) 
                    and #(GetEntityCoords(lastVehicle) - closestPumpCoords) <= 3
                
                if vehicleInRange then
                    local vehicleFuelType = getVehicleFuelType(lastVehicle)
                    local isElectric = vehicleFuelType == 'Electro'
                    local inVehicle = IsPedInAnyVehicle(cache.ped, false)
                    
                    -- Gas station interaction
                    if not isElectric and pumpType == 'gas' then
                        if inVehicle then
                            Text3D(closestPumpCoords, locale('player_in_car'), 0.5)
                        elseif closestPumpDist < 2 then
                            Text3D(closestPumpCoords, locale('player_interaction'), 0.5)
                            if IsControlJustReleased(0, 38) and not isFueling then
                                openGasStation(
                                    nearestGasStation.GasStation_Name, 
                                    nearestGasStation.Zone_Street_Name, 
                                    Entity(lastVehicle).state.fuel
                                )
                            end
                        end
                    -- Electric station interaction
                    elseif isElectric and pumpType == 'electric' then
                        if inVehicle then
                            Text3D(closestPumpCoords, locale('player_in_car_electro'), 0.5)
                        elseif closestPumpDist < 2 then
                            Text3D(closestPumpCoords, locale('player_interaction_electro'), 0.5)
                            if IsControlJustReleased(0, 38) and not isCharging then
                                openElectricStation(
                                    nearestGasStation.GasStation_Name, 
                                    nearestGasStation.Zone_Street_Name, 
                                    round(Entity(lastVehicle).state.fuel), 
                                    isCharging
                                )
                            end
                        end
                    end
                end
                Wait(0) -- Frame-perfect for input detection
            else
                Wait(500) -- Slower when not near pump
            end
        else
            Wait(1000) -- Slowest when no station nearby
        end
    end
end)

-- ============================================================
-- FUEL MANAGEMENT LOOP
-- ============================================================

--- Consume fuel while driving
CreateThread(function()
    if not Config.ManageFuel then return end
    
    while true do
        Wait(2000)
        local ped = cache.ped
        local vehicle = cache.vehicle
        
        if IsPedInAnyVehicle(ped) and GetPedInVehicleSeat(vehicle, -1) == ped then
            -- Skip bicycles
            if GetVehicleClass(vehicle) == 13 then return end
            
            local state = Entity(vehicle).state
            
            -- Initialize state bag if needed
            if not state.fuel then
                local vehicleModel = GetEntityModel(vehicle)
                local fuelCategory = "Petrol"
                
                for k, v in pairs(Vehicles) do
                    for _, model in pairs(v) do
                        if vehicleModel == GetHashKey(model) then
                            fuelCategory = k
                            break
                        end
                    end
                end
                
                TriggerServerEvent(
                    'r4x_gas.CreateStateBag', 
                    NetworkGetNetworkIdFromEntity(vehicle), 
                    GetVehicleFuelLevel(vehicle), 
                    fuelCategory
                )
                
                while not state.fuel and not state.fuelType do Wait(0) end
            end
            
            manageFuel(state, vehicle)
        end
    end
end)

-- ============================================================
-- JERRY CAN FUNCTIONS
-- ============================================================

--- Fuel cap bone names to check
local FUEL_CAP_BONES = {
    'petrolcap',
    'petroltank',
    'petroltank_l'
}

--- Get vehicle in front of player using raycast
---@return number|nil Vehicle entity or nil
local function getVehicleInFront()
    local player = PlayerPedId()
    local playerPos = GetEntityCoords(player, false)
    local playerForwardVector = GetEntityForwardVector(player)
    local playerFrontPos = playerPos + playerForwardVector * 3.0

    local rayHandle = StartShapeTestRay(playerPos, playerFrontPos, 10, player, 0)
    local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)

    if IsEntityAVehicle(vehicle) then
        return vehicle
    end
    return nil
end

--- Find fuel cap bone on vehicle
---@param vehicle number Vehicle entity
---@return number Bone index or nil
local function getCapBoneIndex(vehicle)
    for i = 1, #FUEL_CAP_BONES do
        local boneIndex = GetEntityBoneIndexByName(vehicle, FUEL_CAP_BONES[i])
        if boneIndex ~= -1 then
            return boneIndex
        end
    end
end

--- Common jerry can usage logic
---@param expectedFuelType string "Petrol" or "Diesel"
---@param wrongFuelType string The opposite fuel type
local function useJerryCan(expectedFuelType, wrongFuelType)
    local vehicle = getVehicleInFront()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    if not vehicle then 
        lib.notify({
            type = 'error',
            label = locale('fuel_station_notify_label'),
            description = locale('far_away_jerry')
        })
        return
    end
    
    local vehicleFuel = Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle)
    local vehicleFuelType = Entity(vehicle).state.fuelType
    local state = Entity(vehicle).state

    -- Check fuel type compatibility
    if vehicleFuelType == wrongFuelType then
        lib.notify({
            type = 'error',
            label = locale('fuel_station_notify_label'),
            description = locale('jerry_can_wrong_fuel', vehicleFuelType)
        })
        return
    end

    -- Check if tank is too full
    if vehicleFuel > 75 then
        lib.notify({
            type = 'error',
            label = locale('fuel_station_notify_label'),
            description = locale('jerry_can_veh_75%')
        })
        return
    end
    
    -- Check distance to fuel cap
    local bone = getCapBoneIndex(vehicle)
    local fuelcapPosition = GetWorldPositionOfEntityBone(vehicle, bone)
    local duration = Config.JerryCanFuelingTime * 1000

    if not fuelcapPosition or #(playerCoords - fuelcapPosition) >= 1.8 then
        lib.notify({
            type = 'error',
            label = locale('fuel_station_notify_label'),
            description = locale('far_away_cap')
        })
        return
    end
    
    -- Start fueling animation
    TaskTurnPedToFaceEntity(cache.ped, vehicle, duration)
    Wait(500)
    
    CreateThread(function()
        lib.progressCircle({
            duration = duration,
            useWhileDead = false,
            canCancel = false,
            disable = {
                move = true,
                car = true,
                combat = true,
            },
            anim = {
                dict = 'weapon@w_sp_jerrycan',
                clip = 'fire',
            },
            prop = {
                model = `w_am_jerrycan`,
                pos = vec3(0.03, 0.03, -0.22),
                rot = vec3(0.0, 120.0, -22.5),
                bone = 57005,
            }
        })
    end)

    setFuel(state, vehicle, vehicleFuel + 25)
end

-- ============================================================
-- JERRY CAN EXPORTS
-- ============================================================

--- Use petrol jerry can (called by ox_inventory)
exports('jerrycan_petrol', function(data, slot)
    useJerryCan("Petrol", "Diesel")
end)

--- Use diesel jerry can (called by ox_inventory)
exports('jerrycan_diesel', function(data, slot)
    useJerryCan("Diesel", "Petrol")
end)