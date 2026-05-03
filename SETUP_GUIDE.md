# SafetyPro - Quick Setup Guide

## 📋 Prerequisites
- Flutter SDK (3.11.5 or higher)
- Android SDK / iOS SDK
- Git

## 🚀 Quick Start

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Build Runner (Optional)
```bash
flutter pub run build_runner build
```

### Step 3: Run the App
```bash
# For Android
flutter run -d android

# For iOS
flutter run -d ios

# For web
flutter run -d web

# For Windows
flutter run -d windows
```

### Step 4: Login
```
Username: admin
Password: admin123
```

## 🎯 Key Features to Try

### 1. Create Your First Alarm ⏰
1. Go to **Alarms** tab
2. Click the **+** button
3. Enter title and description
4. Pick a time (5 minutes from now for testing)
5. Select "No Repeat" or "Daily"
6. Click **Create**
7. Wait for notification at scheduled time

### 2. Send SOS Emergency 🚨
1. Go to **SOS** tab
2. Enter incident title and details
3. Select severity (High/Critical)
4. Click **SEND SOS ALERT**
5. Check **Incidents** to see the created incident
6. Click incident to see details

### 3. Enable Location Tracking 📍
1. Grant location permission
2. Go to **Location** tab
3. Click **Start Tracking**
4. Allow location service
5. Watch real-time location updates
6. View location history below

### 4. Manage Incidents 📊
1. Go to **Incidents** tab
2. View all incidents with filters
3. Click incident for details
4. Use **Acknowledge** or **Resolve** buttons
5. Track status changes

### 5. Set Emergency Contacts 👥
1. Go to **Profile** tab
2. Scroll to "Emergency Contacts"
3. Enter phone number
4. Click **+** to add
5. View all saved contacts
6. Remove contacts with **X** button

## 🎨 Customization

### Change Theme Colors
Edit `lib/core/theme/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF2563EB); // Change this
```

### Update Demo Credentials
Edit `lib/core/constants/app_constants.dart`:
```dart
static const String dummyUsername = 'admin';
static const String dummyPassword = 'admin123';
```

### Modify Database
Edit `lib/services/database_service.dart` for schema changes

## 🔍 Testing Alarms

### Immediate Test
1. Create alarm with time = NOW + 1 minute
2. Stay on Alarms tab
3. Watch for notification

### Recurring Test
1. Create alarm with time = current hour:minute
2. Select "Daily" recurrence
3. Wait until next day same time
4. Or modify `alarmCheckIntervalSeconds` to 10 seconds for quick testing

## 📍 Testing Location

### Emulator Testing
Use Android Emulator extended controls:
1. Open Extended Controls in Emulator
2. Go to Location tab
3. Enter test coordinates
4. Press Send

### Real Device
- Just enable location permission
- App will use real GPS

## 🐛 Common Issues

### Issue: "No location permission"
**Solution**: Grant location permission in app settings

### Issue: "Alarms not triggering"
**Solution**: 
- Check if alarm time is in future
- Ensure app is not force-stopped
- Check notification settings

### Issue: "Database locked"
**Solution**: Restart the app or clear app data

### Issue: "Dependencies failed"
**Solution**: 
```bash
flutter clean
flutter pub get
flutter run
```

## 📊 Testing Scenarios

### Scenario 1: Full Workflow
1. Login ✓
2. Create alarm ✓
3. Wait for alarm ✓
4. Send SOS ✓
5. Check incidents ✓
6. Resolve incident ✓
7. Track location ✓
8. Add emergency contact ✓

### Scenario 2: Emergency Response
1. Create HIGH severity SOS
2. View incident in Incidents tab
3. Click Acknowledge
4. Check location in Location tab
5. Add responder contact in Profile

## 🎓 Understanding the Flow

```
App Start
   ↓
SplashScreen (2 seconds)
   ↓
Check if logged in?
   ├─ Yes → HomeScreen
   └─ No → LoginScreen
            ↓
         Authenticate
            ↓
         Save token
            ↓
         HomeScreen
            ↓
    Navigate between:
    - Home (Dashboard)
    - SOS (Emergencies)
    - Alarms (Schedules)
    - Incidents (History)
    - Location (GPS)
    - Profile (Settings)
```

## 💾 Database Locations

**Android**: `/data/data/com.example.safety_app/databases/safety_pro.db`
**iOS**: `Application Support/safety_pro.db`

Access via:
- Android Studio Device File Explorer
- Xcode Devices and Simulators

## 🔄 Development Workflow

1. Make code changes
2. **Hot reload** (r) for UI changes
3. **Full restart** (R) for service changes
4. Check debug console for logs

## 📝 Important Logs

Look for these in debug console:
```
I/logger: User logged in: admin
I/logger: Starting alarm monitoring for user: user_001
I/logger: Location updated: (lat, lon)
I/logger: Incident created: incident_id
```

## ⚙️ Advanced Setup

### For Real API Integration
1. Update `AuthService` to call actual API
2. Modify `IncidentService` for API sync
3. Update `AlarmService` for server-side scheduling
4. Change `DatabaseService` to use API

### For Firebase
1. Add Firebase packages (already in pubspec)
2. Configure Firebase Console
3. Update main.dart with Firebase init
4. Replace local notifications with FCM

## 🧪 Unit Testing

Create test file: `test/services/auth_service_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:safety_app/services/auth_service.dart';

void main() {
  test('Login with correct credentials', () async {
    final auth = AuthService();
    final result = await auth.login('admin', 'admin123');
    expect(result, true);
  });
}
```

Run tests:
```bash
flutter test
```

## 📱 Device Testing Checklist

- [ ] Login works
- [ ] Alarm notification shows
- [ ] Location permission works
- [ ] SOS incident creates
- [ ] Navigation smooth
- [ ] No crashes
- [ ] Database persists
- [ ] Logout works

---

**Ready to run!** 🎉

`flutter run`

For issues, check the complete documentation in `ENTERPRISE_README.md`
