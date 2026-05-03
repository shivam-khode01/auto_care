import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/constants/app_constants.dart';
import '../data/models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  final logger = Logger();

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    logger.i('Creating database tables');

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        profileImage TEXT,
        emergencyContacts TEXT,
        isActive INTEGER NOT NULL,
        lastLogin TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Incidents table
    await db.execute('''
      CREATE TABLE incidents (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        severity TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        status TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        resolvedAt TEXT,
        attachments TEXT,
        metadata TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Alarms table
    await db.execute('''
      CREATE TABLE alarms (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        alarmType TEXT NOT NULL,
        scheduledTime TEXT NOT NULL,
        recurrence TEXT NOT NULL,
        recurrenceDays TEXT,
        notificationSound TEXT,
        isActive INTEGER NOT NULL,
        snoozeDuration INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        lastTriggered TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Location History table
    await db.execute('''
      CREATE TABLE location_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy REAL NOT NULL,
        altitude REAL,
        speed REAL,
        timestamp TEXT NOT NULL,
        address TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    logger.i('Database tables created successfully');
  }

  Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    logger.i('Upgrading database from v$oldVersion to v$newVersion');
  }

  // User operations
  Future<void> insertUser(User user) async {
    final db = await database;
    try {
      await db.insert('users', {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'profileImage': user.profileImage,
        'emergencyContacts': user.emergencyContacts
            .map((c) => '${c.id}|${c.phoneNumber}|${c.name}|${c.priority}')
            .join(','),
        'isActive': user.isActive ? 1 : 0,
        'lastLogin': user.lastLogin.toIso8601String(),
        'createdAt': user.createdAt.toIso8601String(),
      });
      logger.i('User inserted: ${user.id}');
    } catch (e) {
      logger.e('Error inserting user: $e');
      rethrow;
    }
  }

  Future<User?> getUser(String userId) async {
    final db = await database;
    try {
      final result = await db.query('users', where: 'id = ?', whereArgs: [userId]);
      if (result.isNotEmpty) {
        return _userFromMap(result.first);
      }
      return null;
    } catch (e) {
      logger.e('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    try {
      await db.update(
        'users',
        {
          'username': user.username,
          'email': user.email,
          'phoneNumber': user.phoneNumber,
          'profileImage': user.profileImage,
          'emergencyContacts': user.emergencyContacts
              .map((c) => '${c.id}|${c.phoneNumber}|${c.name}|${c.priority}')
              .join(','),
          'isActive': user.isActive ? 1 : 0,
          'lastLogin': user.lastLogin.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );
      logger.i('User updated: ${user.id}');
    } catch (e) {
      logger.e('Error updating user: $e');
      rethrow;
    }
  }

  // Incident operations
  Future<void> insertIncident(Incident incident) async {
    final db = await database;
    try {
      await db.insert('incidents', {
        'id': incident.id,
        'userId': incident.userId,
        'title': incident.title,
        'description': incident.description,
        'category': incident.category,
        'severity': incident.severity,
        'latitude': incident.latitude,
        'longitude': incident.longitude,
        'status': incident.status,
        'timestamp': incident.timestamp.toIso8601String(),
        'resolvedAt': incident.resolvedAt?.toIso8601String(),
        'attachments': incident.attachments.join(','),
        'metadata': incident.metadata.toString(),
      });
      logger.i('Incident inserted: ${incident.id}');
    } catch (e) {
      logger.e('Error inserting incident: $e');
      rethrow;
    }
  }

  Future<List<Incident>> getIncidents(String userId,
      {int limit = 50, int offset = 0}) async {
    final db = await database;
    try {
      final result = await db.query(
        'incidents',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'timestamp DESC',
        limit: limit,
        offset: offset,
      );
      return result.map((map) => _incidentFromMap(map)).toList();
    } catch (e) {
      logger.e('Error getting incidents: $e');
      return [];
    }
  }

  Future<void> updateIncidentStatus(String incidentId, String status) async {
    final db = await database;
    try {
      await db.update(
        'incidents',
        {
          'status': status,
          'resolvedAt': status == 'RESOLVED' ? DateTime.now().toIso8601String() : null,
        },
        where: 'id = ?',
        whereArgs: [incidentId],
      );
      logger.i('Incident status updated: $incidentId -> $status');
    } catch (e) {
      logger.e('Error updating incident status: $e');
      rethrow;
    }
  }

  // Alarm operations
  Future<void> insertAlarm(SafetyAlarm alarm) async {
    final db = await database;
    try {
      await db.insert('alarms', {
        'id': alarm.id,
        'userId': alarm.userId,
        'title': alarm.title,
        'description': alarm.description,
        'alarmType': alarm.alarmType,
        'scheduledTime': alarm.scheduledTime.toIso8601String(),
        'recurrence': alarm.recurrence,
        'recurrenceDays': alarm.recurrenceDays?.join(','),
        'notificationSound': alarm.notificationSound,
        'isActive': alarm.isActive ? 1 : 0,
        'snoozeDuration': alarm.snoozeDuration,
        'createdAt': alarm.createdAt.toIso8601String(),
        'lastTriggered': alarm.lastTriggered?.toIso8601String(),
      });
      logger.i('Alarm inserted: ${alarm.id}');
    } catch (e) {
      logger.e('Error inserting alarm: $e');
      rethrow;
    }
  }

  Future<List<SafetyAlarm>> getAlarms(String userId) async {
    final db = await database;
    try {
      final result = await db.query(
        'alarms',
        where: 'userId = ? AND isActive = 1',
        whereArgs: [userId],
        orderBy: 'scheduledTime ASC',
      );
      return result.map((map) => _alarmFromMap(map)).toList();
    } catch (e) {
      logger.e('Error getting alarms: $e');
      return [];
    }
  }

  Future<void> updateAlarm(SafetyAlarm alarm) async {
    final db = await database;
    try {
      await db.update(
        'alarms',
        {
          'title': alarm.title,
          'description': alarm.description,
          'scheduledTime': alarm.scheduledTime.toIso8601String(),
          'recurrence': alarm.recurrence,
          'isActive': alarm.isActive ? 1 : 0,
          'lastTriggered': alarm.lastTriggered?.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [alarm.id],
      );
      logger.i('Alarm updated: ${alarm.id}');
    } catch (e) {
      logger.e('Error updating alarm: $e');
      rethrow;
    }
  }

  Future<void> deleteAlarm(String alarmId) async {
    final db = await database;
    try {
      await db.delete('alarms', where: 'id = ?', whereArgs: [alarmId]);
      logger.i('Alarm deleted: $alarmId');
    } catch (e) {
      logger.e('Error deleting alarm: $e');
      rethrow;
    }
  }

  // Location operations
  Future<void> insertLocation(String userId, LocationData location) async {
    final db = await database;
    try {
      await db.insert('location_history', {
        'userId': userId,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'accuracy': location.accuracy,
        'altitude': location.altitude,
        'speed': location.speed,
        'timestamp': location.timestamp.toIso8601String(),
        'address': location.address,
      });
    } catch (e) {
      logger.e('Error inserting location: $e');
    }
  }

  Future<List<LocationData>> getLocationHistory(String userId,
      {int limit = 100}) async {
    final db = await database;
    try {
      final result = await db.query(
        'location_history',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      return result
          .map((map) => LocationData(
            latitude: map['latitude'] as double,
            longitude: map['longitude'] as double,
            accuracy: map['accuracy'] as double,
            altitude: (map['altitude'] as num?)?.toDouble() ?? 0.0,
            speed: (map['speed'] as num?)?.toDouble() ?? 0.0,
            timestamp: DateTime.parse(map['timestamp'] as String),
            address: map['address'] as String?,
          ))
          .toList();
    } catch (e) {
      logger.e('Error getting location history: $e');
      return [];
    }
  }

  // Helper methods
  User _userFromMap(Map<String, dynamic> map) {
    List<EmergencyContact> contacts = [];
    final contactsStr = map['emergencyContacts'] as String?;
    if (contactsStr != null && contactsStr.isNotEmpty) {
      final contactParts = contactsStr.split(',');
      for (var part in contactParts) {
        final parts = part.split('|');
        if (parts.length == 4) {
          contacts.add(EmergencyContact(
            id: parts[0],
            phoneNumber: parts[1],
            name: parts[2],
            priority: parts[3],
          ));
        }
      }
    }

    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      profileImage: map['profileImage'] ?? '',
      emergencyContacts: contacts,
      isActive: (map['isActive'] as int) == 1,
      lastLogin: DateTime.parse(map['lastLogin']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Incident _incidentFromMap(Map<String, dynamic> map) {
    return Incident(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      severity: map['severity'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      status: map['status'],
      timestamp: DateTime.parse(map['timestamp']),
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.parse(map['resolvedAt'])
          : null,
      attachments: (map['attachments'] as String?)?.split(',') ?? [],
    );
  }

  SafetyAlarm _alarmFromMap(Map<String, dynamic> map) {
    return SafetyAlarm(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      alarmType: map['alarmType'],
      scheduledTime: DateTime.parse(map['scheduledTime']),
      recurrence: map['recurrence'] ?? 'NONE',
      recurrenceDays: (map['recurrenceDays'] as String?)
          ?.split(',')
          .map((e) => int.parse(e))
          .toList(),
      notificationSound: map['notificationSound'] ?? 'default',
      isActive: (map['isActive'] as int) == 1,
      snoozeDuration: map['snoozeDuration'] ?? 5,
      createdAt: DateTime.parse(map['createdAt']),
      lastTriggered: map['lastTriggered'] != null
          ? DateTime.parse(map['lastTriggered'])
          : null,
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
