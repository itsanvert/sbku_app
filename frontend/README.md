<<<<<<< HEAD
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

</div>
=======
# 📱 SBKU App  
**Samdech Preah Mahasangharajah Bour Kry University Mobile Application**

SBKU App is a mobile-first attendance management system designed to modernize and simplify academic attendance at **Samdech Preah Mahasangharajah Bour Kry University (SBKU)**.

The application enables students, professors, and administrative staff to efficiently track, manage, and review attendance data using mobile devices, reducing manual work and improving data accuracy.

---

## ✨ Key Features

- 📌 **Mobile-Based Attendance Tracking**  
  Record and manage attendance directly from mobile devices.

- 📊 **Automated Attendance Reports**  
  Generate reports by:
  - Daily
  - Monthly
  - Yearly

- 👥 **Role-Based Access Control**  
  Customized access for:
  - Students
  - Professors
  - Administrative Staff

- 🏫 **University-Focused System**  
  Built specifically for higher education environments.

- ⚡ **Efficient & Accurate**  
  Reduces human error, saves time, and improves record organization.

---

## 👤 User Roles & Capabilities

### 🎓 Students
- View personal attendance records
- Track attendance status over time

### 👨‍🏫 Professors
- Take and manage class attendance
- Review attendance summaries by course

### 🧑‍💼 Staff / Administration
- Monitor overall attendance data
- Access detailed attendance reports
- Support academic and administrative operations

---

## 🎯 Objectives

- Replace manual attendance systems with a mobile-first solution
- Improve accuracy and reliability of attendance data
- Reduce administrative workload
- Provide real-time access to attendance information

---

## 🎨 UI/UX Design

The application interface is designed to be **simple, modern, and role-based**.

🔗 **Figma Design Preview**  
https://www.figma.com/design/yr1tZ56H8VI9erP0AdJ9wk/SBKU_APP

---

## 🚧 Development Progress & Preview Links

### 📐 Design
- ✅ UI/UX Design Completed
- ⏳ UX Improvements (In Review)

🔗 Design Preview  
https://www.figma.com/design/yr1tZ56H8VI9erP0AdJ9wk/SBKU_APP

---

### 🛠️ Development
- ⏳ Backend Development (Planned / In Progress)
- ⏳ Mobile Application Development
- ⏳ API Integration

🔗 Source Code Repository  
_Private / Academic Use_

---

### 📱 App Preview (Coming Soon)
- 🎥 Demo Video  
  (Coming Soon)

- 📲 Android APK  
  (Internal Testing)

- 🍎 iOS TestFlight  
  (Internal Testing)

---

### 🗺️ Roadmap
- Phase 1: Core Attendance Features
- Phase 2: Reports & Analytics
- Phase 3: Notifications & Optimization
- Phase 4: Deployment & University Rollout

---

## 🚀 Benefits

- Faster attendance processing
- Centralized and secure data storage
- Improved transparency for students and faculty
- Better insights for academic planning

---

## 📌 Project Status

- UI/UX Design: ✅ Completed  
- Development: ⏳ In Progress / Planned  
- Testing: ⏳ Upcoming  
- Deployment: ⏳ Planned  

---

## 📄 License

This project is developed for **academic and institutional use** at  
**Samdech Preah Mahasangharajah Bour Kry University (SBKU)**.

---

## 🤝 Contributors

- **Project Manager & Full Stack Developer**  
  - Vert San

- **Mobile Application Developer**  
  - Chhaom Sovanarak

- **Mobile Application Developer & UI/UX Designer**  
  - Horng Sina

- **Mobile Application Developer**  
  - Yun Yuna

---

**SBKU App — Smarter Attendance for a Smarter University 🎓**
>>>>>>> cecf32289ef5cf76f6d38ba83b916ecae0df8554
