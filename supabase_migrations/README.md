# Supabase Migrations

This directory contains database migration scripts for the Perfin application.

## Migration Files

### 001_add_main_app_features.sql

This migration adds support for the main app features including:

**New Tables:**
- `goals` - Financial goals with target amounts and deadlines
- `chat_messages` - AI Copilot conversation history
- `notification_preferences` - User notification settings

**Extended Tables:**
- `transactions` - Added `is_synced` and `linked_goal_id` fields
- `budgets` - Added `is_active` field

## How to Apply Migrations

### Option 1: Using Supabase Dashboard

1. Log in to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Copy the contents of the migration file
4. Paste and execute the SQL

### Option 2: Using Supabase CLI

```bash
# If you have Supabase CLI installed
supabase db push
```

### Option 3: Manual Execution

```bash
# Connect to your Supabase database and run:
psql -h <your-supabase-host> -U postgres -d postgres -f supabase_migrations/001_add_main_app_features.sql
```

## Migration Order

Migrations should be applied in numerical order:
1. First, ensure the base schema from `supabase_setup.sql` is applied
2. Then apply `001_add_main_app_features.sql`

## Row Level Security (RLS)

All tables have Row Level Security enabled to ensure users can only access their own data. The policies are automatically created by the migration scripts.

## Indexes

The migrations create indexes on frequently queried columns to optimize performance:
- User ID indexes for all tables
- Date indexes for time-based queries
- Status indexes for filtering

## Rollback

If you need to rollback this migration, you can drop the new tables:

```sql
DROP TABLE IF EXISTS goals CASCADE;
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS notification_preferences CASCADE;

-- Remove added columns from existing tables
ALTER TABLE transactions DROP COLUMN IF EXISTS is_synced;
ALTER TABLE transactions DROP COLUMN IF EXISTS linked_goal_id;
ALTER TABLE budgets DROP COLUMN IF EXISTS is_active;
```

**Warning:** This will permanently delete all data in these tables. Make sure to backup your data before rolling back.

## Local Database Schema

The local SQLite schema is defined in `lib/database/local_schema.sql` and is used for offline support. This schema is automatically created by the app on first run and is not synced to Supabase.
