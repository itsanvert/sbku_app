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
        $this->db = Firebase::firestore()->database();
    }

    /**
     * Get a collection.
     */
    public function collection(string $name)
    {
        return $this->db->collection($name);
    }

    /**
     * Get a document by ID.
     */
    public function getDocument(string $collection, string $id)
    {
        $doc = $this->db->collection($collection)->document($id)->snapshot();
        
        if (!$doc->exists()) {
            return null;
        }

        $data = $doc->data();
        $data['id'] = $doc->id();
        return $data;
    }

    /**
     * List documents in a collection with filters.
     */
    public function list(string $collection, array $filters = [], string $orderBy = null, string $direction = 'asc')
    {
        $query = $this->db->collection($collection);

        foreach ($filters as $field => $value) {
            if (is_array($value)) {
                $query = $query->where($field, $value[0], $value[1]);
            } else {
                $query = $query->where($field, '=', $value);
            }
        }

        if ($orderBy) {
            $query = $query->orderBy($orderBy, $direction);
        }

        $documents = $query->documents();
        $results = [];

        foreach ($documents as $document) {
            $data = $document->data();
            $data['id'] = $document->id();
            $results[] = $data;
        }

        return $results;
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
