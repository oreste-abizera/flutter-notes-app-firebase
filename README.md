# Flutter Notes App with Firebase

A complete Flutter notes application with Firebase Authentication and Cloud Firestore integration using Provider for state management. Built as Individual Assignment 2 for ALU Flutter Mobile Development course.

## 🚀 Features

- **Separate Authentication Screens**: Dedicated Sign In and Sign Up screens
- **Firebase Authentication**: Email/Password signup and login with comprehensive validation
- **Real-time CRUD Operations**: Create, Read, Update, Delete notes with instant UI updates
- **Provider State Management**: Clean architecture eliminating all setState() calls
- **Real-time Firestore Sync**: Live data synchronization with Firestore database
- **Input Validation**: Comprehensive form validation with specific error messages
- **User Feedback**: Color-coded SnackBar notifications (green success, red error)
- **Clean UI**: Material Design 3 with responsive layouts and polished Cards
- **Session Persistence**: User stays logged in across app restarts
- **Error Handling**: Comprehensive error handling for all operations

## 🏗️ Architecture

This project follows clean architecture principles with complete separation of concerns:

```
lib/
├── models/
│   ├── app_user.dart         # User data model
│   └── note.dart             # Note data model with Firestore mapping
├── providers/
│   ├── auth_provider.dart    # Authentication state management
│   └── notes_provider.dart   # Notes state with real-time streams
├── repositories/
│   ├── auth_repository.dart  # Firebase Auth operations
│   └── notes_repository.dart # Firestore CRUD operations
├── screens/
│   ├── sign_in_screen.dart   # Dedicated sign in screen
│   ├── sign_up_screen.dart   # Dedicated sign up screen
│   └── notes_screen.dart     # Main notes interface
├── widgets/
│   ├── auth_wrapper.dart     # Authentication state router
│   ├── add_note_dialog.dart  # Add note dialog with validation
│   └── edit_note_dialog.dart # Edit note dialog with validation
├── utils/
│   └── validators.dart       # Input validation utilities
├── firebase_options.dart     # Firebase configuration
└── main.dart                 # App entry point with providers
```

## 📱 State Management - Provider Pattern

This app demonstrates advanced Provider usage with **zero setState() calls** in business logic:

### AuthProvider
```dart
class AuthProvider with ChangeNotifier {
  // Features:
  - Real-time auth state listening
  - Comprehensive error handling
  - Loading state management
  - Session persistence
  - Specific validation for each auth error
}
```

### NotesProvider  
```dart
class NotesProvider with ChangeNotifier {
  // Features:
  - Real-time Firestore streaming
  - Automatic UI updates on data changes
  - Optimistic updates for better UX
  - Background error handling
  - Stream subscription management
}
```

### Provider Benefits Demonstrated
1. **Complete State Separation**: UI never directly manages business state
2. **Real-time Reactivity**: UI automatically reflects all data changes
3. **Memory Management**: Proper disposal of streams and controllers
4. **Error Isolation**: Errors handled at provider level with user feedback
5. **Testable Architecture**: Business logic completely separated from UI

## 🔥 Firebase Integration

### Setup Requirements
1. **Firebase Project**: Created at [Firebase Console](https://console.firebase.google.com/)
2. **Authentication**: Email/Password provider enabled
3. **Firestore Database**: Created with proper security rules
4. **Platform Configuration**:
   - `android/app/google-services.json` (Android)
   - `ios/Runner/GoogleService-Info.plist` (iOS)
   - `firebase_options.dart` (Generated via FlutterFire CLI)

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notes/{noteId} {
      allow read, write: if request.auth != null && 
                         request.auth.uid == resource.data.userId;
    }
  }
}
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  firebase_core: ^3.15.1
  firebase_auth: ^5.6.2
  cloud_firestore: ^5.5.0
  provider: ^6.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Firebase CLI
- FlutterFire CLI

