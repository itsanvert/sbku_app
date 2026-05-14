<?php

namespace App\Services;

use Kreait\Laravel\Firebase\Facades\Firebase;
use Google\Cloud\Firestore\FirestoreClient;
use Google\Cloud\Firestore\DocumentReference;
use Illuminate\Support\Str;

class FirestoreService
{
    protected $db;

    public function __construct()
    {
        $this->db = Firebase::project('app')->firestore()->database();
    }

    /**
     * Get the Firestore database instance.
     */
    public function db()
    {
        return $this->db;
    }

    /**
     * Find a document by ID.
     */
    public function find(string $collection, $id)
    {
        $doc = $this->db->collection($collection)->document((string)$id)->snapshot();
        return $doc->exists() ? array_merge(['id' => $doc->id()], $doc->data()) : null;
    }

    /**
     * Get all documents in a collection with optional filters.
     */
    public function all(string $collection, array $where = [], array $orderBy = [], $limit = null)
    {
        $query = $this->db->collection($collection);

        foreach ($where as $w) {
            $query = $query->where($w[0], $w[1], $w[2]);
        }

        foreach ($orderBy as $field => $direction) {
            $query = $query->orderBy($field, $direction);
        }

        if ($limit) {
            $query = $query->limit($limit);
        }

        $documents = $query->documents();
        $results = [];
        foreach ($documents as $doc) {
            $results[] = array_merge(['id' => $doc->id()], $doc->data());
        }
        return collect($results);
    }

    /**
     * Create a new document.
     */
    public function create(string $collection, array $data, $id = null)
    {
        $data['created_at'] = now()->toIso8601String();
        $data['updated_at'] = now()->toIso8601String();

        $colRef = $this->db->collection($collection);
        if ($id) {
            $colRef->document((string)$id)->set($data);
            return array_merge(['id' => (string)$id], $data);
        } else {
            $docRef = $colRef->add($data);
            return array_merge(['id' => $docRef->id()], $data);
        }
    }

    /**
     * Update a document.
     */
    public function update(string $collection, $id, array $data)
    {
        $data['updated_at'] = now()->toIso8601String();
        $this->db->collection($collection)->document((string)$id)->update($this->formatUpdateData($data));
        return true;
    }

    /**
     * Delete a document.
     */
    public function delete(string $collection, $id)
    {
        $this->db->collection($collection)->document((string)$id)->delete();
        return true;
    }

    /**
     * Helper to format update data (handling nested arrays if needed).
     */
    protected function formatUpdateData(array $data)
    {
        $formatted = [];
        foreach ($data as $key => $value) {
            $formatted[] = ['path' => $key, 'value' => $value];
        }
        return $formatted;
    }
}
