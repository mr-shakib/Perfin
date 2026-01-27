# Environment Variables Setup

## Overview

The app now uses environment variables to manage sensitive credentials securely. This prevents accidentally committing secrets to version control.

## Files Created

### 1. `.env` (Git Ignored)
Contains actual credentials - **NEVER commit this file!**

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
```

### 2. `.env.example` (Version Controlled)
Template file showing what variables are needed without actual values.

### 3. `lib/config/supabase_config.dart` (Updated)
Now loads credentials from environment variables instead of hardcoded values.

## Setup Instructions

### For Development

1. **Copy the example file**:
   ```bash
   copy .env.example .env
   ```

2. **Fill in your credentials** in `.env`:
   - Get them from Supabase dashboard → Settings → API
   - Replace placeholder values with actual keys

3. **Run the app**:
   ```bash
   flutter pub get
   flutter run
   ```

### For New Team Members

1. Ask team lead for `.env` file or credentials
2. Place `.env` file in project root
3. Run `flutter pub get`
4. Start developing!

## Security Best Practices

### ✅ DO:
- Keep `.env` file in `.gitignore`
- Use `.env.example` to document required variables
- Share credentials securely (encrypted chat, password manager)
- Use different credentials for dev/staging/production
- Rotate keys regularly

### ❌ DON'T:
- Commit `.env` file to git
- Share credentials in plain text (email, Slack, etc.)
- Hardcode credentials in source code
- Use production keys in development
- Share service role key with client-side code

## Key Types Explained

### SUPABASE_ANON_KEY (Public/Anon Key)
- ✅ Safe to use in client-side code (Flutter app)
- ✅ Can be exposed in mobile apps
- ✅ Protected by Row Level Security (RLS)
- Used for: User authentication, data access with RLS

### SUPABASE_SERVICE_ROLE_KEY (Secret Key)
- ❌ NEVER use in client-side code
- ❌ NEVER commit to version control
- ❌ Bypasses Row Level Security
- Used for: Backend operations, admin tasks, migrations

## How It Works

### Before (Hardcoded):
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://...';
  static const String supabaseAnonKey = 'eyJhbGci...';
}
```
❌ Credentials visible in source code
❌ Committed to git history
❌ Hard to change per environment

### After (Environment Variables):
```dart
class SupabaseConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
}
```
✅ Credentials in `.env` file (git ignored)
✅ Easy to change per environment
✅ Secure and flexible

## Troubleshooting

### Error: "SUPABASE_URL not found in .env file"

**Cause**: `.env` file is missing or not loaded

**Solution**:
1. Check `.env` file exists in project root
2. Verify it's not empty
3. Ensure `flutter pub get` was run
4. Restart the app

### Error: "Unable to load asset: .env"

**Cause**: `.env` not listed in `pubspec.yaml` assets

**Solution**:
Already fixed! The `.env` file is listed in `pubspec.yaml`:
```yaml
assets:
  - assets/images/
  - assets/json/
  - .env
```

### Keys Not Working

**Cause**: Wrong keys or expired keys

**Solution**:
1. Go to Supabase dashboard → Settings → API
2. Copy fresh keys
3. Update `.env` file
4. Restart app

## Multiple Environments

### Development (.env)
```env
SUPABASE_URL=https://dev-project.supabase.co
SUPABASE_ANON_KEY=dev_key_here
```

### Staging (.env.staging)
```env
SUPABASE_URL=https://staging-project.supabase.co
SUPABASE_ANON_KEY=staging_key_here
```

### Production (.env.production)
```env
SUPABASE_URL=https://prod-project.supabase.co
SUPABASE_ANON_KEY=prod_key_here
```

Load different files:
```dart
await dotenv.load(fileName: ".env.production");
```

## CI/CD Integration

### GitHub Actions Example:
```yaml
- name: Create .env file
  run: |
    echo "SUPABASE_URL=${{ secrets.SUPABASE_URL }}" >> .env
    echo "SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}" >> .env
```

### Store secrets in:
- GitHub: Settings → Secrets and variables → Actions
- GitLab: Settings → CI/CD → Variables
- Bitbucket: Repository settings → Pipelines → Repository variables

## Verification

Check if environment variables are loaded:
```dart
void main() async {
  await dotenv.load(fileName: ".env");
  
  print('URL: ${dotenv.env['SUPABASE_URL']}');
  print('Key loaded: ${dotenv.env['SUPABASE_ANON_KEY'] != null}');
}
```

## Migration Checklist

- [x] Added `flutter_dotenv` package
- [x] Created `.env` file with credentials
- [x] Created `.env.example` template
- [x] Added `.env` to `.gitignore`
- [x] Updated `supabase_config.dart` to use env vars
- [x] Added `.env` to `pubspec.yaml` assets
- [x] Updated `main.dart` to load env file
- [x] Tested app with new configuration

## Your Credentials

Get your credentials from Supabase dashboard:
1. Go to your project at https://supabase.com/dashboard
2. Navigate to Settings → API
3. Copy your Project URL and anon/public key
4. Add them to your `.env` file

**Note**: Never share your service role key - it bypasses all security rules! 🔒

