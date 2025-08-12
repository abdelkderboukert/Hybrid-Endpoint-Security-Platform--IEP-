// lib/axios.ts
import axios from "axios";

const axiosInstance = axios.create({
  baseURL: "http://localhost:8000/api", // Your Django API URL
  withCredentials: true, // Important for sending cookies
});

// We don't need interceptors for request because cookies are sent automatically.
// However, we need one for the response to handle token refresh.

axiosInstance.interceptors.response.use(
  (response) => response, // Directly return successful responses
  async (error) => {
    const originalRequest = error.config;

    // Check if the error is 401 and it's not a retry request
    if (error.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true; // Mark it as a retry

      try {
        // Call the refresh token endpoint
        await axiosInstance.post("/token/refresh/");
        // The cookies (new access and refresh tokens) are automatically updated by the backend.
        // Now, retry the original request with the new token.
        return axiosInstance(originalRequest);
      } catch (refreshError) {
        // If refresh fails, redirect to login or handle logout
        console.error("Token refresh failed", refreshError);
        window.location.href = "/login"; // Or use a more sophisticated logout function
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default axiosInstance;
