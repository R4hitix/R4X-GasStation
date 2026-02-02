# 🚀 R4x Gas Station

**Modern fuel system for FiveM with beautiful UI, electric vehicle support, and smooth animations.**

Built with Lua + React/TypeScript for that premium feel.

---

## ✨ Features

- 🛢️ **Gasoline & Diesel** - Different prices, realistic consumption
- ⚡ **Electric Vehicles** - Dedicated charging stations with cool animations  
- 🔧 **Jerry Cans** - Buy and use petrol/diesel cans from the pump
- 💳 **Multiple Payment** - Cash or bank card
- 🎨 **Modern UI** - Glassmorphism design, floating panels, neon glows
- 📍 **Map Blips** - All stations visible on the map
- 🔄 **State Bags** - Fuel persists across sessions

---

## 📦 Dependencies

- [ox_lib](https://github.com/overextended/ox_lib) (required)
- [ESX Legacy](https://github.com/esx-framework/esx_core)
- [ox_inventory](https://github.com/overextended/ox_inventory) (for jerry cans)

---

## 🔧 Installation

1. Drop `r4x_gasstation` in your resources folder
2. Add to `server.cfg`:
   ```
   ensure r4x_gasstation
   ```
3. Add items to `ox_inventory/data/items.lua`:
   ```lua
   ['jerrycan_petrol'] = {
       label = 'Petrol Can',
       weight = 2500,
       stack = false,
       close = true,
       client = {
           export = 'r4x_gasstation.jerrycan_petrol'
       }
   },
   
   ['jerrycan_diesel'] = {
       label = 'Diesel Can',
       weight = 2500,
       stack = false,
       close = true,
       client = {
           export = 'r4x_gasstation.jerrycan_diesel'
       }
   }
   ```
4. Restart your server

---

## 💡 Usage

### Get vehicle fuel
```lua
local vehicle = GetPlayersLastVehicle()
local fuel = Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle)
```

### Set vehicle fuel
```lua
Entity(vehicle).state.fuel = 75.0
```

### Configure vehicles
Edit `config.lua` to set which vehicles use Diesel or Electric:
```lua
Vehicles = {
    ["Diesel"] = { "adder", "sultan" },
    ["Electro"] = { "neon", "voltic", "raiden" }
}
```

---

## ⚙️ Configuration

All settings are in `config.lua`:

| Setting | Description | Default |
|---------|-------------|---------|
| `PetrolPrice` | Price per liter (gasoline) | 5 |
| `DieselPrice` | Price per liter (diesel) | 8 |
| `ChargingPrice` | Price per kWh | 3 |
| `ShowBlips` | Show stations on map | true |
| `ManageFuel` | Enable fuel consumption | true |

---

## 📍 Adding Stations

Edit `data/stations.lua`:
```lua
[vec3(x, y, z)] = {
    fType = 'gas', -- or 'electric'
    GasStation_Name = "My Station",
    Zone_Street_Name = "Location Name",
    PumpObjectsCoords = {
        vector3(x, y, z), -- pump positions
    }
}
```

---

## 🎨 Customization

The UI is built with React. To modify:
1. Navigate to `web/`
2. Run `npm install`
3. Edit components in `src/components/`
4. Build with `npm run build`

---

## 📝 Credits

Made with ❤️ by R4x Team.

---

**Questions?** Open an issue or reach out!
