<?php

namespace App\Repositories;

use App\Services\FirestoreService;
use Illuminate\Support\Collection;

class FirestoreSubjectRepository
{
    protected FirestoreService $firestore;
    protected string $collection = 'subjects';

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
        $data = $this->firestore->list($this->collection, $filters, 'name', 'asc');
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

    public function forFaculty($facultyId): Collection
    {
        return $this->where('faculty_id', $facultyId);
    }
}
