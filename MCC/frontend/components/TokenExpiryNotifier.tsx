"use client";

import { useEffect } from "react";
import Cookies from "js-cookie"; // `npm install js-cookie @types/js-cookie`
import { jwtDecode } from "jwt-decode";
import axiosInstance from "@/lib/axios";

const TokenExpiryNotifier = () => {
  useEffect(() => {
    const interval = setInterval(() => {
      const token = Cookies.get("access_token"); // We read the cookie to check expiry
      if (!token) return;

      try {
        const decoded: { exp: number } = jwtDecode(token);
        const now = Date.now() / 1000;

        // Check if the token expires in the next 60 seconds
        if (decoded.exp < now + 60) {
          // You can show a modal here
          const extendSession = window.confirm(
            "Your session is about to expire. Do you want to extend it?"
          );

          if (extendSession) {
            // Call the refresh endpoint. The axios interceptor will handle the logic,
            // but we can also call it proactively.
            axiosInstance.post("/token/refresh/").catch((err) => {
              console.error("Failed to refresh token proactively", err);
              // Handle logout if proactive refresh fails
            });
          } else {
            // User chose not to extend, so log them out
            // Ideally, call your logout function from the auth store
            window.location.href = "/login"; // Simple redirect
          }
          // Clear interval once the prompt is shown to avoid multiple popups
          clearInterval(interval);
        }
      } catch (e) {
        console.error("Invalid token", e);
      }
    }, 15000); // Check every 15 seconds

    return () => clearInterval(interval);
  }, []);

  return null; // This component does not render anything
};

export default TokenExpiryNotifier;
