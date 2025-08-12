// types/auth.ts
export interface User {
  admin_id: string;
  username: string;
  email: string;
  layer?: number;
  server_id?: string | null;
  is_active?: boolean;
}

export interface AuthContextType {
  user: User | null;
  login: (username: string, password: string) => Promise<void>;
  logout: () => void;
  loading: boolean;
}
