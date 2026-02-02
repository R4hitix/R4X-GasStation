/**
 * R4x Gas Station - NUI Event Hook
 * React hook for listening to NUI messages from Lua
 */

import { MutableRefObject, useEffect, useRef } from 'react';
import { noop } from '../utils/misc';

// ============================================================
// TYPES
// ============================================================

interface NuiMessageData<T = unknown> {
  action: string;
  data: T;
}

type NuiHandler<T> = (data: T) => void;

// ============================================================
// HOOK
// ============================================================

/**
 * Hook to listen for NUI messages from Lua client scripts
 * 
 * @template T - Type of data expected from the event
 * @param action - The event action name to listen for
 * @param handler - Callback function to handle incoming data
 * 
 * @example
 * useNuiEvent<{ visible: boolean }>('setVisible', (data) => {
 *   setVisible(data.visible);
 * });
 */
export const useNuiEvent = <T = any>(
  action: string,
  handler: NuiHandler<T>
): void => {
  // Store handler in ref to avoid stale closures
  const savedHandler: MutableRefObject<NuiHandler<T>> = useRef(noop);

  // Update ref when handler changes
  useEffect(() => {
    savedHandler.current = handler;
  }, [handler]);

  // Set up event listener
  useEffect(() => {
    const eventListener = (event: MessageEvent<NuiMessageData<T>>) => {
      const { action: eventAction, data } = event.data;

      if (eventAction === action && savedHandler.current) {
        savedHandler.current(data);
      }
    };

    window.addEventListener('message', eventListener);

    // Cleanup on unmount
    return () => window.removeEventListener('message', eventListener);
  }, [action]);
};

export default useNuiEvent;
