import 'package:intl/intl.dart';

// Emergency Contact Model with Priority
class EmergencyContact {
  final String id;
  final String phoneNumber;
  final String name;
  final String priority; // 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW'

  EmergencyContact({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.priority = 'MEDIUM',
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      name: json['name'] ?? '',
      priority: json['priority'] ?? 'MEDIUM',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'priority': priority,
    };
  }

  EmergencyContact copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? priority,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      priority: priority ?? this.priority,
    );
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final String phoneNumber;
  final String profileImage;
  final List<EmergencyContact> emergencyContacts;
  final bool isActive;
  final DateTime lastLogin;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.profileImage = '',
    this.emergencyContacts = const [],
    this.isActive = true,
    required this.lastLogin,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profileImage: json['profileImage'] ?? '',
      emergencyContacts: (json['emergencyContacts'] as List?)
              ?.map((c) => EmergencyContact.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: json['isActive'] ?? true,
      lastLogin: DateTime.parse(json['lastLogin'] ?? DateTime.now().toString()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'emergencyContacts': emergencyContacts.map((c) => c.toJson()).toList(),
      'isActive': isActive,
      'lastLogin': lastLogin.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phoneNumber,
    String? profileImage,
    List<EmergencyContact>? emergencyContacts,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Incident {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category; // 'SOS', 'ALARM', 'ROUTINE', 'ALERT'
  final String severity; // 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
  final double latitude;
  final double longitude;
  final String status; // 'PENDING', 'ACKNOWLEDGED', 'RESOLVED'
  final DateTime timestamp;
  final DateTime? resolvedAt;
  final List<String> attachments;
  final Map<String, dynamic> metadata;

  Incident({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.latitude,
    required this.longitude,
    this.status = 'PENDING',
    required this.timestamp,
    this.resolvedAt,
    this.attachments = const [],
    this.metadata = const {},
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'ALERT',
      severity: json['severity'] ?? 'MEDIUM',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      status: json['status'] ?? 'PENDING',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'severity': severity,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  String get formattedTime => DateFormat('MMM dd, yyyy hh:mm a').format(timestamp);

  Incident copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    String? severity,
    double? latitude,
    double? longitude,
    String? status,
    DateTime? timestamp,
    DateTime? resolvedAt,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return Incident(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }
}

class SafetyAlarm {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String alarmType; // 'SCHEDULED', 'RECURRING', 'PROXIMITY'
  final DateTime scheduledTime;
  final String recurrence; // 'NONE', 'DAILY', 'WEEKLY', 'MONTHLY'
  final List<int>? recurrenceDays; // 0=Sunday, 1=Monday, etc.
  final String notificationSound;
  final bool isActive;
  final int snoozeDuration; // in minutes
  final DateTime createdAt;
  final DateTime? lastTriggered;

  SafetyAlarm({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.alarmType,
    required this.scheduledTime,
    this.recurrence = 'NONE',
    this.recurrenceDays,
    this.notificationSound = 'default',
    this.isActive = true,
    this.snoozeDuration = 5,
    required this.createdAt,
    this.lastTriggered,
  });

  factory SafetyAlarm.fromJson(Map<String, dynamic> json) {
    return SafetyAlarm(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      alarmType: json['alarmType'] ?? 'SCHEDULED',
      scheduledTime:
          DateTime.parse(json['scheduledTime'] ?? DateTime.now().toString()),
      recurrence: json['recurrence'] ?? 'NONE',
      recurrenceDays: json['recurrenceDays'] != null
          ? List<int>.from(json['recurrenceDays'])
          : null,
      notificationSound: json['notificationSound'] ?? 'default',
      isActive: json['isActive'] ?? true,
      snoozeDuration: json['snoozeDuration'] ?? 5,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      lastTriggered: json['lastTriggered'] != null
          ? DateTime.parse(json['lastTriggered'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'alarmType': alarmType,
      'scheduledTime': scheduledTime.toIso8601String(),
      'recurrence': recurrence,
      'recurrenceDays': recurrenceDays,
      'notificationSound': notificationSound,
      'isActive': isActive,
      'snoozeDuration': snoozeDuration,
      'createdAt': createdAt.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
    };
  }

  String get formattedTime => DateFormat('hh:mm a').format(scheduledTime);

  SafetyAlarm copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? alarmType,
    DateTime? scheduledTime,
    String? recurrence,
    List<int>? recurrenceDays,
    String? notificationSound,
    bool? isActive,
    int? snoozeDuration,
    DateTime? createdAt,
    DateTime? lastTriggered,
  }) {
    return SafetyAlarm(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      alarmType: alarmType ?? this.alarmType,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      recurrence: recurrence ?? this.recurrence,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
      notificationSound: notificationSound ?? this.notificationSound,
      isActive: isActive ?? this.isActive,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
    );
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final DateTime timestamp;
  final String? address;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude = 0.0,
    this.speed = 0.0,
    required this.timestamp,
    this.address,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      accuracy: json['accuracy'] ?? 0.0,
      altitude: json['altitude'] ?? 0.0,
      speed: json['speed'] ?? 0.0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
    };
  }
}
