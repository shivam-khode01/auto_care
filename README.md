# Safety App 🚨

**A Professional Emergency Response Mobile Application**

An enterprise-grade Flutter safety application designed to provide real-time emergency assistance, location tracking, and instant contact notification system. Built with clean architecture principles and modern state management.

---

## 📋 Table of Contents

- [Features](#features)
- [Technology Stack](#technology-stack)
- [Project Architecture](#project-architecture)
- [Installation & Setup](#installation--setup)
- [Usage Guide](#usage-guide)
- [Project Structure](#project-structure)
- [API & Services](#api--services)
- [Database Schema](#database-schema)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

---

## ✨ Features

### 🔐 **Authentication & User Management**
- Secure user authentication with session management
- User profile management
- Account information display
- Logout functionality with confirmation

### 📞 **Emergency Contact Management**
- Add up to 5 emergency contacts
- Priority-based contact system:
  - **CRITICAL** 🔴 - Called first in emergencies
  - **HIGH** 🟠 - Called second in emergencies
  - **MEDIUM** 🟡 - Called third in emergencies
  - **LOW** 🟢 - Called last in emergencies
- Real-time contact status tracking
- Contact edit and deletion with confirmation
- Automatic contact filtering based on incident severity

### 🆘 **SOS Emergency System**
- One-tap emergency activation
- Incident severity selection (CRITICAL/HIGH/MEDIUM/LOW)
- Automatic contact filtering by severity
- Real-time phone calling to emergency contacts
- Incident history tracking
- Location capture at incident time

### ☎️ **Real Phone Calling**
- Direct phone calling integration via device
- Priority-based sequential calling
- Call status monitoring
- SMS notifications (upcoming)
- Automatic call logging

### 📍 **Location Tracking**
- Real-time GPS location tracking
- Location history storage
- Background location updates
- Geolocation permissions handling
- Location accuracy monitoring

### ⏰ **Alarm & Monitoring**
- Real-time alarm system
- Status monitoring
- Automated alerts
- Notification system integration

### 📊 **Incident Management**
- Create and track incidents
- Incident categorization by severity
- Timestamp tracking
- Contact response logging
- Historical incident data storage

---

## 🛠️ Technology Stack

### **Frontend Framework**
- **Flutter** - Cross-platform mobile development
- **Dart** - Programming language
- **Material Design 3** - UI framework with modern design patterns

### **State Management**
- **Riverpod 2.4.0** - Advanced state management with providers
- **flutter_riverpod** - Riverpod integration for Flutter

### **Database & Storage**
- **SQLite (sqflite 2.3.0)** - Local database
- **SharedPreferences** - Lightweight key-value storage
- **uuid 4.0.0** - Unique identifier generation

### **Device Integration**
- **url_launcher 6.1.0** - Phone calling and SMS
- **geolocator 11.0.0** - GPS location tracking
- **flutter_local_notifications** - Push notifications
- **permission_handler** - Runtime permissions management

### **Architecture Pattern**
- **Clean Architecture** - Separation of concerns
- **Service Layer** - Business logic encapsulation
- **Provider Pattern** - State and dependency management
- **Singleton Pattern** - Shared service instances

---

## 🏗️ Project Architecture

```
lib/
├── core/
│   ├── theme/          # App theme and styling
│   └── constants/      # App-wide constants
├── data/
│   ├── models/         # Data models (User, EmergencyContact, Incident, etc.)
│   └── database/       # Database operations
├── services/
│   ├── auth_service.dart           # Authentication & user management
│   ├── database_service.dart       # SQLite operations
│   ├── phone_service.dart          # Real calling & SMS
│   ├── location_service.dart       # GPS tracking
│   ├── alarm_service.dart          # Alarm monitoring
│   └── incident_service.dart       # Incident management
├── providers/
│   ├── auth_provider.dart          # Auth state management
│   ├── incidents_provider.dart     # Incident state management
│   ├── alarms_provider.dart        # Alarm state management
│   └── location_provider.dart      # Location state management
└── ui/
    ├── screens/
    │   ├── login_screen.dart       # Authentication
    │   ├── home_page.dart          # Dashboard
    │   ├── profile_screen.dart     # User profile & contacts
    │   ├── sos_page.dart           # Emergency activation
    │   ├── camera_page.dart        # Photo capture
    │   └── routine_page.dart       # Routine activities
    └── widgets/                    # Reusable UI components
```

---

## 📦 Installation & Setup

### **Prerequisites**
- Flutter SDK (3.0 or higher)
- Android SDK (API 21+)
- iOS 12.0 or higher
- Git

### **Step 1: Clone Repository**
```bash
git clone https://github.com/yourusername/safety_app.git
cd safety_app
```

### **Step 2: Install Dependencies**
```bash
flutter pub get
```

### **Step 3: Configure for Android**
Update `android/app/build.gradle.kts`:
```kotlin
android {
    compileSdk = 34
    
    defaultConfig {
        applicationId = "com.example.safety_app"
        minSdk = 21
        targetSdk = 34
    }
}
```

### **Step 4: Add Permissions**

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to send emergency alerts to nearby contacts</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Background location tracking for safety features</string>
```

### **Step 5: Run the App**
```bash
flutter run
```

Or for specific device:
```bash
flutter run -d <device_id>
```

---

## 🚀 Usage Guide

### **1. Login**
- Default credentials: `admin` / `admin123`
- Enter username and password
- Tap "Login"

### **2. Add Emergency Contacts**
1. Navigate to **Profile** screen
2. Tap **"Add Emergency Contact"**
3. Enter contact details:
   - **Phone Number**: Full mobile number with country code
   - **Contact Name**: Name or relation (Mom, Dad, Sister, etc.)
   - **Priority Level**: Select CRITICAL, HIGH, MEDIUM, or LOW
4. Tap **"Add Contact"**

### **3. Activate SOS**
1. Navigate to **SOS** screen
2. Select incident severity:
   - **CRITICAL**: Highest priority - calls CRITICAL contacts
   - **HIGH**: High priority - calls CRITICAL + HIGH contacts
   - **MEDIUM**: Medium priority - calls first 3 contacts
   - **LOW**: Standard - calls all contacts in order
3. Review matched contacts
4. Tap **"SEND SOS"**
5. System will automatically call emergency contacts in priority order

### **4. View Profile**
- See account information
- Manage emergency contacts
- Logout when needed

---

## 📁 Project Structure Details

### **Models** (`lib/data/models/models.dart`)
```dart
class User {
  final String id;
  final String username;
  final String email;
  final String phoneNumber;
  final List<EmergencyContact> emergencyContacts;
  final DateTime createdAt;
  final bool isActive;
}

class EmergencyContact {
  final String id;
  final String phoneNumber;
  final String name;
  final String priority; // CRITICAL, HIGH, MEDIUM, LOW
}

class Incident {
  final String id;
  final String userId;
  final String severity;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
}

class Alarm {
  final String id;
  final String userId;
  final String status;
  final DateTime createdAt;
}
```

### **Services Overview**

**AuthService** - User authentication and profile management
```dart
- login(username, password)
- logout()
- addEmergencyContact(phoneNumber, name, priority)
- removeEmergencyContact(contactId)
- getCurrentUser()
```

**PhoneService** - Real phone calling with priority filtering
```dart
- makeCall(phoneNumber)
- sendSMS(phoneNumber, message)
- getContactsByPriority(priority)
- getContactsForSeverity(severity)
- callEmergencyContacts(contacts)
```

**LocationService** - GPS tracking and geolocation
```dart
- getCurrentLocation()
- startTracking()
- stopTracking()
- getLocationHistory()
```

**IncidentService** - Incident creation and management
```dart
- createIncident(severity, latitude, longitude)
- getIncidents()
- getIncidentById(id)
```

---

## 💾 Database Schema

### **SQLite Tables**

**users** table
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  email TEXT,
  phoneNumber TEXT,
  emergencyContacts TEXT,
  isActive INTEGER DEFAULT 1,
  createdAt TEXT
)
```

**emergency_contacts** table
```sql
CREATE TABLE emergency_contacts (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  phoneNumber TEXT NOT NULL,
  name TEXT,
  priority TEXT,
  FOREIGN KEY(userId) REFERENCES users(id)
)
```

**incidents** table
```sql
CREATE TABLE incidents (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  severity TEXT NOT NULL,
  latitude REAL,
  longitude REAL,
  createdAt TEXT,
  FOREIGN KEY(userId) REFERENCES users(id)
)
```

**location_history** table
```sql
CREATE TABLE location_history (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  latitude REAL,
  longitude REAL,
  timestamp TEXT,
  FOREIGN KEY(userId) REFERENCES users(id)
)
```

---

## 🔧 Development

### **Building for Production**

**Android Release Build**
```bash
flutter build apk --release
```

**Android App Bundle**
```bash
flutter build appbundle --release
```

**iOS Release Build**
```bash
flutter build ios --release
```

### **Testing**
```bash
flutter test
```

### **Code Analysis**
```bash
flutter analyze
```

### **Format Code**
```bash
flutter format lib/
```

---

## 📝 Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### **Code Style**
- Follow Flutter style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Ensure code is well-formatted with `flutter format`

---

## 📋 Roadmap

- [ ] Firebase integration for cloud backup
- [ ] Professional authentication (OAuth, Firebase Auth)
- [ ] Advanced incident analytics dashboard
- [ ] Call recording for evidence
- [ ] Real-time incident map tracking
- [ ] Multi-language support
- [ ] Offline-first capabilities
- [ ] Wearable device integration
- [ ] AI-powered threat detection
- [ ] Emergency services integration

---

## ⚠️ Disclaimer

This application is designed for personal emergency safety. For official emergency assistance, always contact local emergency services (911 in US, 112 in EU, 100 in India, etc.).

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 📧 Contact & Support

For issues, feature requests, or questions:
- **Create an Issue** on GitHub
- **Email**: support@safetyapp.dev
- **Documentation**: [Wiki](https://github.com/yourusername/safety_app/wiki)

---

## 🙏 Acknowledgments

- Flutter and Dart communities
- Riverpod state management
- Material Design 3
- All contributors and users

---

## 🎯 Current Status

✅ **Production Ready Features:**
- User authentication
- Emergency contact management
- Real phone calling system
- Location tracking
- Incident creation and logging
- Priority-based contact filtering

⏳ **In Development:**
- SMS notifications
- Call history analytics
- Enhanced UI/UX polish

---

**Made with ❤️ for safety and emergency response**
