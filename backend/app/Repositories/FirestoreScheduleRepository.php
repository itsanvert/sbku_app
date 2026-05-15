<?php

namespace App\Repositories;

use App\Services\FirestoreService;
use Illuminate\Support\Collection;

class FirestoreScheduleRepository
{
    protected FirestoreService $firestore;
    protected string $collection = 'schedules';

    public function __construct(FirestoreService $firestore)
    {
        $this->firestore = $firestore;
    }

    public function find($id): ?array
    {
        return $this->firestore->getDocument($this->collection, $id);
    }

    public function all(array $filters = []): Collection
    {
        $data = $this->firestore->list($this->collection, $filters, 'created_at', 'desc');
        return collect($data);
    }

    public function create(array $data): string
    {
        $data['created_at'] = now()->toIso8601String();
        $data['updated_at'] = now()->toIso8601String();
        return $this->firestore->create($this->collection, $data);
    }

    public function update($id, array $data): void
    {
        $data['updated_at'] = now()->toIso8601String();
        $this->firestore->update($this->collection, $id, $data);
    }

    public function delete($id): void
    {
        $this->firestore->delete($this->collection, $id);
    }

    public function where($field, $value): Collection
    {
        return $this->all([$field => $value]);
    }

    public function whereIn($field, array $values): Collection
    {
        // Firestore doesn't support whereIn directly, need to use multiple queries
        $results = collect();
        foreach ($values as $value) {
            $results = $results->merge($this->where($field, $value));
        }
        return $results->unique('id');
    }

    public function forDay(string $day): Collection
    {
        return $this->all([['day_of_the_week', '==', strtolower($day)]]);
    }

    public function activeOn(string $date): Collection
    {
        $data = $this->firestore->list($this->collection, [], 'created_at', 'desc');
        return collect($data)->filter(function ($schedule) use ($date) {
            $startDate = $schedule['start_date'] ?? null;
            $endDate = $schedule['end_date'] ?? null;
            
            if ($startDate && $startDate > $date) return false;
            if ($endDate && $endDate < $date) return false;
            
            return true;
        });
    }

    public function overlapping(string $start, string $end, ?int $excludeId = null): Collection
    {
        $data = $this->firestore->list($this->collection, [], 'start_time', 'asc');
        return collect($data)->filter(function ($schedule) use ($start, $end, $excludeId) {
            if ($excludeId && $schedule['id'] == $excludeId) return false;
            
            $scheduleStart = $schedule['start_time'];
            $scheduleEnd = $schedule['end_time'];
            
            return $scheduleStart < $end && $scheduleEnd > $start;
        });
    }

    public function forTeacher(int $teacherId): Collection
    {
        return $this->where('teacher_id', $teacherId);
    }
}
