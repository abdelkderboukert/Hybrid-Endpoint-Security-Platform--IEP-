"use client";

import { useEffect, useState } from "react";
import { usePathname } from "next/navigation"; // Import the usePathname hook
import { useAuthStore } from "@/store/authStore";
import axiosInstance from "@/lib/axios";

const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const { setUser, user } = useAuthStore();
  const [loading, setLoading] = useState(true);
  const pathname = usePathname(); // Get the current URL path

  useEffect(() => {
    // Define your public paths where a session check is not needed
    const publicPaths = ["/", "/login", "/register"];

    // Check if the current path is a public one or the dynamic verification path
    if (
      publicPaths.includes(pathname) ||
      pathname.startsWith("/verify-email")
    ) {
      setLoading(false);
      return; // Skip the session check entirely
    }

    // This logic will now ONLY run on protected paths
    const initializeAuth = async () => {
      if (user) {
        setLoading(false);
        return;
      }
      try {
        const response = await axiosInstance.post("/token/refresh/");
        setUser(response.data.access);
      } catch (error) {
        setUser(null);
      } finally {
        setLoading(false);
      }
    };

    initializeAuth();
  }, [pathname, setUser, user]);

  // For public paths, loading is set to false immediately and children are rendered.
  // For protected paths, this shows a loading state during the session check.
  if (loading) {
    return <div>Loading...</div>;
  }

  return <>{children}</>;
};

export default AuthProvider;
