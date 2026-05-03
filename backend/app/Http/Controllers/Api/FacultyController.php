<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Faculty;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FacultyController extends Controller
{
    public function index(): JsonResponse
    {
        $faculties = Faculty::all();
        return response()->json([
            'success' => true,
            'data' => $faculties->map(fn($f) => [
                'id' => (string)$f->id,
                'name' => $f->name,
            ])
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255|unique:faculties,name',
        ]);

        $faculty = Faculty::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Faculty created successfully',
            'data' => [
                'id' => (string)$faculty->id,
                'name' => $faculty->name,
            ]
        ], 201);
    }

    public function show(Faculty $faculty): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'id' => (string)$faculty->id,
                'name' => $faculty->name,
            ]
        ]);
    }

    public function update(Request $request, Faculty $faculty): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255|unique:faculties,name,' . $faculty->id,
        ]);

        $faculty->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Faculty updated successfully',
            'data' => [
                'id' => (string)$faculty->id,
                'name' => $faculty->name,
            ]
        ]);
    }

    public function destroy(Faculty $faculty): JsonResponse
    {
        $faculty->delete();

        return response()->json([
            'success' => true,
            'message' => 'Faculty deleted successfully'
        ]);
    }
}
