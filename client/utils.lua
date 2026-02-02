--[[
    R4x Gas Station - NUI Utility Functions
    Handles NUI visibility and communication with React frontend
]]

-- ============================================================
-- NUI VISIBILITY
-- ============================================================

--- Hide NUI and remove focus
function hideNui()
    SetNuiFocus(false, false)
    TriggerScreenblurFadeOut(1000)
    
    SendNUIMessage({
        action = 'eventHandler',
        data = {
            _value = 'close',
            _visible = false
        }
    })
end

-- NUI callback to close interface
RegisterNUICallback('hideGasStation', function()
    hideNui()
end)

-- ============================================================
-- GAS STATION NUI
-- ============================================================

--- Open gas station interface
---@param stationName string Station display name
---@param location string Location/street name
---@param currentFuel number Current vehicle fuel level (0-100)
function openGasStation(stationName, location, currentFuel)
    SetNuiFocus(true, true)
    TriggerScreenblurFadeIn(1000)
    
    SendNUIMessage({
        action = 'eventHandler',
        data = {
            _value = 'Gas-Station',
            _visible = true,
            _name = stationName,
            _location = location,
            _currentFuelLevel = currentFuel
        }
    })
end

-- ============================================================
-- ELECTRIC STATION NUI
-- ============================================================

--- Open electric station interface
---@param stationName string Station display name
---@param location string Location/street name
---@param batteryLevel number Current battery level (0-100)
---@param isCharging boolean Is vehicle currently charging
function openElectricStation(stationName, location, batteryLevel, isCharging)
    SetNuiFocus(true, true)
    TriggerScreenblurFadeIn(1000)
    
    SendNUIMessage({
        action = 'eventHandler',
        data = {
            _value = 'Electric-Station',
            _visible = true,
            _name = stationName,
            _location = location,
            _currentFuelLevel = batteryLevel,
            _chargingPrice = Config.ChargingPrice,
            _isCharging = isCharging
        }
    })
end
