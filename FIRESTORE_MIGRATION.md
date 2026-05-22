# Firestore Migration Guide

This document describes the migration from PostgreSQL to Firebase Firestore for the SBKU application.

## Overview

The application has been migrated to use Firebase Firestore as the primary data source in production, replacing the PostgreSQL database. This migration includes:

- Firestore service layer for data operations
- Repository pattern for Firestore collections
- Model updates to use Firestore when active
- Livewire component updates for Firestore compatibility
- Migration script to transfer data from SQL to Firestore

## Configuration

### Environment Variables

The following environment variables control Firestore usage:

- `USE_FIRESTORE`: Set to `true` to enable Firestore as the primary data source
- `FIREBASE_PROJECT_ID`: Firebase project ID (e.g., `sbkuapp-vert25`)
- `FIREBASE_CREDENTIALS`: Path to Firebase service account credentials JSON file
- `GOOGLE_APPLICATION_CREDENTIALS`: Path to Google Cloud credentials (same as FIREBASE_CREDENTIALS)
- `GOOGLE_CLOUD_USE_REST`: Set to `true` to use REST API instead of gRPC (recommended for cloud environments)

### Database Configuration

When `USE_FIRESTORE` is set to `true`:
- The default database connection is forced to SQLite
- PostgreSQL connection is disabled (null values)
- Database migrations are skipped
- An empty SQLite database is created to prevent connection errors

## Firestore Repositories

The following repository classes have been created for Firestore operations:

- `FirestoreUserRepository` - User data operations
- `FirestoreStudentRepository` - Student data operations
- `FirestoreScheduleRepository` - Schedule data operations
- `FirestoreFacultyRepository` - Faculty data operations
- `FirestoreMajorRepository` - Major data operations
- `FirestoreAcademicClassRepository` - Academic class operations
- `FirestoreShiftRepository` - Shift data operations
- `FirestoreTeacherRepository` - Teacher data operations
- `FirestoreSubjectRepository` - Subject data operations
- `FirestoreSyllabusRepository` - Syllabus data operations
- `FirestoreRoomRepository` - Room data operations

## Model Updates

The following models have been updated to use Firestore when active:

- `Student` - Uses FirestoreStudentRepository
- `Schedule` - Uses FirestoreScheduleRepository

These models override the following methods:
- `find()` - Uses Firestore when active
- `all()` - Uses Firestore when active
- `save()` - Syncs to Firestore when active
- `delete()` - Removes from Firestore when active

## Livewire Component Updates

The `StudentIndex` Livewire component has been updated to:
- Load schedule relationships from Firestore
- Mock relationships for Firestore data compatibility
- Use Firestore service for data operations in production

## Migration Script

A migration command has been created to transfer data from SQL to Firestore:

```bash
php artisan firestore:migrate
```

To migrate a specific model:

```bash
php artisan firestore:migrate --model=Student
```

The migration script:
- Reads all records from SQL database
- Formats dates and relationships properly
- Includes relationship data (e.g., user_name, faculty_name for students)
- Writes data to Firestore collections
- Uses the same collection names as SQL tables

## Deployment

### Environment Configuration

Configure your `.env` file with:
- `DB_CONNECTION` set to `sqlite`
- `USE_FIRESTORE` set to `true`
- Firebase credentials configuration
- SQLite database path for compatibility

### Start Script

The `start.sh` script has been updated to:
- Skip database migrations when `USE_FIRESTORE` is true
- Create empty SQLite database to prevent connection errors
- Set up Firebase credentials from secrets

## Testing

To test Firestore integration locally:

1. Set `USE_FIRESTORE=true` in your `.env` file
2. Ensure Firebase credentials are configured
3. Run the migration script to transfer data
4. Test the application with Firestore as the data source

## Troubleshooting

### PostgreSQL Connection Errors

If you see PostgreSQL connection errors in production:
1. Ensure `USE_FIRESTORE=true` is set in your `.env` or container environment
2. Verify that the database configuration is using SQLite
3. Check that migrations are being skipped in start.sh
4. Clear Laravel configuration cache: `php artisan config:clear`

### Firestore Connection Errors

If Firestore connection fails:
1. Verify Firebase credentials are properly configured
2. Check that `FIREBASE_PROJECT_ID` is correct
3. Ensure `GOOGLE_CLOUD_USE_REST=true` is set (recommended for cloud environments)
4. Check Firebase project permissions and Firestore rules

### Data Not Loading

If data is not loading from Firestore:
1. Verify the migration script has been run
2. Check that collection names match table names
3. Ensure Firestore security rules allow read access
4. Check Laravel logs for Firestore errors

## Rollback

To rollback to PostgreSQL:
1. Set `USE_FIRESTORE=false` in your `.env` or container environment
2. Configure PostgreSQL connection in your `.env`
3. Remove the database configuration changes
4. Deploy the application

## Notes

- The application maintains dual compatibility with SQL and Firestore
- Firestore is used only when `USE_FIRESTORE` is explicitly set to `true`
- SQLite is used as a fallback for session/cache storage
- The migration script should be run before enabling Firestore in production
