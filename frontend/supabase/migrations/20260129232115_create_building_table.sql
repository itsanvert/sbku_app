CREATE TABLE building (
    id TEXT PRIMARY KEY,
    building_name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);