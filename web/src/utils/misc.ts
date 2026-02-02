/**
 * R4x Gas Station - Miscellaneous Utilities
 */

/**
 * Checks if running in a regular browser (not FiveM CEF)
 * Useful for development and testing
 */
export const isEnvBrowser = (): boolean => {
    return !(window as any).invokeNative;
};

/**
 * Empty function placeholder
 */
export const noop = (): void => { };