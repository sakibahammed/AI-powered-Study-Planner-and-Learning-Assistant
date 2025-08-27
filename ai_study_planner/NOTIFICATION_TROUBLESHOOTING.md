# Notification Troubleshooting Guide

## Why You're Not Getting Push Notifications

There are several common reasons why notifications might not be working. Let's troubleshoot step by step:

## 🔍 **Step 1: Check App Permissions**

### Android:
1. **Go to Settings** → **Apps** → **AI Study Planner**
2. **Tap "Permissions"**
3. **Make sure "Notifications" is enabled**
4. **Also check if "Display over other apps" is enabled**

### iOS:
1. **Go to Settings** → **AI Study Planner**
2. **Make sure "Notifications" is turned ON**
3. **Check that "Allow Notifications" is enabled**

## 🔍 **Step 2: Check Device Settings**

### Android:
1. **Settings** → **Notifications** → **App notifications**
2. **Find "AI Study Planner"**
3. **Make sure it's not blocked**

### iOS:
1. **Settings** → **Notifications**
2. **Find "AI Study Planner"**
3. **Enable all notification types**

## 🔍 **Step 3: Check Do Not Disturb**

### Both Platforms:
1. **Make sure Do Not Disturb is OFF**
2. **Check if Focus Mode is blocking notifications**
3. **Verify battery optimization isn't killing the app**

## 🔍 **Step 4: Test Notifications in App**

1. **Open the AI Study Planner app**
2. **Go to Planner screen**
3. **Tap the menu button (⋮) in the top right**
4. **Select "Test Notification"**
5. **You should see a notification immediately**

## 🔍 **Step 5: Check Notification Status**

1. **In the app, tap menu (⋮)**
2. **Select "Check Notification Status"**
3. **Check the console/debug output for status information**

## 🔍 **Step 6: Create a Task with Time**

1. **Create a new task**
2. **Set a specific time (not just a date)**
3. **Make sure the time is at least 5 minutes in the future**
4. **The notification will be scheduled for 5 minutes before the task time**

## 🚨 **Common Issues & Solutions**

### Issue 1: "No notifications at all"
**Solution:**
- Check device permissions
- Make sure app is not in battery optimization
- Try the test notification in the app

### Issue 2: "Test notification works but scheduled notifications don't"
**Solution:**
- Make sure you're setting a specific time (not just date)
- Check that the time is in the future
- Verify the app isn't being killed by the system

### Issue 3: "Notifications work but are delayed"
**Solution:**
- This is normal for scheduled notifications
- They are sent exactly 5 minutes before the task time
- Check your device's time settings

### Issue 4: "App crashes when creating tasks"
**Solution:**
- Make sure you have the latest version
- Try clearing app data and cache
- Reinstall the app if needed

## 🔧 **Debug Information**

The app now includes detailed logging. When you:
1. **Create a task with time** - Check console for scheduling logs
2. **Use "Check Notification Status"** - See pending notifications
3. **Use "Test Notification"** - Verify immediate notifications work

## 📱 **Platform-Specific Notes**

### Android:
- Notifications use `AndroidScheduleMode.exactAllowWhileIdle`
- Requires notification permissions
- May be affected by battery optimization

### iOS:
- Notifications use `DarwinNotificationDetails`
- Requires explicit permission requests
- May be affected by Focus modes

## 🆘 **Still Not Working?**

If you've tried all the above and notifications still don't work:

1. **Check the console/debug output** for error messages
2. **Try creating a task for 5 minutes from now** to test scheduling
3. **Make sure the app is not being killed** by the system
4. **Check if your device supports the notification features**

## 📞 **Getting Help**

If you're still having issues:
1. **Note down any error messages** from the console
2. **Try the test notification** and report if it works
3. **Check the notification status** and share the output
4. **Describe your device and OS version**

---

**Remember:** Notifications are scheduled for exactly 5 minutes before your task time. If you create a task for 3:00 PM, you'll get a notification at 2:55 PM.
