<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AcademicClass;
use App\Services\FirestoreService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AcademicClassController extends Controller
{
    public function __construct(
    ) {}

    public function index(Request $request): JsonResponse
    {
        if (config('app.env') === 'production' || $request->has('firestore')) {
            $classes = $this->firestore->list('academic_classes');
            return response()->json([
                'success' => true,
                'data' => $classes
            ]);
        }

        $classes = AcademicClass::with('major.faculty')->get();
        return response()->json([
            'success' => true,
            'data' => $classes->map(fn($c) => [
                'id' => (string)$c->id,
                'name' => $c->name,
                'code' => $c->code,
                'major_id' => (string)$c->major_id,
                'major_name' => $c->major->name ?? 'Unknown',
                'faculty_name' => $c->major->faculty->name ?? 'Unknown',
                'academic_year' => $c->academic_year,
                'semester' => (string)$c->semester,
            ])
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:50',
            'major_id' => 'required',
            'academic_year' => 'required|string|max:50',
            'semester' => 'required|integer|min:1|max:2',
        ]);

        if (config('app.env') === 'production' || $request->has('firestore')) {
            $id = $validated['code']; // Or generate a UUID
            $class = $this->firestore->set('academic_classes', $id, $validated);
            return response()->json([
                'success' => true,
                'message' => 'Class created in Firestore',
                'data' => $class
            ], 201);
        }

        $class = AcademicClass::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Class created successfully',
            'data' => [
                'id' => (string)$class->id,
                'name' => $class->name,
                'code' => $class->code,
                'major_id' => (string)$class->major_id,
                'academic_year' => $class->academic_year,
                'semester' => (string)$class->semester,
            ]
        ], 201);
    }

    public function show(Request $request, $id): JsonResponse
    {
        if (config('app.env') === 'production' || $request->has('firestore')) {
            $class = $this->firestore->getDocument('academic_classes', (string)$id);
            if (!$class) {
                return response()->json(['success' => false, 'message' => 'Class not found'], 404);
            }
            return response()->json(['success' => true, 'data' => $class]);
        }

        $academicClass = AcademicClass::findOrFail($id);
        return response()->json([
            'success' => true,
            'data' => [
                'id' => (string)$academicClass->id,
                'name' => $academicClass->name,
                'code' => $academicClass->code,
                'major_id' => (string)$academicClass->major_id,
                'major_name' => $academicClass->major->name ?? 'Unknown',
                'faculty_name' => $academicClass->major->faculty->name ?? 'Unknown',
                'academic_year' => $academicClass->academic_year,
                'semester' => (string)$academicClass->semester,
            ]
        ]);
    }

    public function update(Request $request, $id): JsonResponse
    {
        if (config('app.env') === 'production' || $request->has('firestore')) {
            $class = $this->firestore->set('academic_classes', (string)$id, $request->all());
            return response()->json([
                'success' => true,
                'message' => 'Class updated in Firestore',
                'data' => $class
            ]);
        }

        $academicClass = AcademicClass::findOrFail($id);
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:50|unique:academic_classes,code,' . $academicClass->id,
            'major_id' => 'required|exists:majors,id',
            'academic_year' => 'required|string|max:50',
            'semester' => 'required|integer|min:1|max:2',
        ]);

        $academicClass->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Class updated successfully',
            'data' => [
                'id' => (string)$academicClass->id,
                'name' => $academicClass->name,
                'code' => $academicClass->code,
                'major_id' => (string)$academicClass->major_id,
                'academic_year' => $academicClass->academic_year,
                'semester' => (string)$academicClass->semester,
            ]
        ]);
    }

    public function destroy(Request $request, $id): JsonResponse
    {
        if (config('app.env') === 'production' || $request->has('firestore')) {
            $this->firestore->delete('academic_classes', (string)$id);
            return response()->json([
                'success' => true,
                'message' => 'Class deleted from Firestore'
            ]);
        }

        $academicClass = AcademicClass::findOrFail($id);
        $academicClass->delete();

        return response()->json([
            'success' => true,
            'message' => 'Class deleted successfully'
        ]);
    }
}
