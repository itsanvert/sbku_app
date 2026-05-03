<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\SyncsToFirestore;

class Subject extends Model
{
    use SyncsToFirestore;
    protected $fillable = [
        'name',
        'code',
        'credit_hours',
    ];
}
