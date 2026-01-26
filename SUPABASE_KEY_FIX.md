# Supabase Key Format Fix

## Issue
Getting "invalid API key" error during signup.

## Root Cause
Supabase has introduced a new key format:
- **Old format**: JWT tokens starting with `eyJ...` (200+ characters)
- **New format**: Shorter keys like `sb_publishable_...` and `sb_secret_...`

The older version of `supabase_flutter` package didn't support the new key format.

## Solution Applied

### 1. Updated `.env` with Correct Keys
```env
SUPABASE_URL=https://qtsamrmwknmqghqfamho.supabase.co
SUPABASE_ANON_KEY=sb_publishable_M0v3oKrSotSrFn9QZ4h3iw_1zRXhOxP
SUPABASE_SERVICE_ROLE_KEY=sb_secret__9DC4WezQHD9eF2555bfXQ_5F4zYBfEm
```

### 2. Updated Supabase Package
Changed from `supabase_flutter: ^2.8.0` to `supabase_flutter: ^2.9.1`

The newer version supports both key formats.

## Your Supabase Keys

### Anon Key (Public - Safe for Client)
```
sb_publishable_M0v3oKrSotSrFn9QZ4h3iw_1zRXhOxP
```
- ✅ Use this in the Flutter app
- ✅ Safe to expose in mobile apps
- ✅ Protected by Row Level Security

### Service Role Key (Secret - Backend Only)
```
sb_secret__9DC4WezQHD9eF2555bfXQ_5F4zYBfEm
```
- ❌ NEVER use in client-side code
- ❌ Bypasses all security rules
- ✅ Only for backend/admin operations

## Next Steps

1. **Restart the app** - The new keys should now work
2. **Try signup again** - Should work without "invalid API key" error
3. **If still failing**, check if you need to run the SQL setup script

## Verify Setup

Run this in Supabase SQL Editor to check if tables exist:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'transactions', 'budgets');
```

If no tables are returned, run the `supabase_setup.sql` script.

## Testing Signup

1. Open app
2. Complete onboarding (if first time)
3. Go to signup screen
4. Fill in details:
   - Name: Test User
   - Email: test@example.com
   - Password: password123
   - Confirm: password123
5. Check "I agree to Terms"
6. Click "Sign Up"
7. Should see "Creating account..." then redirect to onboarding

## Common Errors After This Fix

### "relation 'profiles' does not exist"
**Solution**: Run `supabase_setup.sql` in Supabase SQL Editor

### "Email already exists"
**Solution**: Use a different email or delete the user from Supabase dashboard

### Still getting "invalid API key"
**Solution**: 
1. Verify keys in `.env` match your Supabase dashboard
2. Run `flutter clean` then `flutter pub get`
3. Restart the app completely

## Key Format Comparison

### Old Format (JWT)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF0c2Ftcm13a25tcWdocWZhbWhvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4OTI4NzAsImV4cCI6MjA1MzQ2ODg3MH0.xxxxxxxxxx
```
- Very long (200+ chars)
- JWT token format
- Still supported

### New Format (Simplified)
```
sb_publishable_M0v3oKrSotSrFn9QZ4h3iw_1zRXhOxP
```
- Shorter and cleaner
- Easier to read and manage
- Requires supabase_flutter ^2.9.0+

Both formats work, but newer Supabase projects use the simplified format.

## Status
✅ Keys updated in `.env`
✅ Package updated to support new format
✅ Ready to test signup!
