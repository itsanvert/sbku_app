<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Room;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RoomController extends Controller
{
    public function index(): JsonResponse
    {
        $rooms = Room::all();
        return response()->json([
            'success' => true,
            'data' => $rooms->map(fn($r) => [
                'id' => (string)$r->id,
                'name' => $r->name,
                'code' => $r->code,
            ])
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'nullable|string|max:50',
        ]);

        $room = Room::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Room created successfully',
            'data' => [
                'id' => (string)$room->id,
                'name' => $room->name,
                'code' => $room->code,
            ]
        ], 201);
    }

    public function show($id): JsonResponse
    {
        $room = Room::findOrFail($id);
        return response()->json([
            'success' => true,
            'data' => [
                'id' => (string)$room->id,
                'name' => $room->name,
                'code' => $room->code,
            ]
        ]);
    }

    public function update(Request $request, $id): JsonResponse
    {
        $room = Room::findOrFail($id);
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'nullable|string|max:50|unique:rooms,code,' . $room->id,
        ]);

        $room->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Room updated successfully',
            'data' => [
                'id' => (string)$room->id,
                'name' => $room->name,
                'code' => $room->code,
            ]
        ]);
    }

    public function destroy($id): JsonResponse
    {
        $room = Room::findOrFail($id);
        $room->delete();

        return response()->json([
            'success' => true,
            'message' => 'Room deleted successfully'
        ]);
    }
}
