create table years (
  id text primary key,
  year_name text not null unique,
  created_at timestamptz default now()
);
