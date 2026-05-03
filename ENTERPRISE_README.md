# SafetyPro - Enterprise Safety Application

## 🎯 Overview
SafetyPro is a professional-grade safety management application built with Flutter, featuring real-time alarms, GPS tracking, emergency SOS alerts, and comprehensive incident management.

## ✨ Features Implemented

### 🔔 Real-Time Alarm System
- **Scheduled Alarms**: Set one-time or recurring alarms
- **Recurring Options**: Daily, Weekly, Monthly schedules
- **Real-Time Notifications**: Local notifications with custom sounds
- **Snooze & Dismiss**: Interactive alarm management
- **Database Persistence**: All alarms saved locally

### 📍 GPS Tracking & Location Services
- **Real-Time Location Tracking**: Continuous GPS updates
- **Location History**: Complete location tracking history
- **Accuracy Indicators**: Shows GPS accuracy levels
- **Distance Calculation**: Calculate distances between locations
- **Location-Aware SOS**: Automatically capture location on emergencies

### 🚨 Emergency SOS System
- **Quick SOS Alerts**: One-click emergency notifications
- **Location Integration**: Automatic GPS capture
- **Severity Levels**: High and Critical incident classification
- **Emergency Contacts**: Notify saved emergency contacts
- **Incident Logging**: All emergencies stored in database

### 📊 Comprehensive Incident Management
- **Multi-Category Incidents**: SOS, Alarms, Routine alerts
- **Severity Classification**: Low, Medium, High, Critical
- **Status Tracking**: Pending → Acknowledged → Resolved
- **Filterable Dashboard**: Sort by status, severity, date
- **Incident Statistics**: Overview of all incidents
- **Complete History**: Access all past incidents

### 👤 User Profile & Emergency Contacts
- **Account Management**: View and update profile
- **Emergency Contacts**: Add up to 5 emergency contacts
- **Contact Management**: Easy add/remove interface
- **Account Information**: Phone, email, membership details

### 📱 Professional Dashboard
- **Real-Time Statistics**: Active alarms, unresolved incidents, critical alerts
- **Quick Actions**: Fast access to main features
- **Recent Incidents**: View latest 3 incidents
- **Beautiful Cards**: Modern Material Design 3 UI
- **Bottom Navigation**: Easy access to all features

## 🏗️ Architecture

### Project Structure
```
lib/
├── core/
│   ├── config/          # Configuration files
│   ├── constants/       # App constants
│   ├── theme/          # Material Design 3 theme
│   └── utils/          # Helper utilities
├── data/
│   ├── datasources/    # Local data sources
│   ├── models/         # Data models
│   └── repositories/   # Data repositories
├── domain/
│   └── entities/       # Domain entities
├── services/           # Business logic services
│   ├── auth_service.dart
│   ├── alarm_service.dart
│   ├── location_service.dart
│   ├── incident_service.dart
│   └── database_service.dart
├── providers/          # Riverpod state management
│   ├── auth_provider.dart
│   ├── alarm_provider.dart
│   ├── incident_provider.dart
│   └── location_provider.dart
└── ui/
    ├── screens/        # UI Screens
    │   ├── splash_screen.dart
    │   ├── login_screen.dart
    │   ├── home_screen.dart
    │   ├── sos_screen.dart
    │   ├── alarms_screen.dart
    │   ├── incidents_screen.dart
    │   ├── location_screen.dart
    │   └── profile_screen.dart
    └── widgets/        # Reusable widgets
```

### Technology Stack
- **State Management**: Flutter Riverpod
- **Local Database**: SQLite with sqflite
- **Local Storage**: SharedPreferences
- **Alarms**: Flutter Local Notifications
- **GPS**: Geolocator package
- **UI Framework**: Material Design 3
- **Logging**: Logger package
- **Fonts**: Google Fonts (Poppins)

## 🎨 UI/UX Design

