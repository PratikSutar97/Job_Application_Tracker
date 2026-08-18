-- Job Ledger / Supabase setup
-- Run this in the Supabase SQL Editor.
-- Never put the service_role key in browser code.

create extension if not exists pgcrypto;

create table if not exists public.job_applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  company text not null,
  role text not null,
  date_applied date not null default current_date,
  status text not null default 'Applied'
    check (status in ('Applied','Interviewing','Offer','Rejected')),
  status_updated_at date not null default current_date,
  link text,
  resume_version text,
  cover_letter_notes text,
  notes text,
  archived boolean not null default false,
  logs jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists job_applications_user_id_idx on public.job_applications(user_id);
create index if not exists job_applications_user_date_idx on public.job_applications(user_id, date_applied desc);

alter table public.job_applications enable row level security;

drop policy if exists "Users can view own applications" on public.job_applications;
create policy "Users can view own applications" on public.job_applications for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists "Users can insert own applications" on public.job_applications;
create policy "Users can insert own applications" on public.job_applications for insert to authenticated with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update own applications" on public.job_applications;
create policy "Users can update own applications" on public.job_applications for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

drop policy if exists "Users can delete own applications" on public.job_applications;
create policy "Users can delete own applications" on public.job_applications for delete to authenticated using ((select auth.uid()) = user_id);

grant select, insert, update, delete on public.job_applications to authenticated;

create or replace function public.set_job_applications_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

drop trigger if exists job_applications_updated_at on public.job_applications;
create trigger job_applications_updated_at before update on public.job_applications for each row execute function public.set_job_applications_updated_at();
