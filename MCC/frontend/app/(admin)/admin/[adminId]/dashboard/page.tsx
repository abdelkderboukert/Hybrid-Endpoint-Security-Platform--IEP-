// frontend/app/(admin)/dashboard/page.tsx
"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/Context/AuthContext";

export default function DashboardPage() {
  const { user, loading, logout } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && !user) {
      router.push("/login");
    }
  }, [loading, user, router]);

  if (loading) {
    return (
      <div className="flex justify-center items-center h-screen">
        <p>Loading...</p>
      </div>
    );
  }

  if (!user) {
    return null;
  }

  return (
    <div className="min-h-screen bg-gray-100 items-center flex flex-col justify-center">
      <div className="bg-gray-600 p-8 flex flex-col rounded-lg">
        <h1>Hi, {user.username}</h1>
        <button className="bg-blue-400 p-1 rounded-sm m-1" onClick={logout}>
          Logout
        </button>
      </div>
    </div>
  );
}
