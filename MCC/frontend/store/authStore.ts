// store/authStore.ts
import { create } from "zustand";
import { jwtDecode } from "jwt-decode";

interface User {
  username: string;
  email: string;
  admin_id: string;
}

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  setUser: (token: string | null) => void;
  logout: () => void;
}

// Function to get user data from a token
const getUserFromToken = (token: string): User | null => {
  if (!token) return null;
  try {
    const decoded: { username: string; email: string; user_id: string } =
      jwtDecode(token);
    return {
      username: decoded.username,
      email: decoded.email,
      admin_id: decoded.user_id,
    };
  } catch (error) {
    console.error("Invalid token", error);
    return null;
  }
};

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: false,
  setUser: (token: string | null) => {
    if (token) {
      const userData = getUserFromToken(token);
      if (userData) {
        set({ user: userData, isAuthenticated: true });
      } else {
        set({ user: null, isAuthenticated: false });
      }
    } else {
      set({ user: null, isAuthenticated: false });
    }
  },
  logout: () => {
    // Note: The actual cookie clearing is done by the backend on the /logout endpoint
    set({ user: null, isAuthenticated: false });
  },
}));
