# task_manager_app

📌 Task Manager App (Flutter + Back4App)
📖 Overview

Task Manager is a Flutter-based mobile application designed for students to efficiently manage their daily tasks.
The app integrates with Back4App (Parse Server) for:

User authentication

Secure cloud data storage

Real-time task synchronization

Students can register using their student email ID, manage their tasks, and access them anytime from the cloud.

✨ Key Features
1. User Authentication

Register and login using student email ID

Credentials stored securely in Back4App

Session management with secure logout

2. Task Management (CRUD Operations)

Add new tasks

View all tasks

Edit existing tasks

Delete tasks

Tasks are linked to the logged-in user

Stored in Back4App Cloud Database

3. Real-Time Cloud Sync

All task updates instantly synced with Parse Server

User-specific task storage

🛠️ Technology Stack
Component	Technology Used
Frontend	Flutter (Dart)
Backend	Back4App (Parse Server)
Database	Back4App Cloud Database
Version Control	GitHub
Hosting (Development)	Local device / Emulator

⚙️ Setup Instructions
1. Install Dependencies
flutter pub get

2. Configure Back4App

Replace credentials in:

lib/services/parse_service.dart


Add:

Application ID

Client Key

Parse Server URL

(Get these from Back4App → App Settings → Security & Keys)


3. Run the Application
flutter run

