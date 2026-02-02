/**
 * R4x Gas Station - Electric Station Component
 * UI panel for electric vehicle charging
 */

import React from 'react';
import './electricstation.css';
import { fetchNui } from '../utils/fetchNui';

// ============================================================
// TYPES
// ============================================================

interface ElectricStationProps {
  chargingPrice: number;
  gasStationName: string;
  gasStationLocation: string;
  currentVehicleFuel: number;
  isCharging: boolean;
}

type PaymentMethod = 'cash' | 'card';

// ============================================================
// COMPONENT
// ============================================================

/**
 * Electric vehicle charging interface
 * Displays battery gauge with charging animations and payment options
 */
const ElectricStation: React.FC<ElectricStationProps> = ({
  chargingPrice,
  gasStationName,
  gasStationLocation,
  currentVehicleFuel,
  isCharging,
}) => {
  // ============================================================
  // CALCULATED VALUES
  // ============================================================

  const batteryLevel = Math.round(currentVehicleFuel);
  const circumference = 2 * Math.PI * 45;
  const strokeDashoffset = circumference - (batteryLevel / 100) * circumference;

  // ============================================================
  // HANDLERS
  // ============================================================

  /** Send charging payment request to Lua */
  const handlePayment = (method: PaymentMethod) => {
    fetchNui('epayment', {
      paymentMethod: method,
      _tankValue: batteryLevel,
    });
  };

  // ============================================================
  // RENDER
  // ============================================================

  return (
    <div className="electric-panel-container">
      <div className="electric-panel glass">

        {/* Header Section */}
        <div className="electric-panel__header">
          <span className="electric-badge">⚡ EV CHARGING</span>
          <h2 className="electric-panel__title">{gasStationName}</h2>
          <p className="electric-panel__location">{gasStationLocation}</p>
        </div>

        {/* Battery Gauge with Animations */}
        <div className={`electric-panel__gauge ${isCharging ? 'is-charging' : ''}`}>

          {/* Outer glow ring (visible when charging) */}
          {isCharging && <div className="gauge-glow-ring"></div>}

          <svg viewBox="0 0 100 100" className="gauge-svg">
            {/* Background circle */}
            <circle
              cx="50" cy="50" r="45"
              fill="none"
              stroke="rgba(255,255,255,0.08)"
              strokeWidth="8"
            />

            {/* Animated glow when charging */}
            {isCharging && (
              <circle
                cx="50" cy="50" r="45"
                fill="none"
                stroke="rgba(34, 197, 94, 0.2)"
                strokeWidth="8"
                className="gauge-charging-bg"
              />
            )}

            {/* Progress circle with gradient */}
            <circle
              cx="50" cy="50" r="45"
              fill="none"
              stroke="url(#electricGradient)"
              strokeWidth="8"
              strokeLinecap="round"
              strokeDasharray={circumference}
              strokeDashoffset={strokeDashoffset}
              transform="rotate(-90 50 50)"
              className="gauge-progress"
            />

            <defs>
              <linearGradient id="electricGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#22c55e" />
                <stop offset="50%" stopColor="#4ade80" />
                <stop offset="100%" stopColor="#86efac" />
              </linearGradient>
            </defs>
          </svg>

          {/* Center Content */}
          <div className="gauge-center">
            {isCharging ? (
              <>
                <div className="charging-bolt">⚡</div>
                <span className="gauge-value charging">{batteryLevel}%</span>
                <span className="gauge-label">CHARGING...</span>
              </>
            ) : (
              <>
                <div className="battery-icon-wrapper">
                  <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                    <rect x="3" y="7" width="16" height="10" rx="2" />
                    <path d="M21 10v4" />
                    <rect
                      x="5" y="9"
                      width={Math.max(1, batteryLevel / 100 * 12)}
                      height="6"
                      rx="1"
                      fill="currentColor"
                    />
                  </svg>
                </div>
                <span className="gauge-value">{batteryLevel}%</span>
                <span className="gauge-label">BATTERY</span>
              </>
            )}
          </div>

          {/* Floating particles when charging */}
          {isCharging && (
            <div className="charging-particles">
              <span></span><span></span><span></span><span></span>
              <span></span><span></span><span></span><span></span>
            </div>
          )}
        </div>

        {/* Status Info Section */}
        <div className="electric-panel__info">
          <div className="info-item">
            <span className="info-label">Status</span>
            <span className={`info-value ${isCharging ? 'status-charging' : 'status-ready'}`}>
              {isCharging ? '⚡ Charging' : 'Ready'}
            </span>
          </div>
          <div className="info-divider"></div>
          <div className="info-item">
            <span className="info-label">Rate</span>
            <span className="info-value price">${chargingPrice}/kWh</span>
          </div>
        </div>

        {/* Payment Buttons (hidden while charging) */}
        {!isCharging && (
          <div className="electric-panel__actions">
            <button className="charge-btn" onClick={() => handlePayment('cash')}>
              <span className="btn-icon">💵</span>
              <span>CASH</span>
            </button>
            <button className="charge-btn" onClick={() => handlePayment('card')}>
              <span className="btn-icon">💳</span>
              <span>CARD</span>
            </button>
          </div>
        )}

        {/* Cancel Button (visible while charging) */}
        {isCharging && (
          <button className="cancel-btn" onClick={() => fetchNui('hideGasStation')}>
            Stop Charging
          </button>
        )}
      </div>
    </div>
  );
};

export default ElectricStation;
