# Notification Test Guide

## How to Test Notifications

I've created a dedicated test screen that lets you send test notifications with a single tap!

### Step 1: Run the App

```bash
flutter run
```

### Step 2: Navigate to Test Screen

Once the app launches:

1. You'll see the home screen with a counter
2. Tap the **"Test Notifications"** button (purple button with bell icon)
3. This will open the Notification Test Screen

### Step 3: Send Test Notifications

The test screen has 7 different notification buttons:

#### 1. 🔵 Simple Test Notification
- Basic notification to verify the system works
- High priority
- Good first test!

#### 2. 🟠 Budget Warning (80%)
- Simulates budget at 80% utilization
- High priority
- Orange warning notification

#### 3. 🔴 Budget Exceeded (105%)
- Simulates budget exceeded by 5%
- **Critical priority** (highest)
- Red alert notification

#### 4. 🟣 Recurring Expense Reminder
- Simulates upcoming monthly rent payment
- Shows amount ($1,200) and days until due (3 days)
- Medium priority

#### 5. 🟢 Goal Deadline Alert
- Simulates being behind on a savings goal
- Shows required monthly savings to catch up
- High priority

#### 6. 🟠 Unusual Spending Alert
- Simulates detection of unusual spending pattern
- Shows explanation of the anomaly
- Medium priority

#### 7. 🔵 Scheduled Notification (10s)
- Schedules a notification for 10 seconds in the future
- Tests the scheduling feature
- High priority

### Step 4: Check Your Notifications

After tapping any button:

1. ✅ You'll see a confirmation message at the bottom of the screen
2. 📱 **Pull down your notification tray** to see the notification
3. 🔔 The notification will have the appropriate icon, title, and message
4. 🎵 You should hear a notification sound (if not on silent mode)

### What to Look For

✅ **Notification appears** in the notification tray  
✅ **Title and message** are correct  
✅ **Icon** shows the Perfin app icon  
✅ **Sound/vibration** works (if enabled)  
✅ **Tapping notification** opens the app (basic behavior)

### Troubleshooting

#### No Notifications Appearing?

1. **Check Permissions**
   - Go to Android Settings → Apps → Perfin → Notifications
   - Ensure notifications are enabled

2. **Check Do Not Disturb**
   - Make sure your phone isn't in Do Not Disturb mode

3. **Check App Permissions**
   - The app should request notification permission on first launch
   - If denied, go to Settings and enable manually

4. **Restart the App**
   - Sometimes a fresh start helps
   - Run `flutter run` again

#### Build Errors?

If you get build errors:
```bash
flutter clean
flutter pub get
flutter run
```

### Testing Different Priority Levels

Notice how different notifications behave:

- **Critical** (Budget Exceeded): Loudest, most prominent
- **High** (Budget Warning, Goal Alert): Standard notification sound
- **Medium** (Recurring Expense, Unusual Spending): Quieter notification

### Testing Duplicate Prevention

Try tapping the same button twice quickly:

1. First tap: Notification sent ✅
2. Second tap: Notification sent ✅ (but won't spam)
3. The system prevents duplicate notifications within 24 hours

### Testing Scheduled Notifications

1. Tap "Scheduled Notification (10s)"
2. Wait 10 seconds
3. You should receive the notification after the delay
4. This tests the scheduling feature

### Next Steps

Once you've verified notifications work:

1. ✅ The notification system is production-ready
2. 🔗 Integrate with real app features (budget tracking, goal monitoring, etc.)
3. 🎨 Customize notification content for your needs
4. 📊 Add analytics to track notification engagement

### Demo Video Suggestion

Record a quick video showing:
1. Opening the test screen
2. Tapping a notification button
3. Pulling down the notification tray
4. Showing the notification

This proves the feature works end-to-end! 🎉

## Quick Test Checklist

- [ ] App builds and runs successfully
- [ ] Test screen opens when button is tapped
- [ ] Simple notification appears in notification tray
- [ ] Budget warning notification appears
- [ ] Budget exceeded notification appears (critical priority)
- [ ] Recurring expense reminder appears
- [ ] Goal deadline alert appears
- [ ] Unusual spending alert appears
- [ ] Scheduled notification appears after 10 seconds
- [ ] Notifications have correct titles and messages
- [ ] Notification sound/vibration works
- [ ] Tapping notification opens the app

## Success! 🎉

If all notifications appear correctly, the notification system is **fully functional** and ready for production use!
