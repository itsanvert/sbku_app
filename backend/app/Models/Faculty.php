<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\SyncsToFirestore;

class Faculty extends Model
{
    use SyncsToFirestore;
    protected $fillable = [
        'name',
    ];

    public function majors()
    {
        return $this->hasMany(Major::class);
    }
}
