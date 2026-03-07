<?php

use Illuminate\Support\Facades\Route;
use App\Livewire\Users\UserIndex;
use App\Livewire\Teachers\TeacherIndex;
Route::get('/', function () {
    return view('auth.login');
});

Route::middleware([
    'auth:sanctum',
    config('jetstream.auth_session'),
    'verified',
])->group(function () {
    Route::get('/dashboard', function () {
        return view('dashboard');
    })->name('dashboard');
});

Route::get('/flux-test', function () {
    return view('flux-test');
});


Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/users', UserIndex::class)->name('users.index');
    Route::get('/teachers', TeacherIndex::class)->name('teachers.index');
});

