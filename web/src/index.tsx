/**
 * R4x Gas Station - React Entry Point
 * Mounts the main App component to the DOM
 */

import React from 'react';
import { createRoot } from 'react-dom/client';
import { isEnvBrowser } from './utils/misc';
import './index.css';
import App from './App';

// Get root element
const root = document.getElementById('root');

// Development: Set background image for testing
if (isEnvBrowser()) {
  root!.style.backgroundImage = 'url("https://i.imgur.com/3pzRj9n.png")';
  root!.style.backgroundSize = 'cover';
  root!.style.backgroundRepeat = 'no-repeat';
  root!.style.backgroundPosition = 'center';
}

// Mount React app
createRoot(root!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
