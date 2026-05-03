<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\SyncsToFirestore;

class Shift extends Model
{
    use SyncsToFirestore;
    protected $fillable = [
        'name',
    ];

    public function teachers()
    {
        return $this->hasMany(Teacher::class);
    }
}
