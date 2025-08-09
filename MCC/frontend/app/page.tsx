"use client";
import { logoutUser, getUserInfo, refreshToken } from "../utils/auth";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";

interface User {
  username: string;
  email: string;
  // other properties
}

export default function Home() {
	const [user, setUser] = useState<User>();
	const router = useRouter();
	useEffect(() => {
		const getUser = async () => {
			const userDetails = await getUserInfo();
			if (userDetails) {
				setUser(userDetails);
			}
      else{
      }
		};
		getUser();
	}, []);

	

	const handleLogout = async () => {
		await logoutUser();
    router.push("/login"); 
	};

  const handleRefresh = async () => {
    await refreshToken();
  }
	return (
		<div className="min-h-screen bg-gray-100 items-center flex flex-col justify-center">
			<div className="bg-gray-600 p-8 flex flex-col rounded-lg">
			{user ? <h1>Hi, {user.username}</h1> : <h1>Welcome stranger!</h1>}

			<button className="bg-blue-400 p-1 rounded-sm m-1" onClick={handleLogout}>Logout</button>
			
			<button className="bg-blue-400 p-1 rounded-sm m-1" onClick={handleRefresh}>refresh token</button>
			</div>
		</div>
	);
}