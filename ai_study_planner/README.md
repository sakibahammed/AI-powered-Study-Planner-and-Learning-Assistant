# AI-powered Study Planner and Learning Assistant

A comprehensive Flutter application that combines study planning, AI-powered learning assistance, and interactive features to enhance your learning experience.

## Features

### 🔐 Authentication
- Firebase Authentication with email/password
- User registration and login
- Secure user data storage in Firestore

### 📊 Dashboard
- Beautiful dashboard with statistics
- Progress tracking
- Quick access to all features

### 🤖 AI Chat Assistant
- Advanced AI-powered chat with file upload support
- PDF document analysis and summarization
- Real-time conversation with AI study assistant
- File upload capabilities for study materials

### 📚 Study Planner
- Task management and scheduling
- Calendar integration
- Progress tracking

### 🎯 Quiz System
- Interactive quiz creation and taking
- Score tracking and analytics
- Performance insights

### 📝 Flashcard System
- Create and manage flashcards
- Spaced repetition learning
- Interactive study sessions

## Project Structure

```
lib/
├── auth/                    # Authentication related files
│   ├── auth_page.dart      # Main auth flow controller
│   ├── login_page.dart     # Login screen
│   └── signup_page.dart    # Registration screen
├── components/             # Reusable UI components
│   ├── widgets/           # Custom widgets
│   │   ├── mybuttons.dart
│   │   ├── textfields.dart
│   │   └── chat_bubble.dart
│   └── images/            # Image assets
├── features/              # Feature-specific modules
│   ├── chat/             # AI chat functionality
│   │   ├── chat_page.dart
│   │   └── chat_services.dart
│   ├── flashcard/        # Flashcard features
│   ├── quiz/             # Quiz features
│   └── planner/          # Study planner features
├── models/               # Data models
├── screens/              # Main app screens
│   ├── dashboard_screen.dart
│   ├── chatbot_screen.dart
│   ├── flashcard_screen.dart
│   ├── planner_screen.dart
│   └── quiz_screen.dart
├── theme/                # App theming
├── widgets/              # Dashboard widgets
├── firebase_options.dart # Firebase configuration
└── main.dart            # App entry point
```

## Getting Started

1. **Prerequisites**
   - Flutter SDK (latest version)
   - Firebase project setup
   - Android Studio / VS Code

2. **Installation**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Ensure `google-services.json` is in `android/app/`
   - Firebase configuration is already included

4. **Run the App**
   ```bash
   flutter run
   ```

## Dependencies

- **Firebase**: Authentication, Firestore database
- **HTTP**: API communication for AI services
- **File Picker**: Document upload functionality
- **Table Calendar**: Calendar integration
- **FL Chart**: Data visualization
- **Intl**: Internationalization support

## Features Overview

### AI Chat Assistant
The app includes an advanced AI chat system that can:
- Analyze uploaded PDF documents
- Provide intelligent responses to study questions
- Maintain conversation context
- Support file upload and processing

### Study Planning
- Create and manage study tasks
- Set deadlines and priorities
- Track completion progress
- Calendar integration for scheduling

### Interactive Learning
- Create custom flashcards
- Take quizzes with immediate feedback
- Track learning progress
- Spaced repetition algorithms

## Contributing

This project is a merged version of two separate Flutter applications, combining the best features from both into a comprehensive study assistant.

## License

This project is for educational purposes.
