<?php

namespace App\Services;

use Kreait\Laravel\Firebase\Facades\Firebase;
use Google\Cloud\Firestore\FirestoreClient;
use Google\Cloud\Firestore\Query;

class FirestoreService
{
    protected $db;

    public function __construct()
    {
        try {
            $this->db = Firebase::firestore()->database();
        } catch (\Exception $e) {
            \Log::error("Failed to initialize Firestore: " . $e->getMessage());
        }
    }

    /**
     * Determine if Firestore is the active/primary data source.
     */
    public static function isActive(): bool
    {
        return env('USE_FIRESTORE', false) === 'true';
    }

    /**
     * Get a collection.
     */
    public function collection(string $name)
    {
        if (!$this->db) return null;
        return $this->db->collection($name);
    }

    /**
     * Get a document by ID.
     */
    public function getDocument(string $collection, string $id)
    {
        if (!$this->db) return null;
        $doc = $this->db->collection($collection)->document($id)->snapshot();
        
        if (!$doc->exists()) {
            return null;
        }

        $data = $doc->data();
        $data['id'] = $doc->id();
        return $data;
    }

    /**
     * Count documents in a collection with optional filters.
     */
    public function count(string $collection, array $filters = []): int
    {
        if (!$this->db) return 0;
        try {
            $query = $this->db->collection($collection);

            foreach ($filters as $field => $value) {
                if (is_array($value) && count($value) === 3) {
                    $query = $query->where($value[0], $value[1], $value[2]);
                } else {
                    $query = $query->where($field, '=', $value);
                }
            }

            return $query->count();
        } catch (\Exception $e) {
            \Log::error("Firestore count error for $collection: " . $e->getMessage());
            return 0;
        }
    }

    /**
     * List documents with filtering, sorting, and pagination.
     */
    public function list(string $collection, array $filters = [], string $sortBy = null, string $sortDir = 'asc', int $limit = null, int $offset = null): array
    {
        if (!$this->db) return [];
        try {
            $query = $this->db->collection($collection);

            foreach ($filters as $field => $value) {
                if (is_array($value) && count($value) === 3) {
                    // Handle [field, operator, value]
                    $query = $query->where($value[0], $value[1], $value[2]);
                } else {
                    // Handle field => value
                    $query = $query->where($field, '=', $value);
                }
            }

            if ($sortBy) {
                $query = $query->orderBy($sortBy, $sortDir);
            }

            if ($limit !== null) {
                $query = $query->limit($limit);
            }

            if ($offset !== null) {
                $query = $query->offset($offset);
            }

            $documents = $query->documents();
            $results = [];

            foreach ($documents as $doc) {
                if ($doc->exists()) {
                    $data = $doc->data();
                    $data['id'] = $doc->id();
                    $results[] = $data;
                }
            }

            return $results;
        } catch (\Exception $e) {
            \Log::error("Firestore list error for $collection: " . $e->getMessage());
            return [];
        }
    }

    /**
     * Create a new document.
     * Returns the ID of the created document.
     */
    public function create(string $collection, array $data, string $id = null): string
    {
        if (!$this->db) return '';
        
        $colRef = $this->db->collection($collection);
        if ($id) {
            $docRef = $colRef->document($id);
            $docRef->set($data);
        } else {
            $docRef = $colRef->add($data);
            $id = $docRef->id();
        }
        
        return $id;
    }

    /**
     * Update an existing document.
     */
    public function update(string $collection, string $id, array $data): void
    {
        if (!$this->db) return;
        $this->db->collection($collection)->document($id)->set($data, ['merge' => true]);
    }

    /**
     * Create or update a document (alias for set).
     */
    public function set(string $collection, string $id, array $data)
    {
        $this->update($collection, $id, $data);
        return $this->getDocument($collection, $id);
    }

    /**
     * Delete a document.
     */
    public function delete(string $collection, string $id)
    {
        if (!$this->db) return;
        $this->db->collection($collection)->document($id)->delete();
    }
}
