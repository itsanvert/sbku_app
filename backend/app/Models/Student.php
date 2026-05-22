<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use App\Traits\SyncsToFirestore;
use App\Services\FirestoreService;
use App\Repositories\FirestoreStudentRepository;
use App\Repositories\FirestoreScheduleRepository;
use App\Repositories\FirestoreFacultyRepository;
use App\Repositories\FirestoreMajorRepository;
use App\Repositories\FirestoreShiftRepository;
use App\Repositories\FirestoreAcademicClassRepository;
use App\Repositories\FirestoreUserRepository;

class Student extends Model
{
    protected $appends = ['name', 'email', 'avatar_url'];

    protected $fillable = [
        'user_id',
        'gender',
        'dob',
        'faculty_id',
        'major_id',
        'year',
        'shift_id',
        'schedule_id',
        'generation',
        'academic_class_id',
        'profile_image_path',
    ];

    protected static $firestoreRepo;

    // ── Firestore Integration ─────────────────────────────────

    public static function getFirestoreRepository()
    {
        if (!static::$firestoreRepo) {
            static::$firestoreRepo = new FirestoreStudentRepository(new FirestoreService());
        }
        return static::$firestoreRepo;
    }

    public static function useFirestore(): bool
    {
        return FirestoreService::isActive();
    }

    // Override find to use Firestore when active
    public static function find($id, $columns = ['*'])
    {
        if (static::useFirestore()) {
            $data = static::getFirestoreRepository()->find($id);
            if ($data) {
                $model = new static();
                $model->fill($data);
                $model->id = $data['id'];
                $model->exists = true;
                return $model;
            }
            return null;
        }
        return parent::find($id, $columns);
    }

    // Override all to use Firestore when active
    public static function all($columns = ['*'])
    {
        if (static::useFirestore()) {
            $data = static::getFirestoreRepository()->all();
            return $data->map(function ($item) {
                $model = new static();
                $model->fill($item);
                $model->id = $item['id'];
                $model->exists = true;
                return $model;
            });
        }
        return parent::all($columns);
    }

    // Override save to sync to Firestore
    public function save(array $options = [])
    {
        $result = parent::save($options);

        if (static::useFirestore() && $result) {
            $data = $this->toArray();
            $data['id'] = $this->id;

            if ($this->wasRecentlyCreated) {
                static::getFirestoreRepository()->create($data);
            } else {
                static::getFirestoreRepository()->update($this->id, $data);
            }
        }

        return $result;
    }

    // Override delete to remove from Firestore
    public function delete()
    {
        $result = parent::delete();

        if (static::useFirestore() && $result) {
            static::getFirestoreRepository()->delete($this->id);
        }

        return $result;
    }

    // ── Accessors ──────────────────────────────────────────────

    /**
     * Get the student's name from the associated user.
     */
    public function getNameAttribute(): ?string
    {
        if (static::useFirestore()) {
            if ($this->user_id) {
                $userRepo = new FirestoreUserRepository(new FirestoreService());
                $user = $userRepo->find($this->user_id);
                return $user['name'] ?? null;
            }
            return $this->attributes['name'] ?? null;
        }

        $user = $this->getRelationValue('user');
        return $user instanceof Model ? $user->name : ($this->user_name ?? null);
    }

    /**
     * Get the student's email from the associated user.
     */
    public function getEmailAttribute(): ?string
    {
        if (static::useFirestore()) {
            if ($this->user_id) {
                $userRepo = new FirestoreUserRepository(new FirestoreService());
                $user = $userRepo->find($this->user_id);
                return $user['email'] ?? null;
            }
            return $this->attributes['email'] ?? null;
        }

        $user = $this->getRelationValue('user');
        return $user instanceof Model ? $user->email : ($this->user_email ?? null);
    }

    /**
     * Get the full URL for the student's profile photo.
     */
    public function getAvatarUrlAttribute(): string
    {
        $baseUrl = request()->getSchemeAndHttpHost() . '/api/storage/';

        return $this->profile_image_path
            ? $baseUrl . $this->profile_image_path
            : 'https://ui-avatars.com/api/?name=' . urlencode($this->name ?? 'S') . '&background=6366f1&color=ffffff';
    }

    // ── Relationships ──────────────────────────────────────────

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function faculty(): BelongsTo
    {
        return $this->belongsTo(Faculty::class);
    }

    public function major(): BelongsTo
    {
        return $this->belongsTo(Major::class);
    }

    public function schedule(): BelongsTo
    {
        return $this->belongsTo(Schedule::class);
    }

    public function shift(): BelongsTo
    {
        return $this->belongsTo(Shift::class);
    }

    public function academicClass(): BelongsTo
    {
        return $this->belongsTo(AcademicClass::class);
    }

    // ── Firestore Relationship Helpers ─────────────────────────

    public function getScheduleRelation()
    {
        if (static::useFirestore() && $this->schedule_id) {
            $scheduleRepo = new FirestoreScheduleRepository(new FirestoreService());
            $schedule = $scheduleRepo->find($this->schedule_id);
            if ($schedule) {
                $model = new Schedule();
                $model->fill($schedule);
                $model->id = $schedule['id'];
                $model->exists = true;
                return $model;
            }
        }
        return $this->schedule;
    }

    public function getFacultyRelation()
    {
        if (static::useFirestore() && $this->faculty_id) {
            $facultyRepo = new FirestoreFacultyRepository(new FirestoreService());
            $faculty = $facultyRepo->find($this->faculty_id);
            if ($faculty) {
                $model = new Faculty();
                $model->fill($faculty);
                $model->id = $faculty['id'];
                $model->exists = true;
                return $model;
            }
        }
        return $this->faculty;
    }

    public function getMajorRelation()
    {
        if (static::useFirestore() && $this->major_id) {
            $majorRepo = new FirestoreMajorRepository(new FirestoreService());
            $major = $majorRepo->find($this->major_id);
            if ($major) {
                $model = new Major();
                $model->fill($major);
                $model->id = $major['id'];
                $model->exists = true;
                return $model;
            }
        }
        return $this->major;
    }

    public function getShiftRelation()
    {
        if (static::useFirestore() && $this->shift_id) {
            $shiftRepo = new FirestoreShiftRepository(new FirestoreService());
            $shift = $shiftRepo->find($this->shift_id);
            if ($shift) {
                $model = new Shift();
                $model->fill($shift);
                $model->id = $shift['id'];
                $model->exists = true;
                return $model;
            }
        }
        return $this->shift;
    }

    public function getAcademicClassRelation()
    {
        if (static::useFirestore() && $this->academic_class_id) {
            $classRepo = new FirestoreAcademicClassRepository(new FirestoreService());
            $class = $classRepo->find($this->academic_class_id);
            if ($class) {
                $model = new AcademicClass();
                $model->fill($class);
                $model->id = $class['id'];
                $model->exists = true;
                return $model;
            }
        }
        return $this->academic_class;
    }
}