### Professional Theme
- **Primary Color**: Professional Blue (#2563EB)
- **Secondary Color**: Purple (#7C3AED)
- **Error Color**: Red (#DC2626)
- **Success Color**: Green (#16A34A)
- **Typography**: Google Poppins font family
- **Responsive Design**: Works on all screen sizes

### Navigation
- **Bottom Navigation**: 6 main sections
- **Nested Navigation**: Routes within each section
- **Splash Screen**: Professional app initialization
- **Smooth Transitions**: Material animations

## 🔐 Authentication

### Demo Credentials (Development)
```
Username: admin
Password: admin123
```

### Authentication Features
- Local authentication with dummy credentials
- Token-based session management
- Auto-login on app restart
- Emergency contact management
- User profile persistence

## 📊 Database Schema

### Tables
1. **users**: User profile information
2. **incidents**: SOS and alert incidents
3. **alarms**: Safety alarms and schedules
4. **location_history**: GPS tracking history
5. **metadata**: Additional incident information

## 🚀 Getting Started

### Installation

1. **Clone and Navigate**
```bash
cd safety_app
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Generate Code** (for Hive if used)
```bash
flutter pub run build_runner build
```

4. **Run the App**
```bash
flutter run
```

### Testing the App

1. **Login**
   - Username: `admin`
   - Password: `admin123`

2. **Create Alarm**
   - Navigate to Alarms tab
   - Click + button
   - Set title, time, and recurrence
   - Save

3. **Test SOS**
   - Navigate to SOS tab
   - Enter incident details
   - Select severity
   - Send alert
   - Check Incidents for confirmation

4. **Location Tracking**
   - Navigate to Location tab
   - Request location permission
   - Click "Start Tracking"
   - View live location and history

## 🔔 Real-Time Features

### Alarm Triggering
- Alarms check every 60 seconds
- Triggers at scheduled time
- Shows notification
- Streams event to UI
- Updates database

### Location Updates
- Updates every 30 seconds or 10 meters
- Real-time stream to UI
- Saves to database
- Shows accuracy

### Notifications
- Local notifications for alarms
- Custom notification channel
- Vibration and sound
- Action buttons (Snooze/Dismiss)

## 📈 Performance Optimizations

- Efficient database queries with indexing
- Stream-based location updates
- Lazy loading of incident lists
- Optimized widget rebuilds with Riverpod
- SQLite for fast local access

## 🔒 Security Features

- Local data storage (no cloud by default)
- Token-based sessions
- User data isolation
- Encrypted fields ready
- Secure storage capable

## 🎯 Key Improvements Over Original App

| Feature | Original | Enterprise |
|---------|----------|-----------|
| Architecture | Basic screens | Clean + Layered |
| State Management | None | Riverpod |
| Database | In-memory | SQLite |
| Alarms | Basic | Real-time + Recurring |
| Location | None | GPS + History |
| Notifications | SnackBar | Local Notifications |
| UI/UX | Basic buttons | Material Design 3 |
| Incident Logging | None | Comprehensive |
| Authentication | Hardcoded | Service-based |

## 🛠️ Development

### Adding New Features

1. **Create Model** in `data/models/`
2. **Create Service** in `services/`
3. **Add Provider** in `providers/`
4. **Build Screen** in `ui/screens/`
5. **Update Navigation** in `home_screen.dart`

### Database Migration

Update `_onUpgrade` in `database_service.dart`:
```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE incidents ADD COLUMN new_field TEXT');
  }
}
```

## 📝 Notes

- App uses dummy authentication for development
- Ready for API backend integration
- All data persisted locally
- No internet required (offline-first)
- Easy to extend with more features

## 🚀 Future Enhancements

- [ ] Firebase integration for cloud backup
- [ ] Real-time API sync
- [ ] SMS/Call emergency notifications
- [ ] Photo/video attachments
- [ ] Advanced mapping features
- [ ] Biometric authentication
- [ ] Dark mode toggle
- [ ] Multi-language support

## 📞 Support

For issues or feature requests, refer to the code documentation and comments throughout the application.

---

**SafetyPro v1.0.0** - Enterprise-Grade Safety Management Solution
