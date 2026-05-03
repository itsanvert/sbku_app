<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Major;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MajorController extends Controller
{
    public function index(): JsonResponse
    {
        $majors = Major::with('faculty')->get();
        return response()->json([
            'success' => true,
            'data' => $majors->map(fn($m) => [
                'id' => (string)$m->id,
                'name' => $m->name,
                'faculty_id' => (string)$m->faculty_id,
                'faculty_name' => $m->faculty->name ?? 'Unknown',
            ])
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'faculty_id' => 'required|exists:faculties,id',
        ]);

        $major = Major::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Major created successfully',
            'data' => [
                'id' => (string)$major->id,
                'name' => $major->name,
                'faculty_id' => (string)$major->faculty_id,
            ]
        ], 201);
    }

    public function show(Major $major): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'id' => (string)$major->id,
                'name' => $major->name,
                'faculty_id' => (string)$major->faculty_id,
                'faculty_name' => $major->faculty->name ?? 'Unknown',
            ]
        ]);
    }

    public function update(Request $request, Major $major): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'faculty_id' => 'required|exists:faculties,id',
        ]);

        $major->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Major updated successfully',
            'data' => [
                'id' => (string)$major->id,
                'name' => $major->name,
                'faculty_id' => (string)$major->faculty_id,
            ]
        ]);
    }

    public function destroy(Major $major): JsonResponse
    {
        $major->delete();

        return response()->json([
            'success' => true,
            'message' => 'Major deleted successfully'
        ]);
    }
}
