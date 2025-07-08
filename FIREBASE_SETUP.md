# Firebase Setup Guide for FixiGo

This guide will help you set up Firebase for the FixiGo iOS app.

## Prerequisites

1. **Firebase Account**: Create a Firebase account at [firebase.google.com](https://firebase.google.com)
2. **Xcode**: Make sure you have Xcode 15.0+ installed
3. **iOS Development**: Basic knowledge of iOS development

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project" or "Add project"
3. Enter project name: `FixiGo` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Choose your Analytics account or create a new one
6. Click "Create project"

## Step 2: Add iOS App to Firebase

1. In your Firebase project console, click the iOS icon (+ Add app)
2. Enter your iOS bundle ID (e.g., `com.yourcompany.FixiGo`)
3. Enter app nickname: `FixiGo`
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Click "Continue"

## Step 3: Configure Xcode Project

### 3.1 Add Firebase SDK via Swift Package Manager

1. In Xcode, go to your project settings
2. Select your project target
3. Go to "Package Dependencies" tab
4. Click "+" to add a new package
5. Enter Firebase iOS SDK URL: `https://github.com/firebase/firebase-ios-sdk.git`
6. Select the following Firebase products:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseStorage
   - FirebaseMessaging
   - FirebaseAnalytics
7. Click "Add Package"

### 3.2 Add GoogleService-Info.plist

1. Drag the downloaded `GoogleService-Info.plist` file into your Xcode project
2. Make sure it's added to your main app target
3. Replace the placeholder file in the project with your actual configuration

### 3.3 Update Bundle Identifier

1. In Xcode, select your project
2. Go to "General" tab
3. Update the Bundle Identifier to match what you entered in Firebase Console
4. Make sure it matches the `BUNDLE_ID` in your `GoogleService-Info.plist`

## Step 4: Configure Firebase Services

### 4.1 Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" authentication
5. Optionally enable other providers (Google, Apple, etc.)

### 4.2 Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" for development
4. Select a location closest to your users
5. Click "Done"

### 4.3 Storage (Optional)

1. In Firebase Console, go to "Storage"
2. Click "Get started"
3. Choose "Start in test mode" for development
4. Select a location
5. Click "Done"

### 4.4 Cloud Messaging

1. In Firebase Console, go to "Cloud Messaging"
2. Click "Get started"
3. This will be used for push notifications

## Step 5: Security Rules

### 5.1 Firestore Security Rules

Update your Firestore security rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Workers can be read by anyone, but only workers can write their own data
    match /workers/{workerId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == workerId;
    }
    
    // Bookings can be read/written by involved parties
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null && 
        (resource.data.customerId == request.auth.uid || 
         resource.data.workerId == request.auth.uid);
    }
    
    // Chat messages can be read/written by chat participants
    match /chats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth != null && 
        (chatId.matches(request.auth.uid + '.*') || 
         chatId.matches('.*' + request.auth.uid));
    }
    
    // Reviews can be read by anyone, written by customers
    match /reviews/{reviewId} {
      allow read: if true;
      allow write: if request.auth != null && 
        resource.data.customerId == request.auth.uid;
    }
    
    // Payments can be read/written by involved parties
    match /payments/{paymentId} {
      allow read, write: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         resource.data.workerId == request.auth.uid);
    }
  }
}
```

### 5.2 Storage Security Rules (if using Storage)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can upload their own profile images
    match /users/{userId}/profile.jpg {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Workers can upload their work photos
    match /workers/{workerId}/photos/{photoId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == workerId;
    }
  }
}
```

## Step 6: Test Firebase Integration

1. Build and run your app
2. Try to sign up a new user
3. Check Firebase Console to see if the user was created
4. Verify that data is being written to Firestore

## Step 7: Production Setup

### 7.1 Update Security Rules

Before going to production, update your security rules to be more restrictive:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Add more specific rules based on your app's requirements
    // Consider adding rate limiting and data validation
  }
}
```

### 7.2 Enable App Check (Recommended)

1. In Firebase Console, go to "App Check"
2. Enable App Check for your app
3. Add App Check to your iOS app

### 7.3 Configure Analytics Events

Set up custom analytics events for better insights:

```swift
// Example analytics events
Analytics.logEvent("booking_created", parameters: [
    "service_type": serviceType.rawValue,
    "amount": amount
])

Analytics.logEvent("worker_rated", parameters: [
    "worker_id": workerId,
    "rating": rating
])
```

## Troubleshooting

### Common Issues

1. **Build Errors**: Make sure all Firebase SDKs are properly added to your target
2. **Authentication Issues**: Verify your `GoogleService-Info.plist` is correctly added
3. **Permission Errors**: Check your Firestore security rules
4. **Network Issues**: Ensure your app has internet connectivity

### Debug Mode

Enable Firebase debug mode for development:

```swift
// Add this to your app's initialization
#if DEBUG
FirebaseConfiguration.shared.setLoggerLevel(.debug)
#endif
```

## Next Steps

1. **Backend Functions**: Consider adding Firebase Cloud Functions for complex business logic
2. **Monitoring**: Set up Firebase Crashlytics for crash reporting
3. **Performance**: Enable Firebase Performance Monitoring
4. **A/B Testing**: Use Firebase Remote Config for feature flags

## Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firebase iOS SDK](https://firebase.google.com/docs/ios/setup)
- [Firebase Community](https://firebase.google.com/community)

---

**Note**: This setup guide assumes you're using the latest Firebase iOS SDK. Always refer to the official Firebase documentation for the most up-to-date instructions. 