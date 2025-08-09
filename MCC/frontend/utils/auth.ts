import axios from "axios";

const API_URL = "http://127.0.0.1:8000/api/users/";

export const registerUser = async (email:string, username:string, password:string) => {
    try {
        const response = await axios.post(`${API_URL}register/`, {email, username, password},
            {withCredentials: true}
        )
        return response.data;
    }
    catch (e) {
        throw new Error("Registration failed!");
        console.error("Registration error:", e);
    }

}
    


export const loginUser = async (email:string, password:string) => {
    try {
        const response = await axios.post(`${API_URL}login/`, {email, password},
            {withCredentials: true}
        )
        return response.data;
    }
    catch (e) {
        throw new Error("Login failed!");
        console.error("Registration error:", e);
    }
}
    


export const logoutUser = async () => {
    try {
        const response = await axios.post(`${API_URL}logout/`, null,
            {withCredentials: true}
        )
        return response.data;
    }
    catch (e) {
        throw new Error("Logout failed!");
        console.error("Registration error:", e);
    }
    
}


export const getUserInfo = async () => {
    try {
        const response = await axios.get(`${API_URL}user-info/`,
            {withCredentials: true}
        )
        return response.data;
    }
    catch (e) {
        throw new Error("Getting user failed!");
        console.error("Registration error:", e);
    }
    
}

export const refreshToken = async () => {
    try {
        const response = await axios.post(`${API_URL}refresh/`, null,
            {withCredentials: true}
        )
        return response.data;
    }
    catch (e) {
        throw new Error("Refreshing token failed!");
        console.error("Registration error:", e);
    }
    
}