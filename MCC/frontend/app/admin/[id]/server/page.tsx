"use client";

import axiosInstance from "@/lib/axios";
import { useAuthStore } from "@/store/authStore";
import { useRouter } from "next/navigation";

export default function DashboardPage() {
  const { user, logout } = useAuthStore();
  const router = useRouter();

  const handleLogout = async () => {
    try {
      await axiosInstance.post("/logout/");
    } catch (error) {
      console.error("Logout failed", error);
    } finally {
      logout(); // Clear state in store
      router.push("/login"); // Redirect to login
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
