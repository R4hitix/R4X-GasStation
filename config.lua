--[[
    R4x Gas Station - Configuration
    Modify these values to customize the fuel system
]]

-- ============================================================
-- PRICES
-- ============================================================

Config = {
    -- Fuel prices (per liter)
    PetrolPrice = 5,
    DieselPrice = 8,
    
    -- Jerry can prices
    PetrolCanPrice = 275,
    DieselCanPrice = 325,
    
    -- Electric charging price (per kWh)
    ChargingPrice = 3,
    
    -- Jerry can refuel duration (seconds)
    JerryCanFuelingTime = 12,
    
    -- Show blips on map
    ShowBlips = true,
    
    -- Enable fuel consumption while driving
    ManageFuel = true,
}

-- ============================================================
-- FUEL CONSUMPTION RATES
-- Based on RPM percentage (0.0 - 1.0)
-- Higher values = faster fuel consumption
-- ============================================================

Fuel_Consumption = {
    -- Gasoline vehicles - balanced consumption
    ['Petrol'] = {
        [1.0] = 1.4,  -- Max RPM
        [0.9] = 1.2,
        [0.8] = 1.0,
        [0.7] = 0.9,
        [0.6] = 0.8,
        [0.5] = 0.7,
        [0.4] = 0.5,
        [0.3] = 0.4,
        [0.2] = 0.2,
        [0.1] = 0.1,
        [0.0] = 0.1,  -- Idle
    },
    
    -- Diesel vehicles - more efficient at high RPM
    ['Diesel'] = {
        [1.0] = 1.0,
        [0.9] = 0.9,
        [0.8] = 0.8,
        [0.7] = 0.7,
        [0.6] = 0.6,
        [0.5] = 0.5,
        [0.4] = 0.3,
        [0.3] = 0.2,
        [0.2] = 0.1,
        [0.1] = 0.1,
        [0.0] = 0.1,
    },
    
    -- Electric vehicles - higher consumption at speed
    ['Electro'] = {
        [1.0] = 1.8,
        [0.9] = 1.6,
        [0.8] = 1.4,
        [0.7] = 1.2,
        [0.6] = 1.0,
        [0.5] = 0.9,
        [0.4] = 0.8,
        [0.3] = 0.5,
        [0.2] = 0.3,
        [0.1] = 0.2,
        [0.0] = 0.1,
    }
}

-- ============================================================
-- VEHICLE FUEL TYPES
-- Add vehicle models that use Diesel or Electric
-- All other vehicles default to Petrol
-- ============================================================

Vehicles = {
    -- Diesel vehicles (trucks, vans, etc.)
    ['Diesel'] = {
        'adder',
        'sultan',
        -- Add more diesel vehicles here
    },
    
    -- Electric vehicles (Tesla, etc.)
    ['Electro'] = {
        'teslax',
        't20',
        'neon',
        'voltic',
        'raiden',
        -- Add more electric vehicles here
    }
}