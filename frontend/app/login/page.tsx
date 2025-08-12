// pages/login.tsx
"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/Context/AuthContext";
import { User } from "@/types/auth";
import Link from "next/link";
import { motion } from "framer-motion";

const LoginPage = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  // const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const { login } = useAuth();
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    // setError("");
    setIsLoading(true);

    try {
      // Await the user data from the login function
      //@ts-expect-error this is to handle the error type
      const user: User = await login(email, password); // Use the user's ID to construct the dynamic URL
      router.push(`/admin/${user.admin_id}/dashboard`);
    } catch (error) {
      console.error("Login error:", error); // @ts-expect-error this is to handle the error type
      setError(error.message || "Login failed. Please check your credentials.");
    } finally {
      setIsLoading(false);
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
        onSubmit={handleSubmit}
        className="bg-white shadow-xl w-3/8 h-max p-8 flex flex-col justify-center items-center rounded-lg"
      >
        <div className="h-8 w-4/5 flex justify-start items-end text-black/50 text-sm mb-1">
          Email
        </div>
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          // placeholder="Email"
          disabled={isLoading}
          className="h-14 w-4/5 mb-4 p-2 border border-gray-300 text-blue-300 rounded-xl"
        />
        <div className="h-8 w-4/5 flex justify-start items-end text-black/50 text-sm mb-1">
          Password
        </div>
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          // placeholder="Password"
          disabled={isLoading}
          className="h-14 w-4/5 mb-4 p-2 border border-gray-300 text-blue-300 rounded-xl"
        />
        <div className="h-8 w-4/5 flex justify-start items-center text-blue-500 mb-5 font-bold">
          Forgot your password?
        </div>
        <motion.button
          type="submit"
          className="h-14 w-4/5 mb-4 p-2 border border-gray-300 bg-blue-400 rounded-xl"
          disabled={isLoading}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          Login
        </motion.button>
      </form>
    </div>
  );
};

export default LoginPage;
