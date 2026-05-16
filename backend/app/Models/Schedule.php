<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use App\Traits\SyncsToFirestore;
use App\Services\FirestoreService;
use App\Repositories\FirestoreScheduleRepository;

class Schedule extends Model
{

    protected $fillable = [
        'name',
        'day_of_the_week',
        'start_time',
        'end_time',
        'start_date',
        'end_date',
        'class_id',
        'teacher_id',
        'subject_id',
        'room_id',
        'syllabus_id',
    ];

    /**
     * Keep start_time / end_time as raw strings (H:i:s) to avoid timezone
     * ambiguity with MySQL TIME columns. Use Carbon::parse() explicitly when
     * formatting is needed. start_date / end_date are proper dates.
     */
    protected $casts = [
        'start_time' => 'string',
        'end_time'   => 'string',
        'start_date' => 'date',
        'end_date'   => 'date',
    ];

    protected static $firestoreRepo;

    // ── Firestore Integration ─────────────────────────────────

    public static function getFirestoreRepository()
    {
        if (!static::$firestoreRepo) {
            static::$firestoreRepo = new FirestoreScheduleRepository(new FirestoreService());
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

    // ── Relationships ──────────────────────────────────────────────────────────

    public function syllabus(): BelongsTo
    {
        return $this->belongsTo(Syllabus::class);
    }

    public function teacher(): BelongsTo
    {
        return $this->belongsTo(Teacher::class);
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    /** The class group assigned to this time slot. */
    public function academicClass(): BelongsTo
    {
        return $this->belongsTo(AcademicClass::class, 'class_id');
    }

    public function room(): BelongsTo
    {
        return $this->belongsTo(Room::class);
    }

    /** All attendance sessions that were run under this schedule slot. */
    public function attendanceSessions(): HasMany
    {
        return $this->hasMany(AttendanceSession::class);
    }

    // ── Scopes ────────────────────────────────────────────────────────────────

    /**
     * Filter schedules for a specific day of the week.
     * Accepts "Monday", "monday", etc. (case-insensitive).
     */
    public function scopeForDay($query, string $day)
    {
        if (static::useFirestore()) {
            $data = static::getFirestoreRepository()->forDay($day);
            return $data->map(function ($item) {
                $model = new static();
                $model->fill($item);
                $model->id = $item['id'];
                $model->exists = true;
                return $model;
            });
        }
        return $query->whereRaw('LOWER(day_of_the_week) = ?', [strtolower($day)]);
    }

    /**
     * Filter schedules active on a given date (within start_date..end_date range).
     */
    public function scopeActiveOn($query, string $date)
    {
        if (static::useFirestore()) {
            $data = static::getFirestoreRepository()->activeOn($date);
            return $data->map(function ($item) {
                $model = new static();
                $model->fill($item);
                $model->id = $item['id'];
                $model->exists = true;
                return $model;
            });
        }
        return $query->where(function ($q) use ($date) {
            $q->whereNull('start_date')->orWhere('start_date', '<=', $date);
        })->where(function ($q) use ($date) {
            $q->whereNull('end_date')->orWhere('end_date', '>=', $date);
        });
    }

    /**
     * Find schedules whose time range overlaps with [start, end].
     * Uses the standard overlap formula: existing.start < new.end AND existing.end > new.start
     */
    public function scopeOverlapping($query, string $start, string $end, ?int $excludeId = null)
    {
        if (static::useFirestore()) {
            $data = static::getFirestoreRepository()->overlapping($start, $end, $excludeId);
            return $data->map(function ($item) {
                $model = new static();
                $model->fill($item);
                $model->id = $item['id'];
                $model->exists = true;
                return $model;
            });
        }
        return $query
            ->where('start_time', '<', $end)
            ->where('end_time',   '>', $start)
            ->when($excludeId, fn($q) => $q->where('id', '!=', $excludeId));
    }

    /**
     * Filter to schedules belonging to a specific teacher.
     */
    public function scopeForTeacher($query, int $teacherId)
    {
        if (static::useFirestore()) {
            $data = static::getFirestoreRepository()->forTeacher($teacherId);
            return $data->map(function ($item) {
                $model = new static();
                $model->fill($item);
                $model->id = $item['id'];
                $model->exists = true;
                return $model;
            });
        }
        return $query->where('teacher_id', $teacherId);
    }

    // ── Accessors ─────────────────────────────────────────────────────────────

    /**
     * Human-readable time range string: "08:00 - 10:00"
     */
    public function getTimeRangeAttribute(): string
    {
        if ($this->start_time && $this->end_time) {
            return substr($this->start_time, 0, 5) . ' - ' . substr($this->end_time, 0, 5);
        }
        return '—';
    }

    /**
     * Full display label: "Schedule Name (Monday: 08:00-10:00)"
     */
    public function getFullDisplayAttribute(): string
    {
        $display = (string)($this->name ?? '—');

        if ($this->day_of_the_week) {
            $display .= " ({$this->day_of_the_week}";

            if ($this->start_time && $this->end_time) {
                $display .= ': ' . substr($this->start_time, 0, 5) . '-' . substr($this->end_time, 0, 5);
            }

            $display .= ')';
        }

        return $display;
    }
}
