<?php

namespace App\Providers;

use App\Actions\Jetstream\AddTeamMember;
use App\Actions\Jetstream\CreateTeam;
use App\Actions\Jetstream\DeleteTeam;
use App\Actions\Jetstream\DeleteUser;
use App\Actions\Jetstream\InviteTeamMember;
use App\Actions\Jetstream\RemoveTeamMember;
use App\Actions\Jetstream\UpdateTeamName;
use Illuminate\Support\ServiceProvider;
use Laravel\Jetstream\Jetstream;

class JetstreamServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        $this->configurePermissions();

        Jetstream::createTeamsUsing(CreateTeam::class);
        Jetstream::updateTeamNamesUsing(UpdateTeamName::class);
        Jetstream::addTeamMembersUsing(AddTeamMember::class);
        Jetstream::inviteTeamMembersUsing(InviteTeamMember::class);
        Jetstream::removeTeamMembersUsing(RemoveTeamMember::class);
        Jetstream::deleteTeamsUsing(DeleteTeam::class);
        Jetstream::deleteUsersUsing(DeleteUser::class);
    }

    /**
     * Configure the roles and permissions that are available within the application.
     */
    protected function configurePermissions(): void
    {
        Jetstream::defaultApiTokenPermissions(['read']);

        // Define permissions
        $allPermissions = [
            'manage-users',
            'manage-teachers',
            'manage-students',
            'manage-attendance',
            'create-sessions',
            'view-sessions',
            'view-reports',
            'read',
            'create',
            'update',
            'delete',
        ];

        Jetstream::role('super admin', 'Super Administrator', $allPermissions)
            ->description('Super Administrators can perform any action and manage the entire system.');

        Jetstream::role('admin', 'Administrator', [
            'manage-teachers',
            'manage-students',
            'manage-attendance',
            'create-sessions',
            'view-sessions',
            'view-reports',
            'read',
            'create',
            'update',
        ])->description('Administrators have the ability to manage school data and operations.');

        Jetstream::role('teacher', 'Teacher', [
            'manage-attendance',
            'view-attendance',
            'create-sessions',
            'view-sessions',
            'read',
            'update',
        ])->description('Teachers can create sessions and manage student attendance.');

        Jetstream::role('student', 'Student', [
            'view-attendance',
            'view-sessions',
            'read',
        ])->description('Students can view sessions and their own attendance records.');

        Jetstream::role('user', 'Standard User', [
            'read',
        ])->description('Standard users have basic read-only access.');
    }
}
