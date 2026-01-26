# Signup Troubleshooting Guide

## Common Issues and Solutions

### Issue 1: Database Tables Not Created
**Symptom**: Signup button does nothing or shows error about missing tables

**Solution**:
1. Go to your Supabase dashboard: https://supabase.com/dashboard/project/qtsamrmwknmqghqfamho
2. Click on "SQL Editor" in the left sidebar
3. Click "New query"
4. Copy the entire contents of `supabase_setup.sql` file
5. Paste into the SQL editor
6. Click "Run" button
7. You should see "Success. No rows returned"

### Issue 2: Email Already Exists
**Symptom**: Error message "An account with this email already exists"

**Solution**:
- Use a different email address, OR
- Delete the existing user from Supabase:
  1. Go to Authentication → Users in Supabase dashboard
  2. Find the user with that email
  3. Click the three dots → Delete user

### Issue 3: Network/Connection Error
**Symptom**: Error about network or connection timeout

**Solution**:
- Check your internet connection
- Verify Supabase project is not paused (free tier projects pause after inactivity)
- Check Supabase credentials in `lib/config/supabase_config.dart`

### Issue 4: Password Too Weak
**Symptom**: Error "Password is too weak" or "Password must be at least 6 characters"

**Solution**:
- Use a password with at least 6 characters
- Supabase requires minimum 6 characters by default

## How to Test Signup

### Step 1: Verify Database Setup
Run this query in Supabase SQL Editor to check if tables exist:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'transactions', 'budgets');
```

You should see 3 rows returned.

### Step 2: Test Signup Flow
1. Open the app
2. Complete onboarding (if first time)
3. Click "Sign Up" on login screen
4. Fill in:
   - Name: Test User
   - Email: test@example.com (use a unique email)
   - Password: password123
   - Confirm Password: password123
5. Check "I agree to Terms & Conditions"
6. Click "Sign Up"
7. Watch for:
   - "Creating account..." message
   - Success → Redirects to onboarding
   - Error → Shows error message in red snackbar

### Step 3: Verify in Supabase
1. Go to Supabase dashboard → Authentication → Users
2. You should see the new user listed
3. Go to Table Editor → profiles
4. You should see a profile record with the user's name

## Updated Error Handling

I've updated both login and signup screens to:
- ✅ Show loading indicator during authentication
- ✅ Display error messages from Supabase
- ✅ Show specific error for each failure case

## Error Messages You Might See

| Error Message | Cause | Solution |
|--------------|-------|----------|
| "An account with this email already exists" | Email already registered | Use different email or delete existing user |
| "Invalid email format" | Email format is wrong | Check email has @ and domain |
| "Password must be at least 6 characters" | Password too short | Use longer password |
| "Sign up failed: ..." | Database/network issue | Check database setup and internet |
| "Failed to save session: ..." | Local storage issue | Clear app data and try again |

## Debug Mode

To see detailed error messages, check the console/logs when signup fails. The error will show:
- Supabase error message
- Stack trace
- Network request details

## Quick Test Checklist

- [ ] Supabase project is active (not paused)
- [ ] SQL script has been run (tables created)
- [ ] Internet connection is working
- [ ] Using unique email address
- [ ] Password is at least 6 characters
- [ ] Terms checkbox is checked
- [ ] Error messages are now visible in app

## Still Not Working?

If signup still doesn't work after checking all above:

1. **Check Supabase Logs**:
   - Go to Supabase dashboard → Logs
   - Look for authentication errors
   - Check for database errors

2. **Test Supabase Connection**:
   - Try creating a user manually in Supabase dashboard
   - Authentication → Add user
   - If this works, the issue is in the app code

3. **Check Console Output**:
   - Look for error messages in the terminal/console
   - Share the error message for further help

4. **Verify Credentials**:
   - Check `lib/config/supabase_config.dart`
   - Ensure URL and anon key are correct
   - URL should be: https://qtsamrmwknmqghqfamho.supabase.co

## Next Steps After Successful Signup

Once signup works:
1. User is created in Supabase Auth
2. Profile is created in profiles table
3. User is automatically logged in
4. Redirected to onboarding flow
5. Can log in again with same credentials
