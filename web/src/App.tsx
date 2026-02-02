/**
 * R4x Gas Station - Application Entry Point
 */

import React, { useState, useEffect } from 'react';
import './App.css';
import { useNuiEvent } from './hooks/useNuiEvent';
import { fetchNui } from './utils/fetchNui';
import GasStation from './components/GasStation';
import ElectricStation from './components/ElectricStation';

// ============================================================
// TYPES
// ============================================================

interface GasStationConfig {
  petrolPrice: number;
  dieselPrice: number;
  petrolCanPrice: number;
  dieselCanPrice: number;
}

// ============================================================
// COMPONENT
// ============================================================

const App: React.FC = () => {
  // Gas Station State
  const [isGasStationVisible, setIsGasStationVisible] = useState(false);
  const [gasStationName, setGasStationName] = useState('');
  const [gasStationLocation, setGasStationLocation] = useState('');
  const [currentVehicleFuel, setCurrentVehicleFuel] = useState(0);

  // Electric Station State
  const [isElectroStationVisible, setIsElectroStationVisible] = useState(false);
  const [chargingPrice, setChargingPrice] = useState(0);
  const [isCharging, setIsCharging] = useState(false);

  // Configuration
  const [gasStationConfig, setGasStationConfig] = useState<GasStationConfig>({
    petrolPrice: 0,
    dieselPrice: 0,
    petrolCanPrice: 0,
    dieselCanPrice: 0,
  });

  // ESC key handler
  useEffect(() => {
    const handleEscapeKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        fetchNui('hideGasStation');
      }
    };
    window.addEventListener('keydown', handleEscapeKey);
    return () => window.removeEventListener('keydown', handleEscapeKey);
  }, []);

  // NUI Events
  useNuiEvent('init', (data: GasStationConfig) => {
    setGasStationConfig(data);
  });

  useNuiEvent('eventHandler', (data: any) => {
    switch (data._value) {
      case 'Gas-Station':
        setIsGasStationVisible(data._visible);
        setGasStationName(data._name);
        setGasStationLocation(data._location);
        setCurrentVehicleFuel(data._currentFuelLevel);
        break;
      case 'Electric-Station':
        setIsElectroStationVisible(data._visible);
        setGasStationName(data._name);
        setGasStationLocation(data._location);
        setCurrentVehicleFuel(data._currentFuelLevel);
        setChargingPrice(data._chargingPrice);
        setIsCharging(data._isCharging);
        break;
      case 'close':
        setIsGasStationVisible(false);
        setIsElectroStationVisible(false);
        break;
    }
  });

  return (
    <>
      {isGasStationVisible && (
        <GasStation
          gasStationConfig={gasStationConfig}
          gasStationName={gasStationName}
          gasStationLocation={gasStationLocation}
          currentVehicleFuel={currentVehicleFuel}
        />
      )}
      {isElectroStationVisible && (
        <ElectricStation
          chargingPrice={chargingPrice}
          gasStationName={gasStationName}
          gasStationLocation={gasStationLocation}
          currentVehicleFuel={currentVehicleFuel}
          isCharging={isCharging}
        />
      )}
    </>
  );
};

export default App;
