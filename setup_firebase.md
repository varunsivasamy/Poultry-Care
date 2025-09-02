# Firebase Setup Guide for Poultry Farm App

This guide will help you set up Firebase for the Poultry Farm Management App.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter a project name (e.g., "poultry-farm-app")
4. Choose whether to enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Authentication

1. In your Firebase project, go to "Authentication" in the left sidebar
2. Click "Get started"
3. Go to the "Sign-in method" tab
4. Enable "Email/Password" provider
5. Click "Save"

## Step 3: Set up Firestore Database

1. In your Firebase project, go to "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location for your database
5. Click "Done"

## Step 4: Configure Security Rules

1. In Firestore Database, go to the "Rules" tab
2. Replace the default rules with:

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

3. Click "Publish"

## Step 5: Get Firebase Configuration

### For Web:
1. In your Firebase project, click the gear icon (⚙️) next to "Project Overview"
2. Select "Project settings"
3. Scroll down to "Your apps" section
4. Click the web icon (</>)
5. Register your app with a nickname
6. Copy the configuration object

### For Android:
1. In Project settings, click the Android icon
2. Register your app with package name: `com.example.poultry_farm`
3. Download the `google-services.json` file
4. Place it in `android/app/` directory

### For iOS:
1. In Project settings, click the iOS icon
2. Register your app with bundle ID: `com.example.poultryFarm`
3. Download the `GoogleService-Info.plist` file
4. Place it in `ios/Runner/` directory

## Step 6: Update Firebase Configuration

1. Open `lib/firebase_options.dart`
2. Replace the placeholder values with your actual Firebase configuration:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-api-key',
  appId: 'your-actual-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  authDomain: 'your-actual-project-id.firebaseapp.com',
  storageBucket: 'your-actual-project-id.appspot.com',
);
```

## Step 7: Test the Setup

1. Run the app: `flutter run`
2. Try to register a new user
3. Check if data is being saved to Firestore
4. Verify authentication is working

## Troubleshooting

### Common Issues:

1. **"Firebase not initialized" error**
   - Make sure you've updated `firebase_options.dart` with correct values
   - Check that `google-services.json` or `GoogleService-Info.plist` is in the correct location

2. **Authentication errors**
   - Verify Email/Password provider is enabled in Firebase Console
   - Check that your email format is valid
   - Ensure password is at least 6 characters

3. **Firestore permission errors**
   - Verify security rules are published
   - Check that rules allow authenticated users to read/write their data

4. **Build errors**
   - Run `flutter clean` and `flutter pub get`
   - Check that all Firebase dependencies are properly installed

### Verification Checklist:

- [ ] Firebase project created
- [ ] Authentication enabled (Email/Password)
- [ ] Firestore database created
- [ ] Security rules configured and published
- [ ] Firebase configuration files downloaded and placed correctly
- [ ] `firebase_options.dart` updated with actual values
- [ ] App builds without errors
- [ ] User registration works
- [ ] Data is saved to Firestore
- [ ] Real-time updates work

## Next Steps

Once Firebase is properly configured:

1. Test all app features
2. Add more security rules if needed
3. Set up Firebase Analytics (optional)
4. Configure Firebase Hosting for web deployment (optional)
5. Set up Firebase Cloud Messaging for push notifications (optional)

## Support

If you encounter issues:
1. Check the Firebase Console for error messages
2. Review Firebase documentation
3. Check the app's console output for detailed error information
4. Verify all configuration steps were completed correctly 