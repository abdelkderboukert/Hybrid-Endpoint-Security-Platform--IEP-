// pages/login.tsx
"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/Context/AuthContext";
import { User } from "@/types/auth";

const LoginPage = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const { login } = useAuth();
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
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
    <div className="">
      <form onSubmit={handleSubmit}>
        <h2>Login</h2> {error && <p style={{ color: "red" }}>{error}</p>}
        {isLoading && <p>Logging in...</p>}
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="Email"
          disabled={isLoading}
        />
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password"
          disabled={isLoading}
        />
        <button type="submit" disabled={isLoading}>
        Login
        </button>
      </form>
    </div>
  );
};

export default LoginPage;
