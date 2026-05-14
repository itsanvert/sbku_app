<?php

namespace App\Traits;

use Kreait\Laravel\Firebase\Facades\Firebase;
use Exception;

trait SyncsToFirestore
{
    /**
     * Boot the trait to hook into model events.
     */
    public static function bootSyncsToFirestore()
    {
        static::created(function ($model) {
            $model->syncToFirestore('created');
        });

        static::updated(function ($model) {
            $model->syncToFirestore('updated');
        });

        static::deleted(function ($model) {
            $model->deleteFromFirestore();
        });
    }

    /**
     * Get the Firestore collection name for this model.
     * Override this method in the model if a custom collection name is needed.
     */
    public function getFirestoreCollectionName()
    {
        return $this->getTable();
    }

    /**
     * Get the data array to sync to Firestore.
     * Override this method in the model if custom formatting is needed.
     */
    public function toFirestoreArray()
    {
        return $this->getAttributes();
    }

    /**
     * Sync the current model state to Firestore.
     */
    public function syncToFirestore($event = 'updated')
    {
        try {
            $firestore = \Kreait\Laravel\Firebase\Facades\Firebase::firestore()->database();
            $collection = $this->getFirestoreCollectionName();
            $documentId = (string) $this->getKey();

            $data = $this->toFirestoreArray();
            
            // Add a timestamp for the sync
            $data['_synced_at'] = now()->toIso8601String();
            $data['_sync_event'] = $event;

            $firestore->collection($collection)->document($documentId)->set($data);
        } catch (Exception $e) {
            \Log::error("Firestore Sync Error for {$this->getFirestoreCollectionName()} [{$this->getKey()}]: " . $e->getMessage());
        }
    }

    /**
     * Delete the current model document from Firestore.
     */
    public function deleteFromFirestore()
    {
        try {
            $firestore = \Kreait\Laravel\Firebase\Facades\Firebase::firestore()->database();
            $collection = $this->getFirestoreCollectionName();
            $documentId = (string) $this->getKey();

            $firestore->collection($collection)->document($documentId)->delete();
        } catch (Exception $e) {
            \Log::error("Firestore Delete Error for {$this->getFirestoreCollectionName()} [{$this->getKey()}]: " . $e->getMessage());
        }
    }
}
