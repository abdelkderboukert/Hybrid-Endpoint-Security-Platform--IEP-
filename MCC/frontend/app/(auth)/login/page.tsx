"use client";
import { useState } from "react";
import axiosInstance from "@/lib/axios";
import { jwtDecode } from "jwt-decode";
import { useRouter } from "next/navigation";
import { useAuthStore } from "@/store/authStore";
import Link from "next/link";
import { motion } from "framer-motion";

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
    <div className="size-full flex items-center justify-center min-h-screen bg-white flex-col">
      <h2 className="text-black text-2xl font-bold">
        Sign in to B luck Business <br /> Hub
      </h2>
      <p className="text-black m-4">
        Don&apos;t have an account?{" "}
        <Link href={"/register"} className="font-bold text-blue-800">
          Create one
        </Link>{" "}
      </p>
      <form
        className="bg-white shadow-xl w-3/8 h-max p-8 flex flex-col justify-center items-center rounded-lg"
        onSubmit={handleSubmit}
      >
        <div className="h-8 w-4/5 flex justify-start items-end text-black/50 text-sm mb-1">
          Email
        </div>
        <input
          type="text"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          placeholder="Username"
          required
          className="h-14 w-4/5 mb-4 p-2 border border-gray-300 text-blue-300 rounded-xl"
        />
        <div className="h-8 w-4/5 flex justify-start items-end text-black/50 text-sm mb-1">
          Password
        </div>
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password"
          required
          className="h-14 w-4/5 mb-4 p-2 border border-gray-300 text-blue-300 rounded-xl"
        />
        <div className="h-8 w-4/5 flex justify-start items-center text-blue-500 mb-5 font-bold">
          Forgot your password?
        </div>
        <motion.button
          type="submit"
          className="h-14 w-4/5 mb-4 p-2 border border-gray-300 bg-blue-400 rounded-xl"
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          Login
        </motion.button>
        {error && <p style={{ color: "red" }}>{error}</p>}
      </form>
    </div>
  );
}
