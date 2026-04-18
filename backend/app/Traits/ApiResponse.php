<?php

namespace App\Traits;

use Illuminate\Http\JsonResponse;

/**
 * Provides a standardized JSON response envelope for all API controllers.
 *
 * Every API response follows the same shape:
 * {
 *   "success": true|false,
 *   "message": "...",
 *   "data":    { ... }        // on success
 *   "errors":  { ... }        // on validation failure (optional)
 * }
 *
 * Usage: `use ApiResponse;` in any controller.
 */
trait ApiResponse
{
    /**
     * Return a success response.
     */
    protected function success(
        mixed $data = null,
        string $message = 'OK',
        int $code = 200,
    ): JsonResponse {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data'    => $data,
        ], $code);
    }

    /**
     * Return a created response (HTTP 201).
     */
    protected function created(
        mixed $data = null,
        string $message = 'Created successfully',
    ): JsonResponse {
        return $this->success($data, $message, 201);
    }

    /**
     * Return an error response.
     */
    protected function error(
        string $message = 'Something went wrong',
        int $code = 400,
        mixed $errors = null,
    ): JsonResponse {
        $payload = [
            'success' => false,
            'message' => $message,
        ];

        if ($errors !== null) {
            $payload['errors'] = $errors;
        }

        return response()->json($payload, $code);
    }

    /**
     * Return a not-found response (HTTP 404).
     */
    protected function notFound(string $message = 'Resource not found'): JsonResponse
    {
        return $this->error($message, 404);
    }

    /**
     * Return an unauthorized response (HTTP 401).
     */
    protected function unauthorized(string $message = 'Unauthenticated'): JsonResponse
    {
        return $this->error($message, 401);
    }

    /**
     * Return a forbidden response (HTTP 403).
     */
    protected function forbidden(string $message = 'Forbidden'): JsonResponse
    {
        return $this->error($message, 403);
    }

    /**
     * Return a no-content response (HTTP 204).
     */
    protected function noContent(): JsonResponse
    {
        return response()->json(null, 204);
    }
}
