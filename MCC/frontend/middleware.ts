// middleware.ts
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(request: NextRequest) {
  // Get the refresh token cookie
  const refreshToken = request.cookies.get("refresh_token")?.value;

  // Define protected paths using a regex
  const protectedPathRegex = /^\/admin\/[^/]+\/.*/;

  // Check if the current path is protected
  if (protectedPathRegex.test(request.nextUrl.pathname)) {
    // If there is no refresh token, the user is not logged in
    if (!refreshToken) {
      // Redirect to the login page
      const url = request.nextUrl.clone();
      url.pathname = "/login";
      return NextResponse.redirect(url);
    }
  }

  // Allow the request to proceed if it's not a protected path
  // or if the user has a refresh token
  return NextResponse.next();
}

// See "Matching Paths" below to learn more
export const config = {
  // Match all paths except for static files and the API routes
  matcher: ["/((?!api|_next/static|_next/image|favicon.ico).*)"],
};
