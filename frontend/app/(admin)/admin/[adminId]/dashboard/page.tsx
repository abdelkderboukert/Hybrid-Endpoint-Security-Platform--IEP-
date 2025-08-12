// frontend/app/(admin)/[user_id]/dashboard/page.tsx
"use client";

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/Context/AuthContext';

export default function DashboardPage() {
    const { user, loading, logout } = useAuth();
    const router = useRouter();

    useEffect(() => {
        // This effect runs after the AuthContext has finished loading.
        // It checks if the user is authenticated.
        if (!loading && !user) {
            // Redirect to the login page only if loading is complete and no user is found.
            router.push("/login");
        }
    }, [loading, user, router]);

    // Show a loading state while the authentication check is in progress.
    if (loading) {
        return (
            <div className="flex justify-center items-center h-screen">
                <p>Loading user data...</p>
            </div>
        );
    }

    // If the user object is null after loading, the redirect has already been handled.
    if (!user) {
        return null;
    }

    // If the user is authenticated, render the dashboard content.
    return (
        <div className="min-h-screen bg-gray-100 items-center flex flex-col justify-center">
            <div className="bg-gray-600 p-8 flex flex-col rounded-lg">
                <h1>Hi, {user.username}</h1>
                <button
                    className="bg-blue-400 p-1 rounded-sm m-1"
                    onClick={logout}
                >
                    Logout
                </button>
            </div>
        </div>
    );
}