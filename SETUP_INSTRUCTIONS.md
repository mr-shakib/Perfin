# PerFin Setup Instructions

## Quick Start

### 1. Get Supabase Credentials

Your current `.env` file has placeholder/invalid Supabase credentials. To fix the login issue:

1. **Go to Supabase**: https://supabase.com
2. **Sign in** or create a free account
3. **Create a new project** (or use existing)
4. **Get your credentials**:
   - Go to: Project Settings → API
   - Copy the following:
     - **Project URL** (e.g., `https://xxxxx.supabase.co`)
     - **anon/public key** (starts with `eyJ`, very long ~200 characters)

### 2. Update .env File

Replace the values in your `.env` file:

```env
SUPABASE_URL=https://your-actual-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your-actual-long-key-here...
```

### 3. Run Database Migrations

Execute the SQL in `supabase_setup.sql` in your Supabase SQL Editor:

1. Go to your Supabase project
2. Click on "SQL Editor" in the left sidebar
3. Copy and paste the contents of `supabase_setup.sql`
4. Click "Run"

### 4. Rebuild and Run

```bash
flutter clean
flutter pub get
flutter run
```

## Alternative: Local-Only Mode (No Cloud)

If you don't want to use Supabase at all, the app will automatically detect invalid credentials and skip cloud features. You can:

1. Keep the placeholder credentials in `.env`
2. The app will work in local-only mode
3. All data is stored locally on the device
4. No cloud sync or authentication

## Troubleshooting

### "Failed host lookup" Error

This means:
- Your Supabase credentials are invalid/placeholder
- OR you have no internet connection
- OR the Supabase URL is wrong

**Solution**: Follow steps 1-4 above to set up real Supabase credentials.

### App Works But No Login

The app now detects invalid Supabase credentials and skips cloud features automatically. Check the console logs for:
- `✓ Supabase initialized successfully` (good)
- `⚠ Skipping Supabase - Invalid credentials detected` (needs setup)

## Features Available

### With Supabase (Cloud Mode):
- ✅ User authentication (login/signup)
- ✅ Cloud data sync
- ✅ Multi-device access
- ✅ Data backup

### Without Supabase (Local Mode):
- ✅ Transaction tracking
- ✅ Budget management
- ✅ Goal setting
- ✅ AI insights (if GROQ_API_KEY is set)
- ✅ All local features
- ❌ No cloud sync
- ❌ No multi-device access

## Need Help?

Check the console output when running the app. It will show:
- Whether Supabase initialized successfully
- Whether storage initialized
- Any errors during startup
