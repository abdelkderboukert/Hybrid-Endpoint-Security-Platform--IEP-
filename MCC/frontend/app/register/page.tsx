"use client"
import React from "react";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { registerUser } from "@/utils/auth";

export default function RegisterPage() {
    const [userName, setUserName] = useState("")
    const [password, setPassword] = useState("")
    const [email, setEmail] = useState("")
    const router = useRouter();

    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault()
        if(userName==="" || password==="" || email==="") {
            return
        }
        try {
            await registerUser(email, userName, password)
            alert("Yay! It worked! User Created!")
            router.push("/login"); 
        }
        catch (e) {
            alert("OOps!")
            console.error("Registration error:", e);
        }
      
    }
	return (
		<div className="min-h-screen bg-gray-100 items-center flex flex-col justify-center">
            <form onSubmit={handleSubmit} className="bg-gray-600 p-8 flex flex-col rounded-lg"> 
				<label>Username</label>

				<input className="text-gray-600" type="text" value={userName} required
                onChange={(e)=>{setUserName(e.target.value)}}/>
				<br />

				<label>Email</label>
				<input className="text-gray-600" type="email" value={email} required 
                onChange={(e)=>{setEmail(e.target.value)}}/>
				<br />

				<label>Password</label>
				<input className="text-gray-600" type="password" value={password} required 
                onChange={(e)=>{setPassword(e.target.value)}}/>
				<br />

				<button
                className="bg-blue-400 p-1 rounded-sm"
                type="submit">Register</button>
			</form>
		</div>
	);
}