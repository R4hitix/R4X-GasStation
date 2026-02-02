/**
 * R4x Gas Station - NUI Fetch Utility
 * Sends data to the Lua client scripts via NUI callbacks
 */

/**
 * Sends a request to the Lua NUI callback handler
 * @template T - Expected response type
 * @param eventName - The NUI callback event name
 * @param data - Optional data to send with the request
 * @returns Promise resolving to the response data
 * 
 * @example
 * // Send payment request
 * await fetchNui('payment', { amount: 100, method: 'cash' });
 */
export async function fetchNui<T = any>(
  eventName: string,
  data?: any
): Promise<T | null> {
  const options: RequestInit = {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify(data),
  };

  // Get resource name from FiveM or use default for browser dev
  const resourceName = (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : 'nui-frame-app';

  try {
    const response = await fetch(`https://${resourceName}/${eventName}`, options);

    if (!response.ok) {
      throw new Error(`NUI request failed: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.warn(`[R4x Gas] NUI fetch error:`, error);
    return null;
  }
}
