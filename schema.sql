-- MyGoals: one table, one row per user (JSONB like ManageMe)
create table if not exists mygoals_data (
  user_id uuid references auth.users on delete cascade primary key,
  data jsonb default '{}',
  updated_at timestamptz default now()
);
alter table mygoals_data enable row level security;
drop policy if exists "own_mygoals_data" on mygoals_data;
create policy "own_mygoals_data" on mygoals_data for all using (auth.uid() = user_id);
create or replace function update_mygoals_ts()
returns trigger language plpgsql as $$
begin new.updated_at=now();return new;end;$$;
drop trigger if exists mygoals_ts on mygoals_data;
create trigger mygoals_ts before update on mygoals_data
  for each row execute procedure update_mygoals_ts();
select 'mygoals_data table ready' as status;
