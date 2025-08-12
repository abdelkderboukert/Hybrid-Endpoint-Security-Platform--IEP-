// frontend/Context/AuthContext.tsx
"use client";

import {
  createContext,
  useContext,
  useState,
  useEffect,
  ReactNode,
} from "react";
import { User, AuthContextType } from "../types/auth";
import { getUserInfo, logoutUser, loginUser } from "../utils/auth";

const AuthContext = createContext<AuthContextType | null>(null);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    const checkAuthStatus = async () => {
      try {
        // Attempt to get user info. The Axios interceptor will handle the refresh if needed.
        const userData = await getUserInfo();
        setUser(userData as User);
        
      } catch (e) {
        // If it fails, the user is not authenticated.
        setUser(null);
        console.error("Failed to fetch user info:", e);
      } finally {
        setLoading(false);
      }
    };
    checkAuthStatus();
  }, []);

  const login = async (email: string, password: string) => {
    try {
      const data = await loginUser(email, password);
      setUser(data.user as User);
      return data.user;
    } catch (e) {
      setUser(null);
      
      //@ts-expect-error this is to handle the error type
      throw new Error(e.response?.data?.detail || "Login failed");
    }
  };

  const logout = async () => {
    try {
      await logoutUser();
      setUser(null);
    } catch (e) {
      setUser(null);
      console.error("Logout failed:", e);
      throw new Error("Logout failed");
    }
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};
