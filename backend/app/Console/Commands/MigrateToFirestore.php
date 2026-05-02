<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Kreait\Laravel\Firebase\Facades\Firebase;
use Exception;

class MigrateToFirestore extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'firestore:migrate {--model= : Only migrate a specific model class name}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Migrate MySQL database records to Firebase Firestore';

    /**
     * List of models to migrate.
     */
    protected $models = [
        \App\Models\User::class,
        \App\Models\Teacher::class,
        \App\Models\Student::class,
        \App\Models\Faculty::class,
        \App\Models\Major::class,
        \App\Models\Shift::class,
        \App\Models\Subject::class,
        \App\Models\Syllabus::class,
        \App\Models\Schedule::class,
        \App\Models\AttendanceSession::class,
        \App\Models\Attendance::class,
    ];

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Starting migration to Firestore...');
        
        $firestore = Firebase::firestore()->database();
        
        $modelsToMigrate = $this->models;
        
        if ($this->option('model')) {
            $modelClass = '\\App\\Models\\' . $this->option('model');
            if (in_array($modelClass, $this->models)) {
                $modelsToMigrate = [$modelClass];
            } else {
                $this->error("Model {$modelClass} is not in the migration list.");
                return 1;
            }
        }

        foreach ($modelsToMigrate as $modelClass) {
            $this->info("Migrating {$modelClass}...");
            
            try {
                $instance = new $modelClass();
                $collectionName = $instance->getTable();
                
                $records = $modelClass::all();
                $bar = $this->output->createProgressBar(count($records));
                
                foreach ($records as $record) {
                    $data = $record->toArray();
                    
                    // Format dates properly
                    foreach ($data as $key => $value) {
                        if ($value instanceof \DateTimeInterface) {
                            $data[$key] = $value->format('Y-m-d H:i:s');
                        } elseif (is_string($value) && strtotime($value) !== false && preg_match('/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/', $value)) {
                            // If it's already an ISO string date
                            $data[$key] = date('Y-m-d H:i:s', strtotime($value));
                        }
                    }

                    // Add SyncsToFirestore specific formatting if it exists
                    if (method_exists($record, 'toFirestoreArray')) {
                        $data = $record->toFirestoreArray();
                    }

                    $firestore->collection($collectionName)
                        ->document((string) $record->getKey())
                        ->set($data);
                        
                    $bar->advance();
                }
                
                $bar->finish();
                $this->newLine();
                $this->info("Successfully migrated {$collectionName}.");
            } catch (Exception $e) {
                $this->newLine();
                $this->error("Failed to migrate {$modelClass}: " . $e->getMessage());
            }
        }

        $this->info('Migration to Firestore completed!');
        return 0;
    }
}
