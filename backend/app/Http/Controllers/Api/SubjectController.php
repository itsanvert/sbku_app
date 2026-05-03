<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Subject;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SubjectController extends Controller
{
    public function index(): JsonResponse
    {
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
            'code' => 'required|string|max:50|unique:subjects,code',
            'credit_hours' => 'nullable|integer|min:1',
        ]);

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

    public function show(Subject $subject): JsonResponse
    {
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

    public function update(Request $request, Subject $subject): JsonResponse
    {
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

    public function destroy(Subject $subject): JsonResponse
    {
        $subject->delete();

        return response()->json([
            'success' => true,
            'message' => 'Subject deleted successfully'
        ]);
    }
}
