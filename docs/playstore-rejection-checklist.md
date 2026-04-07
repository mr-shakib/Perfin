# Google Play Rejection Risk Checklist (PerFin)

Last reviewed: 2026-04-07

Use this before every Play Console submission. Each item includes why rejection can happen.

## 1) High-Risk Items Found In This Codebase Now

- [ ] **Replace "coming soon" Terms/Privacy links with real, accessible pages**  
  Why rejected: user data policy expects real privacy disclosures; placeholder legal links are a red flag during review.  
  Evidence: `lib/screens/auth/widgets/signup_buttons.dart` (shows `Terms & Conditions coming soon!` and `Privacy Policy coming soon!`).

- [ ] **Fix privacy claim mismatch for AI processing**  
  Why rejected: deceptive/misleading claims if app says data is processed locally while it is sent to external APIs.  
  Evidence: `lib/screens/profile/privacy_settings_screen.dart` says AI is local; `lib/services/ai_service.dart` sends data to `https://api.groq.com/openai/v1`.

- [ ] **Ensure true account deletion (account + associated data), not only local table cleanup**  
  Why rejected: account deletion policy requires full account deletion flow. Deactivation/logout alone is not enough.  
  Evidence: `lib/screens/profile/widgets/account_deletion_dialog.dart` deletes app tables then logs out, but does not clearly delete auth account identity itself.

- [ ] **Add outside-app account deletion web URL in Play Console**  
  Why rejected: for apps with in-app account creation, Google requires deletion initiation from inside and outside the app.

## 2) User Data / Privacy / Declarations

- [ ] **Publish a public, non-geofenced privacy policy URL in Play Console**  
  Why rejected: missing or inaccessible privacy policy.

- [ ] **Show privacy policy link/text inside the app**  
  Why rejected: policy requires in-app access to privacy policy (not Play listing only).

- [ ] **Complete Data safety form accurately** (collection, sharing, processing, retention/deletion)  
  Why rejected: inaccurate Data safety declarations are common enforcement/rejection reasons.

- [ ] **Match Data safety answers with real app behavior** (Supabase auth/profile, AI prompts, notifications, analytics if added)  
  Why rejected: mismatch between declared and observed behavior.

- [ ] **Use in-context permission prompts and consent language**  
  Why rejected: permissions must be necessary for promoted features and requested in context.

## 3) Financial + AI Specific Risks (Important for PerFin)

- [ ] **Submit Financial features declaration in Play Console**  
  Why rejected: any app with financial features must complete this declaration.

- [ ] **Avoid misleading financial claims** (guaranteed savings, guaranteed outcomes, etc.)  
  Why rejected: deceptive behavior / misleading metadata.

- [ ] **Add clear AI limitation wording** (educational info, not professional financial/tax/investment advice)  
  Why rejected: risky financial guidance without proper framing can trigger policy/legal concerns.

- [ ] **Add AI safety handling** (block harmful/offensive/deceptive outputs)  
  Why rejected: generative AI features are developer responsibility under AI-generated content policy.

## 4) Store Listing & Metadata

- [ ] **Ensure screenshots, title, short description, and full description exactly match actual app functionality**  
  Why rejected: deceptive metadata.

- [ ] **Avoid unverifiable superlatives** ("best", "100% accurate", "guaranteed")  
  Why rejected: misleading claims.

- [ ] **Complete content rating questionnaire honestly**  
  Why rejected: missing or inaccurate ratings can lead to removal/rejection.

- [ ] **If login is required, provide working reviewer credentials + steps in Play Console App Access**  
  Why rejected: reviewers cannot test restricted flows without valid reusable credentials.

## 5) App Functionality / Technical Quality

- [ ] **No crash/freeze/blockers on first launch, signup, login, dashboard, add transaction, AI chat**  
  Why rejected: broken functionality policy.

- [ ] **Verify runtime behavior on real devices (Android 13/14/15), not emulator only**  
  Why rejected: device-specific breakage during review.

- [ ] **Target API level meets current Play requirement at submission time**  
  Why rejected: API level non-compliance blocks publishing.

- [ ] **Ensure release signing is correct** (`key.properties` present, not fallback debug signing)  
  Why rejected/blocked: upload/update issues and release integrity concerns.

- [ ] **Request only necessary permissions** (`POST_NOTIFICATIONS` only if user-facing feature requires it)  
  Why rejected: unnecessary sensitive/special access requests.

## 6) Final Pre-Submit Pass

- [ ] Build release artifact and smoke test it end-to-end.
- [ ] Re-check every declaration field in Play Console (Data safety, App access, Financial features, Content rating).
- [ ] Confirm privacy policy and account deletion URLs are live and correct.
- [ ] Confirm store listing text does not over-promise features.

## Official Policy References

- User Data policy (privacy policy, Data safety, account deletion): https://support.google.com/googleplay/android-developer/answer/10144311?hl=en
- Permissions & sensitive APIs: https://support.google.com/googleplay/android-developer/answer/16558241?hl=en
- Financial Services policy + declaration: https://support.google.com/googleplay/android-developer/answer/9876821?hl=en
- Deceptive behavior policy: https://support.google.com/googleplay/android-developer/answer/16680223?hl=en
- Target API requirements: https://support.google.com/googleplay/android-developer/answer/11926878?hl=en
- App access login credentials requirements: https://support.google.com/googleplay/android-developer/answer/15748846?hl=en
- AI-generated content policy overview: https://support.google.com/googleplay/android-developer/answer/14094294?hl=en
- Functionality/content/user experience policy: https://support.google.com/googleplay/android-developer/answer/9898783?hl=en
