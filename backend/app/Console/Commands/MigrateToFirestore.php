<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Kreait\Laravel\Firebase\Facades\Firebase;
use ReflectionClass;
use Illuminate\Support\Str;

class MigrateToFirestore extends Command
{
    protected $signature = 'migrate:to-firestore {--model= : Migrate specific model}';
    protected $description = 'Migrate existing data from PostgreSQL to Firestore';

    public function handle()
    {
        $models = $this->getTargetModels();

        if (empty($models)) {
            $this->error('No models found using SyncsToFirestore trait.');
            return;
        }

        foreach ($models as $modelClass) {
            $this->migrateModel($modelClass);
        }

        $this->info('Migration complete!');
    }

    protected function getTargetModels(): array
    {
        if ($this->option('model')) {
            $model = "App\\Models\\" . $this->option('model');
            return class_exists($model) ? [$model] : [];
        }

        // List of models we found earlier
        return [
            \App\Models\User::class,
            \App\Models\Subject::class,
            \App\Models\Shift::class,
            \App\Models\Schedule::class,
            \App\Models\Major::class,
            \App\Models\Message::class,
            \App\Models\Faculty::class,
            \App\Models\Attendance::class,
            \App\Models\AcademicClass::class,
            \App\Models\AttendanceSession::class,
        ];
    }

    protected function migrateModel($modelClass)
    {
        $modelInstance = new $modelClass();
        $tableName = $modelInstance->getTable();
        $collectionName = method_exists($modelInstance, 'getFirestoreCollectionName') 
            ? $modelInstance->getFirestoreCollectionName() 
            : $tableName;

        $count = $modelClass::count();
        $this->info("Migrating {$count} records for {$tableName} to Firestore collection '{$collectionName}'...");

        $firestore = Firebase::firestore()->database();
        
        $modelClass::chunk(500, function ($records) use ($firestore, $collectionName) {
            $bulkWriter = $firestore->bulkWriter();
            
            foreach ($records as $record) {
                $data = method_exists($record, 'toFirestoreArray') 
                    ? $record->toFirestoreArray() 
                    : $record->getAttributes();
                
                $data['_synced_at'] = now()->toIso8601String();
                $data['_sync_event'] = 'migration';

                $docRef = $firestore->collection($collectionName)->document((string)$record->getKey());
                $bulkWriter->set($docRef, $data);
            }
            
            $bulkWriter->close();
            $this->output->write('.');
        });

        $this->info("\nFinished {$tableName}.");
    }
}
