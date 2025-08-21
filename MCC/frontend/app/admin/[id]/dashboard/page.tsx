// components/DashboardPage.tsx
"use client";

import axiosInstance from "@/lib/axios";
import { useAuthStore } from "@/store/authStore";
import { useRouter } from "next/navigation";
import Cookies from "js-cookie"; // Install js-cookie: npm install js-cookie

export default function DashboardPage() {
  const { user, logout } = useAuthStore();
  const router = useRouter();

  const handleLogout = async () => {
    try {
      const refreshToken = Cookies.get("refresh_token"); // Get the refresh token from the cookie

      if (refreshToken) {
        // Send the refresh token in the request body to the backend's TokenBlacklistView
        await axiosInstance.post("/logout/", {
          refresh: refreshToken,
        });
        console.log("Logout successful");
      }
    } catch (error) {
      console.error("Logout failed", error);
    } finally {
      // Always clear local state and cookies regardless of the backend response
      logout();
      Cookies.remove("access_token");
      Cookies.remove("refresh_token");
      router.push("/login");
    }
  };

  return (
    <div>
      <h1>Admin Dashboard</h1>
      {user ? (
        <>
          <p>Welcome, {user.username}!</p>
          <p>Your ID: {user.admin_id}</p>
          <button onClick={handleLogout}>Logout</button>
        </>
      ) : (
        <p>Loading user data...</p>
      )}
    </div>
  );
}
