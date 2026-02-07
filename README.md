# SBKU App

<div align="center">

![Laravel](https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

**A full-stack application for scalable syllabus management**

[Features](#-features) • [Quick Start](#-quick-start) • [API Documentation](#-api-integration) • [Contributing](#-contributing)

</div>

---

## 📖 Overview

SBKU App is a modern full-stack application built with a Laravel backend and Flutter mobile application. It's designed for efficient syllabus management with robust API-based communication, providing a seamless experience across platforms.

## 📋 Tech Stack

### Backend
- **[Laravel](https://laravel.com/)** - PHP framework for robust web applications
- **Laravel Jetstream** - Authentication and team management scaffolding
- **REST API** - RESTful API architecture for mobile integration
- **MySQL** - Relational database management system

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
├── flutter_app/            # Flutter mobile application
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
- **MySQL** >= 8.0
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
   
   Update your `.env` file with database credentials:
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
   php artisan serve --port=8080
   ```

   The backend will be available at `http://localhost:8080`

### Frontend Setup (Flutter)

1. **Navigate to Flutter directory**
   ```bash
   cd flutter_app
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

   For specific platforms:
   ```bash
   # Run on Android
   flutter run -d android
   
   # Run on iOS
   flutter run -d ios
   
   # Run on Web
   flutter run -d chrome
   ```

## 🔌 API Integration

The Laravel backend provides RESTful APIs consumed by the Flutter application:

| Component | Details |
|-----------|---------|
| **Base URL** | Configurable via environment (default: `http://localhost:8080/api`) |
| **Authentication** | JWT-based with Laravel Jetstream |
| **Format** | JSON |
| **Endpoints** | Syllabus CRUD, user authentication, profile management |

### Example API Endpoints

```
GET    /api/syllabi           # List all syllabi
POST   /api/syllabi           # Create new syllabus
GET    /api/syllabi/{id}      # Get specific syllabus
PUT    /api/syllabi/{id}      # Update syllabus
DELETE /api/syllabi/{id}      # Delete syllabus
POST   /api/auth/login        # User login
POST   /api/auth/register     # User registration
```

## 📱 Flutter App Features

- ✅ **Cross-Platform** - Single codebase for iOS, Android, and Web
- ✅ **Responsive Design** - Adaptive UI for phones, tablets, and desktops
- ✅ **API Integration** - Seamless communication with Laravel backend
- ✅ **State Management** - Efficient state handling with Provider/Riverpod
- ✅ **Offline Support** - Local caching for improved performance
- ✅ **Material Design** - Modern UI following Material Design 3 guidelines

## 🔧 Development Notes

- ✨ Codebase refactored and cleaned for optimal maintainability
- 🗑️ Unnecessary assets and dependencies removed
- 📝 Git configuration included for version control
- 🎯 Follows Laravel and Flutter best practices
- 📐 Modular architecture for easy scalability
- 🔍 Comprehensive error handling and logging

## 📚 Documentation

- **Backend API Documentation**: Available at `/api/documentation` when running the Laravel server
- **Flutter Code Structure**: Organized following Flutter best practices and clean architecture
- **Database Schema**: Detailed migrations available in `backend/database/migrations/`

## 🧪 Testing

### Backend Tests

```bash
cd backend
php artisan test
```

Run specific test suites:
```bash
# Feature tests
php artisan test --testsuite=Feature

# Unit tests
php artisan test --testsuite=Unit
```

### Flutter Tests

```bash
cd flutter_app
flutter test
```

Run with coverage:
```bash
flutter test --coverage
```

## 🛠️ Built With

- [Laravel](https://laravel.com/) - The PHP Framework for Web Artisans
- [Flutter](https://flutter.dev/) - Build apps for any screen
- [MySQL](https://www.mysql.com/) - The world's most popular open source database
- [Laravel Jetstream](https://jetstream.laravel.com/) - Authentication scaffolding
- [Dart](https://dart.dev/) - Client-optimized programming language

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📧 Contact

Project Link: [https://github.com/yourusername/sbku_app](https://github.com/yourusername/sbku_app)

---

<div align="center">

**Made with ❤️ for education management**

</div>
