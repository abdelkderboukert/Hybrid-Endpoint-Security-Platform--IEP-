"use client";
import React from "react";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { registerUser } from "@/utils/auth";
import Link from "next/link";
import { motion } from "framer-motion";

export default function RegisterPage() {
  const [userName, setUserName] = useState("");
  const [password, setPassword] = useState("");
  const [email, setEmail] = useState("");
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (userName === "" || password === "" || email === "") {
      return;
    }
    try {
      await registerUser(email, userName, password);
      alert("Yay! It worked! User Created!");
      router.push("/login");
    } catch (e) {
      alert("OOps!");
      console.error("Registration error:", e);
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
          className="h-14 w-4/5 mb-4 p-2 border border-gray-300 text-blue-300 rounded-xl"
          type="text"
          value={userName}
          required
          onChange={(e) => {
            setUserName(e.target.value);
          }}
          
        />
        <br />

        <div className="h-8 w-4/5 flex justify-start items-end text-black/50 text-sm mb-1">
          Email
        </div>
        <input
          className="h-14 w-4/5 mb-4 p-2 border border-gray-300 text-blue-300 rounded-xl"
          type="email"
          value={email}
          required
          onChange={(e) => {
            setEmail(e.target.value);
          }}
        />
        <br />

        <div className="h-8 w-4/5 flex justify-start items-end text-black/50 text-sm mb-1">
          Password
        </div>
        <input
          className="h-14 w-4/5 mb-4 p-2 border border-gray-300 text-blue-300 rounded-xl"
          type="password"
          value={password}
          required
          onChange={(e) => {
            setPassword(e.target.value);
          }}
        />
        <br />

        <motion.button
          type="submit"
          className="h-14 w-4/5 mb-4 p-2 border border-gray-300 bg-blue-400 rounded-xl">
          Register
        </motion.button>
      </form>
    </div>
  );
}
