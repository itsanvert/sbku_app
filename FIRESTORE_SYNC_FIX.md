# Firestore Migration Sync Fix Guide

## Problem

When migrating models to Firestore, the `SyncsToFirestore` trait was attempting to persist `_synced_at` and `_sync_event` attributes to the MySQL database, but these columns didn't exist. This caused the error:

```
SQLSTATE[42S22]: Column not found: 1054 Unknown column '_synced_at' in 'field list'
```

## Solution Implemented

### 1. Database Migration Added

**File**: `database/migrations/2026_05_16_000000_add_firestore_sync_columns.php`

This migration adds the required columns to all tables using the `SyncsToFirestore` trait:

- `_synced_at` (timestamp): Records when the record was last synced to Firestore
- `_sync_event` (string): Records what event triggered the sync (created/updated/deleted)
- Index on `_synced_at` for query performance

**Tables Updated**:

- users
- teachers
- students
- subjects
- shifts
- schedules
- messages
- majors
- faculties

### 2. SyncsToFirestore Trait Enhanced

**File**: `app/Traits/SyncsToFirestore.php`

**Improvements**:

- Added check for `USE_FIRESTORE` environment variable to skip syncing when Firestore is disabled
- After syncing to Firestore, the trait now sets the local `_synced_at` and `_sync_event` attributes without triggering another database save
- Prevents infinite loops and unnecessary database writes

```php
// Skip sync if Firestore is not enabled
if (!env('USE_FIRESTORE', false)) {
    return;
}

// ...sync to Firestore...

// Update attributes without triggering save
$this->timestamps = false;
$this->setAttribute('_synced_at', now());
$this->setAttribute('_sync_event', $event);
$this->timestamps = true;
```

### 3. Migration Robustness

Fixed several existing migrations to handle cases where:

- Tables/columns already exist
- Columns need to be checked before adding

Updated migrations:

- `2026_05_03_224350_add_fields_to_schedules_table.php`
- `2026_05_12_220000_create_rooms_table.php`

## How to Apply

### For Development

1. **Run pending migrations**:

```bash
cd backend
php artisan migrate
```

2. **If you need a fresh start** (WARNING: loses data):

```bash
php artisan migrate:refresh --seed
```

### For Production

The migrations will automatically run on deployment via your deployment pipeline.

## Configuration

Ensure your `.env` file has the Firestore configuration:

```env
USE_FIRESTORE=false          # Set to true to enable Firestore syncing
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CREDENTIALS=/path/to/credentials.json
GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
GOOGLE_CLOUD_USE_REST=true   # For Render/cloud environments
```

## How It Works

### Normal Operation (USE_FIRESTORE=false)

1. Model is saved to MySQL database
2. Firestore sync is skipped
3. Only MySQL data exists

### With Firestore (USE_FIRESTORE=true)

1. Model is saved to MySQL database
2. Firestore sync event fires (created/updated/deleted)
3. Data is synced to Firestore with `_synced_at` and `_sync_event` metadata
4. Local model attributes are updated to track sync status
5. Both databases stay in sync

## Troubleshooting

### Still Getting "\_synced_at" Errors?

1. **Verify migrations ran**:

```bash
php artisan migrate:status
```

2. **Check database has columns**:

```bash
php artisan tinker
> Schema::hasColumn('users', '_synced_at')
```

3. **If columns missing**, run migration:

```bash
php artisan migrate --force
```

### Models Not Syncing to Firestore?

1. Check `USE_FIRESTORE` environment variable is `true`
2. Verify Firebase credentials are valid
3. Check Laravel logs:

```bash
tail -f storage/logs/laravel.log
```

### Performance Issues?

The `_synced_at` column is indexed for fast lookups. You can query recently synced records:

```php
$recentlySynced = User::where('_synced_at', '>', now()->subMinutes(5))->get();
```

## Models Using SyncsToFirestore

The following models automatically sync to Firestore:

- `User`
- `Teacher`
- `Student`
- `Subject`
- `Shift`
- `Schedule`
- `Message`
- `Major`
- `Faculty`

To disable syncing for a specific model, simply remove the trait:

```php
// Remove this line from the model
use \App\Traits\SyncsToFirestore;
```

## Next Steps

1. Test user profile updates work without errors
2. Monitor logs for Firestore sync errors
3. Verify data appears in Firestore in Firebase Console
4. Consider archiving old MySQL data once confident with Firestore
