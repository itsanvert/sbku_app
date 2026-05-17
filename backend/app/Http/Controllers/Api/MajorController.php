<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Major;
use App\Services\FirestoreService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MajorController extends Controller
{
    protected $firestore;

    public function __construct(FirestoreService $firestore)
    {
        $this->firestore = $firestore;
    }

    public function index(Request $request): JsonResponse
    {
        if (FirestoreService::isActive() || $request->has('firestore')) {
            $majors = $this->firestore->list('majors');
            return response()->json([
                'success' => true,
                'data' => $majors
            ]);
        }

        $majors = Major::with('faculty')->get();
        return response()->json([
            'success' => true,
            'data' => $majors->map(fn($m) => [
                'id' => (string)$m->id,
                'name' => $m->name,
                'code' => $m->code,
                'faculty_id' => (string)$m->faculty_id,
                'faculty_name' => $m->faculty->name ?? 'Unknown',
            ])
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:50',
            'faculty_id' => 'required',
        ]);

        if (FirestoreService::isActive() || $request->has('firestore')) {
            $id = $validated['code'];
            $major = $this->firestore->set('majors', $id, $validated);
            return response()->json([
                'success' => true,
                'message' => 'Major created in Firestore',
                'data' => $major
            ], 201);
        }

        $major = Major::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Major created successfully',
            'data' => [
                'id' => (string)$major->id,
                'name' => $major->name,
                'code' => $major->code,
                'faculty_id' => (string)$major->faculty_id,
            ]
        ], 201);
    }

    public function show(Request $request, $id): JsonResponse
    {
        if (FirestoreService::isActive() || $request->has('firestore')) {
            $major = $this->firestore->getDocument('majors', (string)$id);
            if (!$major) {
                return response()->json(['success' => false, 'message' => 'Major not found'], 404);
            }
            return response()->json(['success' => true, 'data' => $major]);
        }

        $major = Major::findOrFail($id);
        return response()->json([
            'success' => true,
            'data' => [
                'id' => (string)$major->id,
                'name' => $major->name,
                'code' => $major->code,
                'faculty_id' => (string)$major->faculty_id,
                'faculty_name' => $major->faculty->name ?? 'Unknown',
            ]
        ]);
    }

    public function update(Request $request, $id): JsonResponse
    {
        if (FirestoreService::isActive() || $request->has('firestore')) {
            $major = $this->firestore->set('majors', (string)$id, $request->all());
            return response()->json([
                'success' => true,
                'message' => 'Major updated in Firestore',
                'data' => $major
            ]);
        }

        $major = Major::findOrFail($id);
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:50|unique:majors,code,' . $major->id,
            'faculty_id' => 'required|exists:faculties,id',
        ]);

        $major->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Major updated successfully',
            'data' => [
                'id' => (string)$major->id,
                'name' => $major->name,
                'code' => $major->code,
                'faculty_id' => (string)$major->faculty_id,
            ]
        ]);
    }

    public function destroy(Request $request, $id): JsonResponse
    {
        if (FirestoreService::isActive() || $request->has('firestore')) {
            $this->firestore->delete('majors', (string)$id);
            return response()->json([
                'success' => true,
                'message' => 'Major deleted from Firestore'
            ]);
        }

        $major = Major::findOrFail($id);
        $major->delete();

        return response()->json([
            'success' => true,
            'message' => 'Major deleted successfully'
        ]);
    }
}
