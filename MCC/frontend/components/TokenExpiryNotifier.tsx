'use client';

import { useEffect, useRef } from 'react';
import { useAuthStore } from '@/store/authStore';
import axiosInstance from '@/lib/axios';

const TokenExpiryNotifier = () => {
  // Get state and actions from the Zustand store
  const { accessTokenExp, setUser, logout } = useAuthStore();
  const modalShown = useRef(false);

  useEffect(() => {
    // Only run if we have an expiration time in our state
    if (!accessTokenExp) return;

    const checkTokenExpiry = async () => {
      const nowInSeconds = Math.floor(Date.now() / 1000);
      const timeToExpiry = accessTokenExp - nowInSeconds;

      // Check if token expires in the next 60 seconds
      if (timeToExpiry > 0 && timeToExpiry < 60 && !modalShown.current) {
        modalShown.current = true; // Prevent multiple alerts

        const extendSession = window.confirm(
          'Your session will expire in less than a minute. Do you want to extend it?'
        );

        if (extendSession) {
          try {
            const response = await axiosInstance.post('/token/refresh/');
            setUser(response.data.access); // Update state with new token
            modalShown.current = false; // Reset for the next cycle
          } catch (error) {
            await logout(); // If refresh fails for any reason, log out
          }
        } else {
          await logout(); // If user clicks "Cancel", log out
        }
      }
    };

    const interval = setInterval(checkTokenExpiry, 10000); // Check every 10 seconds

    return () => clearInterval(interval);
  }, [accessTokenExp, setUser, logout]);

  return null;
};

export default TokenExpiryNotifier;