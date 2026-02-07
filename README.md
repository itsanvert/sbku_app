# SBKU App

SBKU App is a **full-stack mobile application** designed for syllabus management and academic tracking.  
It features a modern **Laravel** REST API backend and a clean **Flutter** mobile frontend.

https://github.com/vertsan/sbku_app

## Tech Stack

| Layer      | Technology              | Purpose                              |
|------------|-------------------------|--------------------------------------|
| Backend    | Laravel 10/11           | RESTful API, authentication, business logic |
| Auth       | Laravel Jetstream       | Secure user authentication & session management |
| Frontend   | Flutter (Dart)          | Cross-platform mobile app (Android + iOS) |
| Storage    | flutter_secure_storage  | Secure token & credential storage    |
| API Client | http / dio (recommended)| HTTP requests from Flutter           |
| Database   | MySQL / MariaDB / SQLite| (configurable via Laravel .env)      |

## Features

- User authentication (register, login, logout, password update)
- Profile management (update name/email, upload/delete profile photo)
- Syllabus viewing and management
- Clean REST API endpoints
- Secure token-based authentication (Laravel Sanctum / Jetstream)
- Environment-based configuration
- Refactored & cleaned codebase
- Removed unnecessary assets and boilerplate

## Project Structure
