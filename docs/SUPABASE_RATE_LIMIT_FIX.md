# Remove Supabase Email Rate Limit

## Issue
Getting rate limit errors when testing signup multiple times.

## Solution 1: Disable Email Confirmation (Recommended for Development)

### Steps:
1. Go to Supabase Dashboard: https://supabase.com/dashboard/project/qtsamrmwknmqghqfamho
2. Click **Authentication** in left sidebar
3. Click **Providers** tab
4. Click on **Email** provider
5. Scroll to **"Confirm email"** setting
6. **Toggle it OFF** (disable)
7. Click **Save**

**Result**: Users can sign up instantly without email confirmation during development.

⚠️ **Important**: Re-enable this in production for security!

## Solution 2: Increase Rate Limits

### Steps:
1. Go to Supabase Dashboard
2. Click **Authentication** → **Rate Limits**
3. Adjust these settings:
   - **Email signups per hour**: Increase to 1000 (or higher)
   - **Email logins per hour**: Increase to 1000 (or higher)
   - **Password recovery per hour**: Increase to 100
4. Click **Save**

## Solution 3: Use Email Aliases for Testing

Instead of creating new emails, use Gmail aliases:

```
test+1@gmail.com
test+2@gmail.com
test+3@gmail.com
test+dev@gmail.com
test+staging@gmail.com
```

All these emails go to `test@gmail.com` but Supabase treats them as different users.

## Solution 4: Delete Test Users

Clean up test users to free up rate limit:

1. Go to **Authentication** → **Users**
2. Find test users
3. Click three dots → **Delete user**
4. Confirm deletion

## Recommended Settings for Development

### Email Provider Settings:
- ✅ **Enable Email Provider**: ON
- ❌ **Confirm email**: OFF (for development)
- ❌ **Secure email change**: OFF (for development)
- ❌ **Secure password change**: OFF (for development)

### Rate Limits:
- **Email signups per hour**: 1000
- **Email logins per hour**: 1000
- **Password recovery per hour**: 100

### For Production:
- ✅ **Confirm email**: ON
- ✅ **Secure email change**: ON
- ✅ **Secure password change**: ON
- **Rate limits**: Keep reasonable (100-500)

## Quick Test After Changes

1. Try signing up with: `test@example.com`
2. Should work instantly without email confirmation
3. Can sign up multiple times without rate limit

## Common Rate Limit Errors

### "Email rate limit exceeded"
**Cause**: Too many signups from same IP
**Solution**: Increase rate limit or wait 1 hour

### "For security purposes, you can only request this once every 60 seconds"
**Cause**: Rapid repeated requests
**Solution**: Wait 60 seconds between attempts

### "Email link is invalid or has expired"
**Cause**: Email confirmation enabled but link expired
**Solution**: Disable email confirmation for development

## Verification

After making changes:
1. Close and reopen your app
2. Try signing up with a new email
3. Should work instantly without errors
4. Check Supabase dashboard → Authentication → Users to see new user

## Current Project Settings

**Project URL**: https://qtsamrmwknmqghqfamho.supabase.co
**Dashboard**: https://supabase.com/dashboard/project/qtsamrmwknmqghqfamho

Navigate to:
- Authentication → Providers → Email (to disable confirmation)
- Authentication → Rate Limits (to increase limits)

## Status Checklist

- [ ] Disabled email confirmation
- [ ] Increased rate limits
- [ ] Tested signup with new email
- [ ] Verified user appears in dashboard
- [ ] No rate limit errors

## Notes

- These settings are per-project
- Changes take effect immediately
- No app restart needed
- Can be changed back anytime for production
