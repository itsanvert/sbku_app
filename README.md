# SBKU App

<div align="center">

![Laravel](https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

**A full-stack application for scalable syllabus management**

[Features](#-features) • [Quick Start](#-quick-start) • [Troubleshooting](#️-troubleshooting--theme-support) • [Contributing](#-contributing)

</div>

---

## 📖 Overview

SBKU App is a modern full-stack application built with a Laravel backend and Flutter mobile application. It's designed for efficient syllabus management with robust API-based communication, providing a seamless experience across platforms.

## 📋 Tech Stack

### Backend
- **[Laravel](https://laravel.com/)** - PHP framework for robust web applications
- **Laravel Jetstream** - Authentication and team management scaffolding
- **REST API** - RESTful API architecture for mobile integration
- **PostgreSQL / MySQL** - Relational database (supports Neon database cloud and local MySQL)

### Frontend
- **[Flutter](https://flutter.dev/)** - Cross-platform mobile framework
- **Dart** - Modern programming language optimized for UI development

## ✨ Features

- 📚 **Syllabus Management** - Complete CRUD operations with intuitive interface
- 🔌 **REST API** - Full API integration for seamless Flutter app communication
- 🔐 **Secure Authentication** - JWT-based authentication with Laravel Jetstream
- 🏗️ **Scalable Architecture** - Clean, maintainable, and modular codebase
- ⚙️ **Environment Configuration** - Flexible configuration for different environments
- 📱 **Cross-Platform** - Single codebase for iOS and Android
- 🎨 **Responsive UI** - Adaptive design for various screen sizes

## 📁 Project Structure

```
sbku_app/
├── backend/                 # Laravel backend application
│   ├── app/                # Application core
│   ├── config/             # Configuration files
│   ├── database/           # Migrations and seeders
│   ├── routes/             # API and web routes
│   └── tests/              # Backend tests
├── frontend/               # Flutter mobile application
│   ├── lib/                # Dart source code
│   │   ├── config/         # App configuration
│   │   ├── models/         # Data models
│   │   ├── screens/        # UI screens
│   │   ├── services/       # API services
│   │   └── widgets/        # Reusable widgets
│   └── test/               # Flutter tests
└── README.md               # Project documentation
```

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have the following installed:

- **PHP** >= 8.1
- **Composer** >= 2.0
- **PostgreSQL** or **MySQL**
- **Flutter** >= 3.0
- **Dart** >= 3.0

### Backend Setup (Laravel)

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Install PHP dependencies**
   ```bash
   composer install
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

4. **Configure database**
   
   Update your `.env` file with database credentials.
   For PostgreSQL:
   ```env
   DB_CONNECTION=pgsql
   DATABASE_URL="your-postgresql-connection-string"
   ```
   
   For MySQL:
   ```env
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=sbku_db
   DB_USERNAME=root
   DB_PASSWORD=
   ```

5. **Run database migrations**
   ```bash
   php artisan migrate
   ```

6. **Start development server**
   ```bash
   php artisan serve --port 8000
   ```

   The backend will be available at `http://localhost:8000`

### Frontend Setup (Flutter)

1. **Navigate to Flutter directory**
   ```bash
   cd frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   
   Update `lib/config/api_config.dart` with your backend URL:
   ```dart
   const String baseUrl = 'http://localhost:8080/api';
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 🛠️ Troubleshooting & Theme Support

### Livewire `MultipleRootElementsDetectedException`
If you encounter `Livewire only supports one HTML element per component. Multiple root elements detected` errors:
- Ensure none of the Blade view files or components contain a UTF-8 BOM (`\xef\xbb\xbf`) at the very start of the file. UTF-8 BOMs output white-space bytes before the first HTML element, causing Livewire's root element parser to fail.
- Strip any UTF-8 BOM from your views, then clear the compiled views:
  ```bash
  php artisan view:clear
  ```

### Light/Dark Mode Styling
The application UI supports fully dynamic Light and Dark mode options:
- Dashboard widgets, static glassmorphic cards (`.glass-card-static`, `.glass-card`), and count cards (`.stat-card`) automatically toggle backgrounds and text colors responsively when the `dark` class is set on the root `<html>` element.