### Installation Steps
1. **Clone the repository**
   ```bash
   git clone [your-repo-url]
   cd flutter-notes-app-firebase
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 🔧 CRUD Operations Implementation

### Real-time Stream-based Architecture
The app uses Firestore streams for real-time updates:

```dart
// Real-time notes streaming
Stream<List<Note>> getNotesStream(String userId) {
  return _firestore
      .collection('notes')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => 
          Note.fromMap(doc.data(), doc.id)).toList());
}
```

### CRUD Operations
- **Create**: `await addNote(text, userId)` - Instant UI update via stream
- **Read**: `startListeningToNotes(userId)` - Real-time streaming
- **Update**: `await updateNote(noteId, text)` - Immediate reflection
- **Delete**: `await deleteNote(noteId)` - Real-time removal

## 📊 Data Structure

### Firestore Notes Collection
```json
{
  "notes": {
    "noteId": {
      "text": "Note content here",
      "userId": "firebase_user_uid",
      "createdAt": 1625097600000,
      "updatedAt": 1625097600000
    }
  }
}
```

### Note Model Implementation
```dart
class Note {
  final String id;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  
  // Firestore serialization methods
  factory Note.fromMap(Map<String, dynamic> map, String id);
  Map<String, dynamic> toMap();
}
```

## 🎨 UI/UX Features

### Material Design 3 Implementation
- **Polished Cards**: Notes displayed in elevated cards with shadows
- **FAB Integration**: Floating Action Button for adding notes
- **Loading States**: Single loader during initial fetch only
- **Color-coded Feedback**: Green SnackBars for success, Red for errors
- **Confirmation Dialogs**: AlertDialog for destructive actions
- **Responsive Design**: Perfect layout in portrait and landscape
- **Empty State**: "Nothing here yet—tap ➕ to add a note."

### Validation & Error Handling
- **Email Validation**: Format checking with specific error messages
- **Password Strength**: Minimum requirements with clear feedback
- **Firebase Errors**: Specific handling for weak passwords, existing users, etc.
- **Network Errors**: Graceful handling of connectivity issues
- **Input Sanitization**: Prevents empty notes and invalid data

## 🧪 Code Quality

### Dart Analyzer Results
```bash
flutter analyze
# Result: No issues found! (0 issues)
```

### Quality Metrics
- **Architecture**: Clean separation of concerns
- **State Management**: Zero setState() in business logic
- **Error Handling**: Comprehensive coverage
- **Memory Management**: Proper disposal of resources
- **Code Style**: Consistent formatting and naming

## 🎬 Demo Video Coverage

The implementation demonstrates:
1. **Cold App Start**: Firebase initialization and auth state check
2. **User Registration**: Complete signup flow with validation
3. **Firebase Console**: Live user creation verification
4. **Empty State**: First-time user experience
5. **Note Operations**: All CRUD operations with real-time updates
6. **Firestore Console**: Live data synchronization
7. **Error Scenarios**: Invalid email, weak password handling
8. **Device Rotation**: Responsive layout testing
9. **Session Persistence**: Logout/login cycle with data preservation
10. **Mobile Platform**: Running on actual device/emulator

## 📈 Performance Features

- **Real-time Updates**: Sub-second UI reflection of data changes
- **Optimized Rebuilds**: Only affected widgets rebuild
- **Stream Management**: Proper subscription lifecycle
- **Memory Efficiency**: Automatic cleanup on dispose
- **Network Optimization**: Efficient Firestore queries

## 🔐 Security Implementation

- **User Data Isolation**: Notes secured by userId
- **Authentication Required**: All operations require valid auth
- **Firestore Rules**: Server-side security enforcement
- **Input Validation**: Client-side data sanitization
- **Error Information**: Sensitive details not exposed to users

## 🤝 Contributing

This project is built for educational purposes as part of ALU's Flutter Mobile Development course. 

## 📄 License

Educational project - ALU Individual Assignment 2
