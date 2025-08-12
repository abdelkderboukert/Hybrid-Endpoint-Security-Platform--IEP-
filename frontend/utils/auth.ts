// frontend/utils/api.ts

import axios from "axios";

const API_URL = "http://127.0.0.1:8000/api/";
// Define protected API paths
const PROTECTED_PATHS = ["admin/"]; // Add any other protected endpoints here

const axiosInstance = axios.create({
  baseURL: API_URL,
  withCredentials: true,
});

axiosInstance.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    const requestPath = originalRequest.url; // Check if the request is for a protected path

    const isProtectedRoute = PROTECTED_PATHS.some((path) =>
      requestPath.includes(path)
    );

    if (
      error.response?.status === 401 &&
      isProtectedRoute &&
      !originalRequest._retry
    ) {
      originalRequest._retry = true;

      try {
        const refreshResponse = await axios.post(
          `${API_URL}token/refresh/`,
          null,
          { withCredentials: true }
        );

        if (refreshResponse.status === 200) {
          return axiosInstance(originalRequest);
        }
      } catch (refreshError) {
        console.error("Refresh token expired. Redirecting to login.");
        window.location.href = "/login";
        return Promise.reject(refreshError);
      }
    }
    return Promise.reject(error);
  }
);

// Functions for API calls
export const registerUser = async (
  email: string,
  username: string,
  password: string
) => {
  const response = await axios.post(`${API_URL}register/`, {
    email,
    username,
    password,
  });
  return response.data;
};

export const loginUser = async (email: string, password: string) => {
  const response = await axios.post(`${API_URL}login/`, { email, password });
  return response.data;
};

export const logoutUser = async () => {
  const response = await axios.post(`${API_URL}logout/`, null, {
    withCredentials: true,
  });
  return response.data;
};

export const getUserInfo = async () => {
  const response = await axiosInstance.get("user-info/");
  return response.data;
};
