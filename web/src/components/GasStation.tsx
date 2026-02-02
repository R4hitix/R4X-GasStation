/**
 * R4x Gas Station - Gas Station Component
 * Main UI panel for gasoline/diesel refueling
 */

import React, { useState } from 'react';
import './gasstation.css';
import { fetchNui } from '../utils/fetchNui';

// ============================================================
// TYPES
// ============================================================

interface GasStationConfig {
  petrolPrice: number;
  dieselPrice: number;
  petrolCanPrice: number;
  dieselCanPrice: number;
}

interface GasStationProps {
  gasStationConfig: GasStationConfig;
  gasStationName: string;
  gasStationLocation: string;
  currentVehicleFuel: number;
}

type FuelType = 'Petrol' | 'Diesel';
type PaymentMethod = 'cash' | 'card';
type JerryCanType = 'petrol' | 'diesel';

// ============================================================
// COMPONENT
// ============================================================

/**
 * Gas Station refueling interface
 * Displays fuel gauge, slider for amount, and payment options
 */
const GasStation: React.FC<GasStationProps> = ({
  gasStationConfig,
  gasStationName,
  gasStationLocation,
  currentVehicleFuel,
}) => {
  // ============================================================
  // STATE
  // ============================================================

  const [selectedFuel, setSelectedFuel] = useState<FuelType>('Petrol');
  const [sliderValue, setSliderValue] = useState(1);
  const [showJerryCan, setShowJerryCan] = useState(false);

  // ============================================================
  // CALCULATED VALUES
  // ============================================================

  const maxFuel = Math.max(1, Math.round(100 - currentVehicleFuel));
  const currentPrice = selectedFuel === 'Petrol'
    ? gasStationConfig.petrolPrice
    : gasStationConfig.dieselPrice;
  const totalPrice = (currentPrice * sliderValue).toFixed(2);

  // Gauge calculations
  const gaugePercentage = Math.round(currentVehicleFuel);
  const circumference = 2 * Math.PI * 40;
  const strokeDashoffset = circumference - (gaugePercentage / 100) * circumference;

  // ============================================================
  // HANDLERS
  // ============================================================

  /** Send payment request to Lua */
  const handlePayment = (method: PaymentMethod) => {
    fetchNui('payment', {
      _fuelType: selectedFuel,
      _tankValue: sliderValue,
      _paymentType: method,
    });
  };

  /** Purchase jerry can */
  const handleBuyJerryCan = (type: JerryCanType) => {
    fetchNui('jerrycan', type);
    setShowJerryCan(false);
  };

  /** Switch fuel type and reset slider */
  const handleFuelTypeChange = (type: FuelType) => {
    setSelectedFuel(type);
    setSliderValue(1);
  };

  // ============================================================
  // RENDER
  // ============================================================

  return (
    <div className="fuel-panel-container">
      <div className="fuel-panel glass">

        {/* Header Section */}
        <div className="fuel-panel__header">
          <div className="fuel-panel__location">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
              <circle cx="12" cy="10" r="3" />
            </svg>
            <span>{gasStationLocation}</span>
          </div>
          <h2 className="fuel-panel__title">{gasStationName}</h2>
        </div>

        {/* Fuel Type Selector */}
        <div className="fuel-panel__selector">
          <button
            className={`fuel-btn ${selectedFuel === 'Petrol' ? 'active' : ''}`}
            onClick={() => handleFuelTypeChange('Petrol')}
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
              <path d="M18 10a1 1 0 0 1-1-1 1 1 0 0 0-1-1h-1V4a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2v-6h1l3 3v-9a1 1 0 0 1 1-1 1 1 0 0 1-2 0zM9 4h2v4H9z" />
            </svg>
            PETROL
          </button>
          <button
            className={`fuel-btn ${selectedFuel === 'Diesel' ? 'active' : ''}`}
            onClick={() => handleFuelTypeChange('Diesel')}
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
              <path d="M18 10a1 1 0 0 1-1-1 1 1 0 0 0-1-1h-1V4a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2v-6h1l3 3v-9a1 1 0 0 1 1-1 1 1 0 0 1-2 0zM9 4h2v4H9z" />
            </svg>
            DIESEL
          </button>
        </div>

        {/* Circular Fuel Gauge */}
        <div className="fuel-panel__gauge">
          <svg viewBox="0 0 100 100" className="gauge-svg">
            <circle cx="50" cy="50" r="40" fill="none" stroke="rgba(255,255,255,0.1)" strokeWidth="6" />
            <circle
              cx="50" cy="50" r="40"
              fill="none"
              stroke="url(#gaugeGradient)"
              strokeWidth="6"
              strokeLinecap="round"
              strokeDasharray={circumference}
              strokeDashoffset={strokeDashoffset}
              transform="rotate(-90 50 50)"
              className="gauge-progress"
            />
            <defs>
              <linearGradient id="gaugeGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                <stop offset="0%" stopColor="#3b82f6" />
                <stop offset="100%" stopColor="#60a5fa" />
              </linearGradient>
            </defs>
          </svg>
          <div className="gauge-center">
            <span className="gauge-value">{gaugePercentage}%</span>
            <span className="gauge-label">TANK</span>
          </div>
        </div>

        {/* Amount Slider */}
        <div className="fuel-panel__slider-section">
          <div className="slider-header">
            <span>Select amount</span>
            <span className="slider-value">{sliderValue} L</span>
          </div>
          <input
            type="range"
            min="1"
            max={maxFuel}
            value={sliderValue}
            onChange={(e) => setSliderValue(Number(e.target.value))}
            className="fuel-slider"
          />
          <div className="slider-labels">
            <span>1L</span>
            <span>{maxFuel}L</span>
          </div>
        </div>

        {/* Price Display */}
        <div className="fuel-panel__price glass-light">
          <div className="price-row">
            <span className="price-label">Price per liter</span>
            <span className="price-value">${currentPrice}</span>
          </div>
          <div className="price-row total">
            <span className="price-label">Total</span>
            <span className="price-total">${totalPrice}</span>
          </div>
        </div>

        {/* Payment Buttons */}
        <div className="fuel-panel__actions">
          <button className="pay-btn" onClick={() => handlePayment('cash')}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <rect x="2" y="6" width="20" height="12" rx="2" />
              <circle cx="12" cy="12" r="2" />
              <path d="M6 12h.01M18 12h.01" />
            </svg>
            CASH
          </button>
          <button className="pay-btn" onClick={() => handlePayment('card')}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <rect x="2" y="4" width="20" height="16" rx="2" />
              <path d="M2 10h20" />
            </svg>
            CARD
          </button>
        </div>

        {/* Jerry Can Button */}
        <button className="jerrycan-btn" onClick={() => setShowJerryCan(true)}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
            <path d="M4 21V10l8-6 8 6v11a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2z" />
          </svg>
          Buy Jerry Can
        </button>
      </div>

      {/* Jerry Can Purchase Modal */}
      {showJerryCan && (
        <div className="jerrycan-modal" onClick={() => setShowJerryCan(false)}>
          <div className="jerrycan-modal__content glass" onClick={(e) => e.stopPropagation()}>
            <h3>Select Jerry Can</h3>
            <div className="jerrycan-options">
              <button className="jerrycan-option" onClick={() => handleBuyJerryCan('petrol')}>
                <div className="jerrycan-icon petrol">⛽</div>
                <span className="jerrycan-type">Petrol</span>
                <span className="jerrycan-amount">25L</span>
                <span className="jerrycan-price">${gasStationConfig.petrolCanPrice}</span>
              </button>
              <button className="jerrycan-option" onClick={() => handleBuyJerryCan('diesel')}>
                <div className="jerrycan-icon diesel">⛽</div>
                <span className="jerrycan-type">Diesel</span>
                <span className="jerrycan-amount">25L</span>
                <span className="jerrycan-price">${gasStationConfig.dieselCanPrice}</span>
              </button>
            </div>
            <button className="jerrycan-close" onClick={() => setShowJerryCan(false)}>
              Cancel
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default GasStation;
