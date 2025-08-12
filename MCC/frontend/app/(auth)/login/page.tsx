"use client";
import { useState } from "react";
import axiosInstance from "@/lib/axios";
import { jwtDecode } from "jwt-decode";
import { useRouter } from "next/navigation";
import { useAuthStore } from "@/store/authStore";

export default function LoginPage() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const router = useRouter();
  const setUser = useAuthStore((state) => state.setUser);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const response = await axiosInstance.post("/login/", {
        username,
        password,
      });
      const { access, refresh } = response.data; // Backend sends tokens in body and cookies

      // We use the access token to set user state
      setUser(access);

      // Navigate to a protected page, for example the user's dashboard
      // The user ID should come from the decoded token in your auth store
      const decodedToken: { user_id: string } = jwtDecode(access);
      router.push(`/admin/${decodedToken.user_id}/dashboard`);
    } catch (err: any) {
      setError(err.response?.data?.detail || "Login failed");
    }
  };

  return (
    <div>
      <h1>Login</h1>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          placeholder="Username"
          required
        />
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password"
          required
        />
        <button type="submit">Login</button>
        {error && <p style={{ color: "red" }}>{error}</p>}
      </form>
    </div>
  );
}
