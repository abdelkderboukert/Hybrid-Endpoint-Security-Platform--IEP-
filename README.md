Project: Distributed Enterprise Security (D-SEC)
Project Overview
D-SEC (Distributed Security) is a comprehensive, multi-layered security solution designed to protect complex enterprise networks. The system combines the power of centralized cloud management with the flexibility of local control, ensuring continuous security even in offline environments. This project aims to deliver an integrated model that covers threat detection, automated response, and data integrity through a clear, hierarchical structure.

Core Architectural Model
The system is built on a three-level hierarchical architecture:

Cloud Controller: The central hub for global management. It is controlled by a Global Admin (Layer 0).

Local Server Controller: An on-premises server that manages a specific local network. It is controlled by a Local Admin (Layer 1).

Sub-Local Server Controller: An optional layer that controls smaller sub-networks. It is controlled by a Sub-Local Admin (Layer N).

Endpoint Agent: The antivirus software installed on each device, serving as the first line of defense.

Key Features

1. Core Security & Threat Detection
   Real-Time Protection Engine: Operates at the kernel-level to continuously monitor system activity, file systems, and memory.

Dual Threat Detection: Combines signature-based detection for known threats (by integrating an open-source engine) with behavioral and heuristic analysis to catch new (zero-day) threats.

Remediation & Quarantine: The ability to move infected files to a secure, isolated location or to delete them.

2. Hierarchical Management and Control
   Role-Based Access Control (RBAC):

Global Admin (Layer 0): Controls the entire system and creates local admins.

Admin (Layer N): Controls only a single server and can create sub-admins and users for lower layers (N+1).

Users: Have access to devices only and cannot create any other accounts.

Multi-Tenancy License System: Each network operates under a unique license, ensuring complete data isolation.

Visibility & Control Scoping: An admin at Layer N can only see and manage devices and accounts within their network and those of their direct descendants. They cannot see data belonging to other admins at the same or different layers.

Policy Management: Admins can create, enforce, and run policies on their controlled devices, similar to how Windows Server functions.

Automated Server Discovery & Failover: New servers can automatically announce their presence on the network, and in case of a connection failure with their parent server, they can communicate directly with the Cloud Controller.

3. Advanced Features & Intelligent Response
   Automated Device Isolation: Upon detecting a critical threat, the endpoint agent automatically isolates the device from the network via the firewall, while keeping the communication channel to the managing server open.

Proactive Correlated Threat Scanning: When a device is isolated, the controller automatically sends a command to all other devices in the network to scan for the same specific threat, preventing its spread.

Advanced Data Integrity Feature:

A blockchain-like system to ensure data has not been tampered with.

Critical data files are hashed and digitally signed; any unauthorized change will result in a hash mismatch, flagged as a threat.

User Monitoring: Captures the current user's name and an image (via webcam) during a critical security event.

4. Synchronization and Offline-First Functionality
   The system features a robust and resilient synchronization mechanism:

Unified Bi-Directional Sync: A single API endpoint (MasterSyncAPIView) handles both uploading local changes to the cloud and downloading the latest updates from the cloud in a single transaction.

Offline-First: Admins and users can make changes to their local databases while disconnected from the network.

"Resilient Chain of Command" Algorithm:

Sync Up: Changes flow up the chain from lower layers to the Cloud.

Sync Down: Authoritative updates from the Cloud cascade down the hierarchy to ensure data consistency across all devices.

Unique ID Management: Temporary IDs are assigned to records created offline and are replaced with permanent, authoritative IDs from the Cloud upon successful synchronization.

Conflict Resolution: The system intelligently merges conflicting changes, using either field-level merging or a "last-write-wins" approach based on the timestamp.

Technology Stack
Backend: Django (Python).

Secure authentication using JWTs with HttpOnly cookies.

Custom permission classes for enforcing license rules.

Clean, reusable code with LicenseScopeMixin and ViewSets.

Frontend: Next.js (React).

Automatic session management and token refreshing.

Protected routes using Next.js Middleware.

Global state management with Zustand.

Local Server Apps: Flutter (Dart) for offline functionality.

Database: PostgreSQL.

Database Schema
The system uses several interconnected tables to organize data:

Admins: Manages the hierarchical admin structure.

Servers: Tracks all servers (cloud, local, sub-local).

Devices: Stores endpoint device information.

Users: User information for the final users.

Policies: Stores security policies.

Threats: Logs all detected threats.

User_Photos: Stores captured user images.

Data_Integrity_Log: Logs data changes for the integrity feature.
