<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Admin frontend routes
Route::prefix('admin')->group(function () {
    Route::get('/', function () {
        return redirect('/admin/login');
    });
    
    Route::get('/login', function () {
        return view('admin.login');
    });
    
    Route::get('/dashboard', function () {
        return view('admin.dashboard');
    });
    
    Route::get('/users', function () {
        return view('admin.users');
    });
    
    Route::get('/settings', function () {
        return view('admin.settings');
    });
    
    Route::get('/analytics', function () {
        return view('admin.analytics');
    });
    
    Route::get('/conversations', function () {
        return view('admin.conversations');
    });
});
