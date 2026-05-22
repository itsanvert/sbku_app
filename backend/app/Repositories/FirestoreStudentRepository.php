<?php

namespace App\Repositories;

use App\Services\FirestoreService;
use Illuminate\Support\Collection;

class FirestoreStudentRepository
{
    protected FirestoreService $firestore;
    protected string $collection = 'students';

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
        $results = collect();
        foreach ($values as $value) {
            $results = $results->merge($this->where($field, $value));
        }
        return $results->unique('id');
    }

    public function withSchedule(): Collection
    {
        $data = $this->firestore->list($this->collection, [], 'created_at', 'desc');
        return collect($data)->map(function ($student) {
            if (isset($student['schedule_id'])) {
                $scheduleRepo = new FirestoreScheduleRepository($this->firestore);
                $student['schedule'] = $scheduleRepo->find($student['schedule_id']);
            }
            return $student;
        });
    }

    public function forFaculty($facultyId): Collection
    {
        return $this->where('faculty_id', $facultyId);
    }

    public function forMajor($majorId): Collection
    {
        return $this->where('major_id', $majorId);
    }

    public function forAcademicClass($classId): Collection
    {
        return $this->where('academic_class_id', $classId);
    }

    public function forShift($shiftId): Collection
    {
        return $this->where('shift_id', $shiftId);
    }
}
