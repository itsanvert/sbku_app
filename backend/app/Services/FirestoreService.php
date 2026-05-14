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
            // We don't throw here to avoid 500ing every request if Firestore is down
            // but subsequent calls to list/get will fail if $this->db is null.
        }
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
     * List documents with filtering and sorting.
     */
    public function list(string $collection, array $filters = [], string $sortBy = null, string $sortDir = 'asc'): array
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
     * Create or update a document.
     */
    public function set(string $collection, string $id, array $data)
    {
        $this->db->collection($collection)->document($id)->set($data, ['merge' => true]);
        return $this->getDocument($collection, $id);
    }

    /**
     * Delete a document.
     */
    public function delete(string $collection, string $id)
    {
        $this->db->collection($collection)->document($id)->delete();
    }
}
