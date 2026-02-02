--[[
    R4x Gas Station - Server Script
    Handles payments, inventory, and vehicle state management
    
    Callbacks:
    - r4x_gas.checkMoney: Process fuel payment
    - r4x_gas.buyJerryCan: Purchase jerry can
    - r4x_gas.canCharge: Process electric charging payment
    
    Events:
    - r4x_gas.CreateStateBag: Initialize vehicle fuel state
    - r4x_gas.fuelingDone: Update fuel after refueling
    - r4x_gas.vehicleCharged: Set fuel to 100% after charging
]]

lib.locale()

-- ============================================================
-- FUEL PAYMENT CALLBACK
-- ============================================================

--- Process payment for gasoline/diesel refueling
---@param source number Player server ID
---@param paymentMethod string "cash" or "card"
---@param tankValue number Liters of fuel
---@param fuelType string "Petrol" or "Diesel"
---@return boolean Success status
lib.callback.register('r4x_gas.checkMoney', function(source, paymentMethod, tankValue, fuelType)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    -- Calculate price
    local isPetrol = (fuelType == 'Petrol')
    local pricePerLiter = isPetrol and Config.PetrolPrice or Config.DieselPrice
    local totalCost = pricePerLiter * tankValue
    
    -- Determine payment account
    local isCash = (paymentMethod == 'cash')
    local targetAccount = isCash and 'money' or 'bank'
    local playerMoney = xPlayer.getAccount(targetAccount).money
    
    -- Check if player has enough money
    local hasEnoughMoney = playerMoney >= totalCost
    
    if hasEnoughMoney then
        xPlayer.removeAccountMoney(targetAccount, totalCost)
        
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'success',
            label = locale('fuel_station_notify_label'),
            description = locale('fuel_station_pay', totalCost, tankValue, fuelType)
        })
        return true
    else
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            label = locale('fuel_station_notify_label'),
            description = locale('fuel_station_no_money')
        })
        return false
    end
end)

-- ============================================================
-- JERRY CAN PURCHASE CALLBACK
-- ============================================================

--- Handle jerry can purchase
---@param source number Player server ID
---@param jerryType string "petrol" or "diesel"
---@return boolean Success status
lib.callback.register('r4x_gas.buyJerryCan', function(source, jerryType)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    -- Determine item and price
    local isPetrol = (jerryType == 'petrol')
    local totalCost = isPetrol and Config.PetrolCanPrice or Config.DieselCanPrice
    local itemToAdd = isPetrol and 'jerrycan_petrol' or 'jerrycan_diesel'
    
    -- Check cash (jerry cans are cash only)
    local playerMoney = xPlayer.getMoney()
    local hasEnoughMoney = playerMoney >= totalCost
    
    if hasEnoughMoney then
        xPlayer.removeMoney(totalCost)
        xPlayer.addInventoryItem(itemToAdd, 1)
        
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'success',
            label = locale('fuel_station_notify_label'),
            description = locale('fuel_station_jerrycan', jerryType, totalCost)
        })
        return true
    else
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            label = locale('fuel_station_notify_label'),
            description = locale('fuel_station_no_money_jerrycan')
        })
        return false
    end
end)

-- ============================================================
-- ELECTRIC CHARGING CALLBACK
-- ============================================================

--- Process payment for electric vehicle charging
---@param source number Player server ID
---@param paymentMethod string "cash" or "card"
---@param tankValue number kWh to charge (percentage points)
---@return boolean Success status
lib.callback.register('r4x_gas.canCharge', function(source, paymentMethod, tankValue)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    -- Calculate price
    local pricePerkWh = Config.ChargingPrice
    local totalCost = pricePerkWh * tankValue
    
    -- Determine payment account
    local isCash = (paymentMethod == 'cash')
    local targetAccount = isCash and 'money' or 'bank'
    local playerMoney = xPlayer.getAccount(targetAccount).money
    
    -- Check if player has enough money
    local hasEnoughMoney = playerMoney >= totalCost
    
    if hasEnoughMoney then
        xPlayer.removeAccountMoney(targetAccount, totalCost)
        
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'success',
            label = locale('fuel_station_notify_label'),
            description = locale('fuel_station_pay_charge', totalCost, tankValue)
        })
        return true
    else
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            label = locale('fuel_station_notify_label'),
            description = locale('fuel_station_no_money_chrage')
        })
        return false
    end
end)

-- ============================================================
-- STATE BAG EVENTS
-- ============================================================

--- Initialize vehicle state bag with fuel data
---@param networkId number Vehicle network ID
---@param vehicleFuel number Initial fuel level
---@param fuelType string "Petrol", "Diesel", or "Electro"
RegisterNetEvent('r4x_gas.CreateStateBag', function(networkId, vehicleFuel, fuelType)
    local vehicle = NetworkGetEntityFromNetworkId(networkId)
    local state = Entity(vehicle).state
    
    -- Set fuel type
    state.fuelType = fuelType

    -- Initialize fuel level if not set
    if not state.fuel and GetEntityType(vehicle) == 2 and NetworkGetEntityOwner(vehicle) == source then
        state:set('fuel', vehicleFuel or 100, true)
    end
end)

--- Update fuel level after refueling
---@param fuel number Current fuel level
---@param newFuel number Fuel added
---@param networkID number Vehicle network ID
RegisterNetEvent('r4x_gas.fuelingDone', function(fuel, newFuel, networkID)
    local currentFuel = math.floor(fuel)
    if currentFuel < 0 then return end

    local vehicle = NetworkGetEntityFromNetworkId(networkID)
    if not DoesEntityExist(vehicle) then return end

    local state = Entity(vehicle).state
    if not state then return end

    -- Cap fuel at 100%
    local fuelToSet = math.min(100, currentFuel + newFuel)
    state:set('fuel', fuelToSet, true)
end)

--- Set fuel to 100% after electric charging complete
---@param networkID number Vehicle network ID
RegisterNetEvent('r4x_gas.vehicleCharged', function(networkID)
    local vehicle = NetworkGetEntityFromNetworkId(networkID)
    if not DoesEntityExist(vehicle) then return end

    local state = Entity(vehicle).state
    if not state then return end

    state:set('fuel', 100, true)
end)