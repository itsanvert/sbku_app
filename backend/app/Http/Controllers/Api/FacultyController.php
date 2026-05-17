<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Faculty;
use App\Services\FirestoreService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FacultyController extends Controller
{
    protected $firestore;

    public function __construct(FirestoreService $firestore)
    {
        $this->firestore = $firestore;
    }

    public function index(Request $request): JsonResponse
    {
        if (FirestoreService::isActive() || $request->has('firestore')) {
            $faculties = $this->firestore->list('faculties');
            return response()->json([
                'success' => true,
                'data' => $faculties
            ]);
        }

        $faculties = Faculty::all();
        return response()->json([
            'success' => true,
            'data' => $faculties->map(fn($f) => [
                'id' => (string)$f->id,
                'name' => $f->name,
                'code' => $f->code,
            ])
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:50',
        ]);

        if (FirestoreService::isActive() || $request->has('firestore')) {
            $id = $validated['code'];
            $faculty = $this->firestore->set('faculties', $id, $validated);
            return response()->json([
                'success' => true,
                'message' => 'Faculty created in Firestore',
                'data' => $faculty
            ], 201);
        }

        $faculty = Faculty::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Faculty created successfully',
            'data' => [
                'id' => (string)$faculty->id,
                'name' => $faculty->name,
                'code' => $faculty->code,
            ]
        ], 201);
    }

    public function show(Request $request, $id): JsonResponse
    {
        if (FirestoreService::isActive() || $request->has('firestore')) {
            $faculty = $this->firestore->getDocument('faculties', (string)$id);
            if (!$faculty) {
                return response()->json(['success' => false, 'message' => 'Faculty not found'], 404);
            }
            return response()->json(['success' => true, 'data' => $faculty]);
        }

        $faculty = Faculty::findOrFail($id);
        return response()->json([
            'success' => true,
            'data' => [
                'id' => (string)$faculty->id,
                'name' => $faculty->name,
                'code' => $faculty->code,
            ]
        ]);
    }

    public function update(Request $request, $id): JsonResponse
    {
        if (FirestoreService::isActive() || $request->has('firestore')) {
            $faculty = $this->firestore->set('faculties', (string)$id, $request->all());
            return response()->json([
                'success' => true,
                'message' => 'Faculty updated in Firestore',
                'data' => $faculty
            ]);
        }

        $faculty = Faculty::findOrFail($id);
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:50|unique:faculties,code,' . $faculty->id,
        ]);

        $faculty->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Faculty updated successfully',
            'data' => [
                'id' => (string)$faculty->id,
                'name' => $faculty->name,
                'code' => $faculty->code,
            ]
        ]);
    }

    public function destroy(Request $request, $id): JsonResponse
    {
        if (FirestoreService::isActive() || $request->has('firestore')) {
            $this->firestore->delete('faculties', (string)$id);
            return response()->json([
                'success' => true,
                'message' => 'Faculty deleted from Firestore'
            ]);
        }

        $faculty = Faculty::findOrFail($id);
        $faculty->delete();

        return response()->json([
            'success' => true,
            'message' => 'Faculty deleted successfully'
        ]);
    }
}
