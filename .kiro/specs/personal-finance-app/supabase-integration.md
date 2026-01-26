# Supabase Integration Specification

## Overview

This specification outlines the integration of Supabase for authentication and data synchronization while maintaining Hive for local storage. This hybrid approach provides:
- Real authentication via Supabase Auth
- Offline-first capability with Hive
- Background data sync to Supabase
- Seamless user experience

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Flutter App                          │
├─────────────────────────────────────────────────────────┤
│  UI Layer (Screens & Widgets)                           │
├─────────────────────────────────────────────────────────┤
│  Provider Layer (State Management)                       │
│  - AuthProvider                                          │
│  - TransactionProvider                                   │
│  - BudgetProvider                                        │
├─────────────────────────────────────────────────────────┤
│  Service Layer                                           │
│  - SupabaseAuthService (Authentication)                 │
│  - HiveStorageService (Local Storage)                   │
│  - SupabaseSyncService (Background Sync)                │
└─────────────────────────────────────────────────────────┘
         │                           │
         ▼                           ▼
   ┌──────────┐              ┌──────────────┐
   │ Supabase │              │ Local Hive   │
   │   Auth   │              │   Database   │
   └──────────┘              └──────────────┘
```

## Requirements

### 1. Supabase Setup

**Acceptance Criteria:**
1. Add `supabase_flutter` package to pubspec.yaml
2. Create Supabase project and obtain credentials
3. Store Supabase URL and anon key in environment variables or constants
4. Initialize Supabase client in main.dart before runApp()
5. Configure Supabase Auth with email/password provider

### 2. Authentication Service Integration

**Acceptance Criteria:**
1. Update AuthService to use Supabase Auth instead of mock authentication
2. Implement `signUp(email, password, name)` using Supabase Auth
3. Implement `signIn(email, password)` using Supabase Auth
4. Implement `signOut()` using Supabase Auth
5. Implement `getCurrentUser()` to get Supabase user
6. Store Supabase session in Hive for offline access
7. Handle Supabase auth errors and map to user-friendly messages
8. Implement password reset functionality

### 3. User Profile Management

**Acceptance Criteria:**
1. Create `profiles` table in Supabase with columns: id (uuid), user_id (uuid), name (text), created_at (timestamp)
2. After signup, create profile record in Supabase
3. Sync user profile to local Hive storage
4. Update User model to include Supabase user_id

### 4. Data Synchronization Strategy

**Acceptance Criteria:**
1. All data operations write to Hive first (offline-first)
2. After successful Hive write, queue sync operation
3. Background sync service pushes changes to Supabase when online
4. Handle sync conflicts (last-write-wins strategy)
5. Store sync status (pending, synced, failed) with each record

### 5. Supabase Database Schema

**Tables to create:**

```sql
-- Profiles table
CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Transactions table
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  category TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Budgets table
CREATE TABLE budgets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  category TEXT,
  year INTEGER NOT NULL,
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, category, year, month)
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own transactions" ON transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own transactions" ON transactions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own transactions" ON transactions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own transactions" ON transactions FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own budgets" ON budgets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own budgets" ON budgets FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own budgets" ON budgets FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own budgets" ON budgets FOR DELETE USING (auth.uid() = user_id);
```

### 6. Route Guards Implementation

**Acceptance Criteria:**
1. Create AuthGuard widget that checks Supabase auth state
2. Redirect to login if not authenticated
3. Allow access if authenticated
4. Listen to Supabase auth state changes
5. Update UI when auth state changes

### 7. Error Handling

**Acceptance Criteria:**
1. Map Supabase auth errors to user-friendly messages
2. Handle network errors gracefully
3. Show appropriate error messages for:
   - Invalid credentials
   - Email already exists
   - Weak password
   - Network timeout
   - Server errors

## Implementation Tasks

### Phase 1: Setup (30 min)
1. Add supabase_flutter package to pubspec.yaml
2. Create Supabase project at supabase.com
3. Copy project URL and anon key
4. Create constants file for Supabase credentials
5. Initialize Supabase in main.dart

### Phase 2: Authentication Service (1 hour)
1. Update AuthService to use Supabase Auth
2. Implement signUp with email/password
3. Implement signIn with email/password
4. Implement signOut
5. Implement session persistence
6. Add error handling

### Phase 3: Database Setup (30 min)
1. Create tables in Supabase SQL editor
2. Enable RLS policies
3. Test policies with sample data

### Phase 4: Route Guards (30 min)
1. Create AuthGuard widget
2. Wrap protected routes with AuthGuard
3. Test authentication flow

### Phase 5: Profile Management (30 min)
1. Create profile after signup
2. Sync profile to Hive
3. Update User model

### Phase 6: Testing (30 min)
1. Test signup flow
2. Test login flow
3. Test logout flow
4. Test route protection
5. Test offline behavior

## Environment Variables

Create a `.env` file (add to .gitignore):
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

Or create `lib/config/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

## Success Criteria

- [x] Users can sign up with email/password via Supabase
- [x] Users can log in with email/password via Supabase
- [x] Users can log out
- [x] Session persists across app restarts
- [ ] Protected routes redirect to login when not authenticated
- [x] User profile is created in Supabase after signup
- [x] Authentication errors show user-friendly messages
- [x] App works offline with Hive storage
- [ ] Data syncs to Supabase when online (future phase)

## Notes

- Start with authentication only
- Data sync (Phase 7) can be implemented later
- Focus on getting auth working first
- Keep Hive as primary storage for now
- Supabase will be used for auth and future sync
