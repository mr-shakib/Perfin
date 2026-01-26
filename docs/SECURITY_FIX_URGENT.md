# 🚨 URGENT: Security Fix Required

## Issue
GitHub detected exposed secrets in your repository:
- Google API Key in `android/app/google-services.json`
- Potentially other sensitive credentials

## Immediate Actions Required

### Step 1: Add Sensitive Files to .gitignore

Run these commands in your terminal:

```bash
# Add sensitive files to .gitignore
echo "android/app/google-services.json" >> .gitignore
echo "ios/Runner/GoogleService-Info.plist" >> .gitignore
echo ".env" >> .gitignore

# Commit the updated .gitignore
git add .gitignore
git commit -m "Add sensitive files to .gitignore"
```

### Step 2: Remove Sensitive Files from Git History

**Option A: Using git filter-repo (Recommended)**

```bash
# Install git-filter-repo
pip install git-filter-repo

# Remove the sensitive file from all history
git filter-repo --path android/app/google-services.json --invert-paths

# Force push to GitHub
git push origin --force --all
```

**Option B: Using BFG Repo-Cleaner**

```bash
# Download BFG from https://rtyley.github.io/bfg-repo-cleaner/
# Then run:
java -jar bfg.jar --delete-files google-services.json

# Clean up
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push
git push origin --force --all
```

**Option C: Simple but Less Secure (if repo is new)**

```bash
# Remove from current commit
git rm --cached android/app/google-services.json
git rm --cached .env
git commit -m "Remove sensitive files"
git push
```

⚠️ **Note**: Option C doesn't remove from history, only from current state.

### Step 3: Rotate All Exposed Credentials

#### Google API Keys
1. Go to Google Cloud Console: https://console.cloud.google.com/
2. Navigate to **APIs & Services** → **Credentials**
3. Find the exposed API key
4. Click **Delete** or **Regenerate**
5. Download new `google-services.json`
6. Place it locally (don't commit!)

#### Supabase Keys
1. Go to Supabase Dashboard: https://supabase.com/dashboard/project/qtsamrmwknmqghqfamho/settings/api
2. Click **Reset** on both keys:
   - Anon/Public key
   - Service role key
3. Update your local `.env` file with new keys
4. **Don't commit** the `.env` file

#### Firebase Keys (if using)
1. Go to Firebase Console
2. Project Settings → Service Accounts
3. Generate new keys
4. Update local files only

### Step 4: Update .gitignore (Already Done)

Your `.gitignore` should include:

```gitignore
# Environment variables
.env
.env.local
.env.*.local

# Firebase/Google Services
android/app/google-services.json
ios/Runner/GoogleService-Info.plist

# Supabase (if you have local config)
supabase/.env

# Other sensitive files
*.key
*.pem
*.p12
*.keystore
!debug.keystore
```

### Step 5: Verify Cleanup

```bash
# Check what's tracked by git
git ls-files | grep -E "(google-services|\.env|\.key)"

# Should return nothing if cleanup was successful
```

### Step 6: Set Up Secrets Properly

#### For Local Development
1. Keep `.env` file locally (already in .gitignore)
2. Share credentials securely (encrypted chat, password manager)
3. Never commit sensitive files

#### For CI/CD (GitHub Actions)
1. Go to GitHub repo → Settings → Secrets and variables → Actions
2. Add secrets:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `GOOGLE_SERVICES_JSON` (base64 encoded)

Example GitHub Action:
```yaml
- name: Create google-services.json
  run: |
    echo "${{ secrets.GOOGLE_SERVICES_JSON }}" | base64 -d > android/app/google-services.json
```

## Files That Should NEVER Be Committed

### ❌ Never Commit:
- `.env` files
- `google-services.json`
- `GoogleService-Info.plist`
- API keys, tokens, passwords
- Private keys (`.key`, `.pem`, `.p12`)
- Keystore files (except debug.keystore)
- Database credentials
- OAuth secrets

### ✅ Safe to Commit:
- `.env.example` (template without real values)
- `google-services.json.example` (template)
- Public configuration files
- Code and assets

## Prevention for Future

### 1. Use Pre-commit Hooks

Install `git-secrets`:
```bash
# Install git-secrets
brew install git-secrets  # macOS
# or
apt-get install git-secrets  # Linux

# Set up in your repo
git secrets --install
git secrets --register-aws
```

### 2. Use GitHub Secret Scanning

Already enabled! GitHub will alert you when secrets are detected.

### 3. Review Before Committing

Always check what you're committing:
```bash
git diff --cached
```

### 4. Use .gitignore Templates

Start with a good template:
```bash
curl https://raw.githubusercontent.com/github/gitignore/main/Flutter.gitignore > .gitignore
```

## Current Status

- [x] `.env` added to .gitignore
- [ ] Remove `google-services.json` from git history
- [ ] Rotate Google API keys
- [ ] Rotate Supabase keys
- [ ] Verify cleanup
- [ ] Set up GitHub secrets for CI/CD

## Quick Commands Summary

```bash
# 1. Update .gitignore
echo "android/app/google-services.json" >> .gitignore
echo ".env" >> .gitignore
git add .gitignore
git commit -m "Update .gitignore for security"

# 2. Remove from current state
git rm --cached android/app/google-services.json
git rm --cached .env
git commit -m "Remove sensitive files"

# 3. Push changes
git push

# 4. Rotate all keys in respective dashboards
# 5. Update local files with new keys
# 6. Never commit them again!
```

## Need Help?

If you're unsure about any step:
1. **Don't panic** - the keys can be rotated
2. **Act quickly** - rotate keys ASAP
3. **Ask for help** - security is important

## Resources

- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
- [git-filter-repo](https://github.com/newren/git-filter-repo)
- [Removing Sensitive Data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
