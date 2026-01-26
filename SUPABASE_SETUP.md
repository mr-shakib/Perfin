# Supabase Authentication Setup Guide

This guide explains how to set up Supabase authentication for the PerFin app.

## Prerequisites

- Supabase account (sign up at https://supabase.com)
- Flutter development environment set up

## Setup Steps

### 1. Supabase Project Setup

Your Supabase project is already configured with:
- **URL**: `https://qtsamrmwknmqghqfamho.supabase.co`
- **Anon Key**: Already configured in `lib/config/supabase_config.dart`

### 2. Database Setup

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor** in the left sidebar
3. Create a new query
4. Copy and paste the contents of `supabase_setup.sql`
5. Click **Run** to execute the SQL script

This will create:
- `profiles` table for user profile data
- `transactions` table for financial transactions (for future use)
- `budgets` table for budget management (for future use)
- Row Level Security (RLS) policies to protect user data
- Indexes for better performance
- Triggers for automatic timestamp updates

### 3. Email Authentication Configuration

1. In your Supabase dashboard, go to **Authentication** → **Providers**
2. Ensure **Email** provider is enabled
3. Configure email settings:
   - **Enable email confirmations**: Optional (disable for development)
   - **Secure email change**: Recommended for production
   - **Secure password change**: Recommended for production

### 4. Test the Setup

Run the app and try:

1. **Sign Up**:
   - Open the app
   - Navigate to Sign Up screen
   - Enter name, email, and password
   - Click "Sign Up"
   - Check Supabase dashboard → Authentication → Users to see the new user

2. **Sign In**:
   - Use the credentials you just created
   - Click "Login"
   - You should be authenticated and redirected to the dashboard

3. **Sign Out**:
   - Click logout (when implemented)
   - You should be redirected to the login screen

## How It Works

### Authentication Flow

1. **Sign Up**:
   - User enters name, email, and password
   - App calls `AuthService.signUp()`
   - Supabase creates user in `auth.users` table
   - App creates profile in `profiles` table
   - User is automatically signed in
   - Session is saved to local Hive storage

2. **Sign In**:
   - User enters email and password
   - App calls `AuthService.authenticate()`
   - Supabase validates credentials
   - App fetches user profile from `profiles` table
   - Session is saved to local Hive storage

3. **Session Persistence**:
   - On app start, `AuthProvider.restoreSession()` is called
   - First checks Supabase for active session
   - Falls back to local Hive storage if offline
   - User stays logged in across app restarts

4. **Sign Out**:
   - App calls `AuthService.signOut()`
   - Supabase session is cleared
   - Local Hive session is cleared
   - User is redirected to login screen

### Hybrid Storage Strategy

The app uses a hybrid approach:
- **Supabase**: Primary authentication and data storage
- **Hive**: Local cache for offline access

This provides:
- Real authentication with Supabase
- Offline capability with Hive
- Seamless user experience

## Troubleshooting

### "Invalid login credentials" error
- Check that the email and password are correct
- Verify the user exists in Supabase dashboard → Authentication → Users

### "An account with this email already exists" error
- The email is already registered
- Try signing in instead of signing up
- Or use a different email address

### Profile not found error
- Check that the `profiles` table exists
- Verify RLS policies are set up correctly
- Check that the profile was created during sign up

### Network errors
- Verify internet connection
- Check Supabase project URL and anon key in `lib/config/supabase_config.dart`
- Ensure Supabase project is not paused (free tier projects pause after inactivity)

## Security Notes

1. **Row Level Security (RLS)**: All tables have RLS enabled to ensure users can only access their own data

2. **Anon Key**: The anon key in the code is safe to expose in client apps - it's designed for this purpose

3. **Password Requirements**: Minimum 6 characters (enforced by Supabase)

4. **Email Confirmation**: Disabled for development, but should be enabled in production

## Next Steps

- [ ] Implement route guards to protect authenticated routes
- [ ] Add password reset functionality
- [ ] Implement data sync for transactions and budgets
- [ ] Add social authentication (Google, Apple)
- [ ] Enable email confirmation for production
- [ ] Add profile editing functionality

## Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
