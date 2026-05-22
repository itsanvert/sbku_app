<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Subject;
use App\Services\FirestoreService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SubjectController extends Controller
{
    protected $firestore;

    public function __construct(FirestoreService $firestore)
    {
        $this->firestore = $firestore;
    }

    public function index(Request $request): JsonResponse
    {
        if (FirestoreService::isActive() || $request->has('firestore')) {
            $subjects = $this->firestore->list('subjects');
            return response()->json([
                'success' => true,
                'data' => $subjects
            ]);
        }

        $subjects = Subject::all();
        return response()->json([
            'success' => true,
            'data' => $subjects->map(fn($s) => [
                'id' => (string)$s->id,
                'name' => $s->name,
                'code' => $s->code,
                'credit_hours' => (string)$s->credit_hours,
            ])
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:50',
            'credit_hours' => 'nullable|integer|min:1',
        ]);

        if (FirestoreService::isActive() || $request->has('firestore')) {
            $id = $validated['code'];
            $subject = $this->firestore->set('subjects', $id, $validated);
            return response()->json([
                'success' => true,
                'message' => 'Subject created in Firestore',
                'data' => $subject
            ], 201);
        }

        $subject = Subject::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Subject created successfully',
            'data' => [
                'id' => (string)$subject->id,
                'name' => $subject->name,
                'code' => $subject->code,
                'credit_hours' => (string)$subject->credit_hours,
            ]
        ], 201);
    }

    public function show(Request $request, $id): JsonResponse
    {
        if (FirestoreService::isActive() || $request->has('firestore')) {
            $subject = $this->firestore->getDocument('subjects', (string)$id);
            if (!$subject) {
                return response()->json(['success' => false, 'message' => 'Subject not found'], 404);
            }
            return response()->json(['success' => true, 'data' => $subject]);
        }

        $subject = Subject::findOrFail($id);
        return response()->json([
            'success' => true,
            'data' => [
                'id' => (string)$subject->id,
                'name' => $subject->name,
                'code' => $subject->code,
                'credit_hours' => (string)$subject->credit_hours,
            ]
        ]);
    }

    public function update(Request $request, $id): JsonResponse
    {
        if (FirestoreService::isActive() || $request->has('firestore')) {
            $subject = $this->firestore->set('subjects', (string)$id, $request->all());
            return response()->json([
                'success' => true,
                'message' => 'Subject updated in Firestore',
                'data' => $subject
            ]);
        }

        $subject = Subject::findOrFail($id);
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:50|unique:subjects,code,' . $subject->id,
            'credit_hours' => 'nullable|integer|min:1',
        ]);

        $subject->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Subject updated successfully',
            'data' => [
                'id' => (string)$subject->id,
                'name' => $subject->name,
                'code' => $subject->code,
                'credit_hours' => (string)$subject->credit_hours,
            ]
        ]);
    }

    public function destroy(Request $request, $id): JsonResponse
    {
        if (FirestoreService::isActive() || $request->has('firestore')) {
            $this->firestore->delete('subjects', (string)$id);
            return response()->json([
                'success' => true,
                'message' => 'Subject deleted from Firestore'
            ]);
        }

        $subject = Subject::findOrFail($id);
        $subject->delete();

        return response()->json([
            'success' => true,
            'message' => 'Subject deleted successfully'
        ]);
    }
}
