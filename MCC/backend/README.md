# Advanced Hierarchical Admin API with Django & Next.js

This project is a full-stack application featuring a powerful Django REST Framework backend and a Next.js frontend. It provides a secure, multi-tenant authentication system with hierarchical permissions based on administrative layers and license keys.

The system is designed for scenarios where a top-level administrator (Layer 0) can create sub-administrators, who can in turn create their own sub-administrators, forming a network or "family tree." All data, including users, servers, and devices, is strictly isolated based on the top-level admin's license key.

## Features

- **Secure JWT Authentication:** Uses `HttpOnly` cookies for secure, stateless authentication.
- **Session Management:** Robust frontend session management with automatic token refreshing and user session restoration on page reload.
- **Hierarchical Admin Structure:** Admins are organized into layers, where an admin at Layer `N` can only create new admins at Layer `N+1`.
- **License Key Activation:** New Layer 0 admins must activate their account with a pre-generated license key before they can perform any actions.
- **Multi-Tenancy & Data Isolation:** All data (Admins, Users, Servers, Devices) is scoped to a license key. An admin can only ever see or interact with data belonging to their own license network.
- **Network-Based Filtering:** Admins can only view the users, sub-admins, and hardware that belong to their direct network hierarchy.
- **Full CRUD API:** Comprehensive API endpoints for managing servers and devices.

---

## Tech Stack

- **Backend:** Python, Django, Django REST Framework, Simple JWT
- **Frontend:** TypeScript, React, Next.js, Axios, Zustand
- **Database:** PostgreSQL (recommended) / SQLite (development)

---

## Setup and Installation

### Backend (Django)

1.  **Clone the repository:**

    ```bash
    git clone <your-repo-url>
    cd <your-repo-name>/backend
    ```

2.  **Create and activate a virtual environment:**

    ```bash
    python -m venv virt
    source virt/bin/activate  # On Windows: virt\Scripts\activate
    ```

3.  **Install dependencies:**

    ```bash
    pip install -r requirements.txt   .
    ```

4.  **Run database migrations:**

    ```bash
    python manage.py makemigrations
    python manage.py migrate
    ```

5.  **Create a superuser (optional, for admin panel):**

    ```bash
    python manage.py createsuperuser
    ```

6.  **Create License Keys:**

    - Run the server, log in to the Django Admin panel at `http://localhost:8000/admin/`.
    - Navigate to "License Keys" and add a few new keys for testing.

7.  **Run the development server:**

    ```bash
    python manage.py runserver localhost:8000
    ```

### Frontend (Next.js)

1.  **Navigate to the frontend directory:**

    ```bash
    cd ../frontend # From the backend directory
    ```

2.  **Install dependencies:**

    ```bash
    npm install
    ```

3.  **Run the development server:**

    ```bash
    npm run dev
    ```

    The application will be available at `http://localhost:3000`.

---

## API Endpoint Documentation

The base URL for all endpoints is `http://localhost:8000/api`.

### Public & Authentication

| Endpoint             | Method | Permissions       | Description                                                  | Sample Body                                                                |
| -------------------- | ------ | ----------------- | ------------------------------------------------------------ | -------------------------------------------------------------------------- |
| `/register/`         | `POST` | `AllowAny`        | Registers a new Layer 0 Admin.                               | `{"username": "u", "email": "e@e.com", "password": "p", "password2": "p"}` |
| `/login/`            | `POST` | `AllowAny`        | Logs in an admin and returns JWTs in `HttpOnly` cookies.     | `{"username": "u", "password": "p"}`                                       |
| `/logout/`           | `POST` | `IsAuthenticated` | Logs out the user and deletes cookies.                       | (Empty)                                                                    |
| `/token/refresh/`    | `POST` | (Cookie)          | Uses the `refresh_token` cookie to get a new `access_token`. | (Empty)                                                                    |
| `/license/activate/` | `POST` | `IsAuthenticated` | Allows a Layer 0 admin to activate their license.            | `{"key": "your-license-key-string"}`                                       |

### Profile & Network Management

| Endpoint                  | Method  | Permissions                          | Description                                       | Sample Body                                                                            |
| ------------------------- | ------- | ------------------------------------ | ------------------------------------------------- | -------------------------------------------------------------------------------------- |
| `/profile/`               | `GET`   | `IsAuthenticated`, `IsLicenseActive` | Get the profile of the logged-in admin.           | -                                                                                      |
| `/profile/`               | `PATCH` | `IsAuthenticated`, `IsLicenseActive` | Update the profile of the logged-in admin.        | `{"email": "new@email.com", "password": "new_pass"}`                                   |
| `/network/admins/`        | `GET`   | `IsAuthenticated`, `IsLicenseActive` | List all sub-admins within the user's network.    | -                                                                                      |
| `/network/users/`         | `GET`   | `IsAuthenticated`, `IsLicenseActive` | List all users within the user's license network. | -                                                                                      |
| `/network/admins/create/` | `POST`  | `IsAuthenticated`, `IsLicenseActive` | Create a new sub-admin (must be at layer `N+1`).  | `{"username": "u", "email": "e@e.com", "password": "p", "password2": "p", "layer": 1}` |
| `/network/users/create/`  | `POST`  | `IsAuthenticated`, `IsLicenseActive` | Create a new user in the network.                 | `{"username": "u", "email": "e@e.com"}`                                                |

### Server & Device Management

| Endpoint         | Method                   | Permissions                          | Description                                                           |
| ---------------- | ------------------------ | ------------------------------------ | --------------------------------------------------------------------- |
| `/servers/`      | `GET`, `POST`            | `IsAuthenticated`, `IsLicenseActive` | List all servers in the license network, or create a new one.         |
| `/servers/{id}/` | `GET`, `PATCH`, `DELETE` | `IsAuthenticated`, `IsLicenseActive` | Retrieve, update, or delete a specific server in the license network. |
| `/devices/`      | `GET`, `POST`            | `IsAuthenticated`, `IsLicenseActive` | List all devices in the license network, or create a new one.         |
| `/devices/{id}/` | `GET`, `PATCH`, `DELETE` | `IsAuthenticated`, `IsLicenseActive` | Retrieve, update, or delete a specific device in the license network. |
