'use client';

import { useEffect, useState } from 'react';
import { useAuthStore } from '@/store/authStore';
import axiosInstance from '@/lib/axios';

const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const { setUser, user } = useAuthStore();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const initializeAuth = async () => {
      // If user is already in state (from client-side navigation), skip.
      if (user) {
        setLoading(false);
        return;
      }
      
      try {
        // Attempt to get a new access_token using the refresh_token cookie
        const response = await axiosInstance.post('/token/refresh/');
        const newAccessToken = response.data.access;
        
        // Use the new token to set the user state
        setUser(newAccessToken);
      } catch (error) {
        // This will fail if the refresh_token is invalid or expired
        setUser(null);
      } finally {
        setLoading(false);
      }
    };

    initializeAuth();
  }, [setUser]); // The empty dependency array ensures this runs only once on load

  // Show a loading message while we check the session
  if (loading) {
    return <div>Loading session...</div>;
  }

  // Once loading is false, show the rest of the application
  return <>{children}</>;
};

export default AuthProvider;