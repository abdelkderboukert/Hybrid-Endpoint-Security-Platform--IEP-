"use client";
import { useState } from "react";
import axiosInstance from "@/lib/axios";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { motion } from "framer-motion";

export default function RegisterPage() {
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [password2, setPassword2] = useState("");
  const [error, setError] = useState("");
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    console.log(username, email, password, password2);
    if (password !== password2) {
      setError("Passwords do not match");
      return;
    }
    try {
      await axiosInstance.post("/register/", {
        username,
        email,
        password,
        password2,
      });
      router.push("/login");
    } catch (err: any) {
      setError(err.response?.data?.detail || "Registration failed");
      console.error("Registration error:", err);
    }
  };

  return (
    <div className="size-full flex items-center justify-center min-h-screen bg-white flex-col">
      <h2 className="text-black text-2xl font-bold">
        Sign in to B luck Business <br /> Hub
      </h2>
      <p className="text-black m-4">
        You have an account?{" "}
        <Link href={"/login"} className="font-bold text-blue-800">
          Login
        </Link>{" "}
      </p>
      <form
        onSubmit={handleSubmit}
        className="bg-white shadow-xl w-3/8 h-max p-8 flex flex-col justify-center items-center rounded-lg"
      >
        <div className="h-8 w-4/5 flex justify-start items-end text-black/50 text-sm mb-1">
          Username
        </div>
        <input
          type="text"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          placeholder="Username"
          className="h-14 w-4/5 mb-4 p-2 border border-gray-300 text-blue-300 rounded-xl"
          required
        />
        <div className="h-8 w-4/5 flex justify-start items-end text-black/50 text-sm mb-1">
          Email
        </div>
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="Email"
          className="h-14 w-4/5 mb-4 p-2 border border-gray-300 text-blue-300 rounded-xl"
          required
        />
        <div className="h-8 w-4/5 flex justify-start items-end text-black/50 text-sm mb-1">
          Password
        </div>
        <input
          className="h-14 w-4/5 mb-4 p-2 border border-gray-300 text-blue-300 rounded-xl"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password"
          required
        />
        <div className="h-8 w-4/5 flex justify-start items-end text-black/50 text-sm mb-1">
          Password
        </div>
        <input
          className="h-14 w-4/5 mb-4 p-2 border border-gray-300 text-blue-300 rounded-xl"
          type="password"
          value={password2}
          onChange={(e) => setPassword2(e.target.value)}
          placeholder="Confirm Password"
          required
        />
        <motion.button
          type="submit"
          className="h-14 w-4/5 mb-4 p-2 border border-gray-300 bg-blue-400 rounded-xl"
        >
          Register
        </motion.button>
        {error && <p style={{ color: "red" }}>{error}</p>}
      </form>
    </div>
  );
}
