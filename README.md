# Poultry Farm Management App

A comprehensive Flutter application for managing poultry farm operations with Firebase backend integration.

## Features

### 🔐 Authentication
- User registration and login with email/password
- Secure Firebase Authentication
- User session management

### 📊 Dashboard
- Real-time statistics display
- Quick overview of farm metrics
- Recent activity feed
- Visual progress indicators

### 📝 Notes Management
- Create, edit, and delete notes
- Real-time synchronization with Firebase
- Timestamp tracking
- User-specific notes

### 🐔 Records & Events
- Track poultry records (births, deaths, etc.)
- Event scheduling with notifications
- Statistical analysis
- Data persistence

### 🔔 Notifications
- Local notification system
- Event reminders
- Scheduled notifications

### 🎨 Modern UI
- Beautiful Material Design interface
- Responsive layout
- Image carousel
- Category-based navigation

## Setup Instructions

### Prerequisites
- Flutter SDK (3.2.3 or higher)
- Dart SDK
- Firebase project
- Android Studio / VS Code

### 1. Clone and Install Dependencies
```bash
cd poultry_farm
flutter pub get
```

### 2. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication (Email/Password)
4. Enable Firestore Database
5. Set up security rules for Firestore

#### Configure Firebase in App
1. Update `lib/firebase_options.dart` with your Firebase project credentials:
   - Replace `your-api-key-here` with your actual API key
   - Replace `your-app-id-here` with your actual app ID
   - Replace `your-project-id-here` with your actual project ID
   - Replace `your-sender-id-here` with your actual sender ID

2. For Android: Add `google-services.json` to `android/app/`
3. For iOS: Add `GoogleService-Info.plist` to `ios/Runner/`

#### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /{collection}/{document} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### 3. Run the App
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── auth_service.dart         # Authentication service
├── database_service.dart     # Firestore database service
├── notification_service.dart # Local notifications
└── pages/
    ├── login_page.dart       # Login/Registration UI
    ├── home_page.dart        # Dashboard
    ├── notes_page.dart       # Notes management
    └── reminders_page.dart   # Records & Events
```

## Database Schema

### Users Collection
```javascript
users/{userId}
{
  email: string,
  createdAt: timestamp,
  totalChicks: number,
  totalDead: number,
  lastUpdated: timestamp
}
```

### Notes Collection
```javascript
users/{userId}/notes/{noteId}
{
  content: string,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### Records Collection
```javascript
users/{userId}/records/{recordId}
{
  type: string,
  content: string,
  chicks: number,
  dead: number,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### Events Collection
```javascript
users/{userId}/events/{eventId}
{
  title: string,
  createdAt: timestamp
}
```

## Key Features Explained

### Authentication Flow
- Users can register with email/password
- Login state is managed automatically
- Protected routes ensure data security
- Logout functionality included

### Real-time Data Sync
- All data is synchronized with Firebase Firestore
- Real-time updates across devices
- Offline support with local caching

### Statistics Tracking
- Automatic calculation of farm metrics
- Visual progress indicators
- Historical data tracking

### Notification System
- Local notifications for events
- Scheduled reminders
- Cross-platform notification support

## Troubleshooting

### Common Issues

1. **Firebase Connection Error**
   - Verify Firebase configuration in `firebase_options.dart`
   - Check internet connection
   - Ensure Firestore rules allow read/write

2. **Authentication Issues**
   - Verify email/password format
   - Check Firebase Authentication settings
   - Ensure user registration is enabled

3. **Build Errors**
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter and Dart SDK versions
   - Verify all dependencies are compatible

### Platform-Specific Setup

#### Android
- Ensure `google-services.json` is in `android/app/`
- Check Android SDK version compatibility
- Verify permissions in `AndroidManifest.xml`

#### iOS
- Ensure `GoogleService-Info.plist` is in `ios/Runner/`
- Check iOS deployment target
- Verify capabilities in Xcode

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review Firebase documentation

## Future Enhancements

- [ ] Image upload for records
- [ ] Advanced analytics dashboard
- [ ] Export functionality
- [ ] Multi-language support
- [ ] Offline mode improvements
- [ ] Push notifications
- [ ] User roles and permissions
