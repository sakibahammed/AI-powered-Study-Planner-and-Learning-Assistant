# Task Notification System

## Overview
The AI Study Planner now includes a smart notification system that sends push notifications 5 minutes before scheduled tasks.

## Features
- **Automatic Scheduling**: When you create a task with a specific time, a notification is automatically scheduled
- **Smart Timing**: Notifications are sent 5 minutes before the task start time
- **Beautiful Messages**: Notifications include motivational messages like "Get ready to crush [task name] and grow! 💪"
- **Time Display**: Tasks with specific times show a time badge on the task cards
- **Test Notifications**: Use the menu in the planner screen to test notifications

## How It Works

### Creating Tasks with Notifications
1. Go to the Planner screen
2. Tap the "+" button to add a new task
3. Fill in the task details
4. Use the "Set Time" button to specify when the task should start
5. Save the task
6. A notification will be automatically scheduled for 5 minutes before the task time

### Notification Messages
- **Title**: "Get ready to crush [task name] and grow! 💪"
- **Body**: "Your task "[task name]" starts in 5 minutes. Time to shine! ✨"

### Time Display
- Tasks with specific times show a small time badge (e.g., "14:30") on the task card
- Tasks without specific times don't show the time badge

### Testing Notifications
1. In the Planner screen, tap the menu button (three dots) in the top right
2. Select "Test Notification"
3. You should receive a test notification immediately

## Technical Details

### Permissions Required
The app requests the following permissions:
- `RECEIVE_BOOT_COMPLETED` - To restore notifications after device restart
- `VIBRATE` - For notification vibration
- `WAKE_LOCK` - To ensure notifications are delivered
- `SCHEDULE_EXACT_ALARM` - For precise notification timing
- `USE_EXACT_ALARM` - For exact alarm scheduling

### Notification Behavior
- Notifications are scheduled using the device's local notification system
- They work even when the app is closed
- Notifications are automatically cancelled when tasks are deleted or edited
- Only tasks with specific times (not midnight 00:00) get notifications

### Platform Support
- **Android**: Full support with custom notification styling
- **iOS**: Full support with native notification appearance

## Troubleshooting

### Notifications Not Working?
1. Check that notification permissions are granted
2. Ensure the task has a specific time set (not just a date)
3. Make sure the notification time hasn't already passed
4. Try the test notification feature to verify the system is working

### Notification Timing
- Notifications are sent exactly 5 minutes before the task time
- If you create a task for 3:00 PM, you'll get notified at 2:55 PM
- Notifications won't be scheduled for past times

### Editing Tasks
- When you edit a task's time, the old notification is cancelled and a new one is scheduled
- When you delete a task, its notification is automatically cancelled

## Future Enhancements
- Customizable notification timing (e.g., 10 minutes, 30 minutes before)
- Different notification sounds for different task categories
- Notification history and management
- Recurring task notifications
