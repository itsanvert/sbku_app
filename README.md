SBKU App

SBKU App is a full-stack application built with a Laravel backend and a Flutter mobile application. The project is structured for scalability and maintainability, with a focus on syllabus management and API-based communication.

Tech Stack

Backend

Laravel

Laravel Jetstream

REST API

Frontend

Flutter

Features

Syllabus model and view implementation

REST API for Flutter integration

Laravel Jetstream authentication

Environment-based configuration

Refactored and cleaned codebase

Project Structure
sbku_app/
├── backend/        # Laravel backend
├── frontend/    # Flutter mobile application
└── README.md

Setup
Backend (Laravel)
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve --port=8080

Frontend (Flutter)
cd flutter_app
flutter pub get
flutter run

API

Laravel provides REST APIs consumed by the Flutter app

API base URL is configurable via environment variables

Notes

Codebase has been refactored and cleaned

Unnecessary assets removed

Git configuration included

License

For development and educational use.
