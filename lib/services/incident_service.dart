import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../data/models/models.dart';
import 'database_service.dart';
import 'location_service.dart';

class IncidentService {
  static final IncidentService _instance = IncidentService._internal();
  final logger = Logger();
  final DatabaseService _dbService = DatabaseService();
  final LocationService _locationService = LocationService();
  final uuid = Uuid();

  IncidentService._internal();

  factory IncidentService() {
    return _instance;
  }

  Future<Incident?> createSOSIncident({
    required String userId,
    required String title,
    required String description,
    required String severity,
  }) async {
    try {
      final location = await _locationService.getCurrentLocation();

      if (location == null) {
        logger.w('Could not get current location for SOS');
        return null;
      }

      final incident = Incident(
        id: const Uuid().v4(),
        userId: userId,
        title: title,
        description: description,
        category: 'SOS',
        severity: severity,
        latitude: location.latitude,
        longitude: location.longitude,
        status: 'PENDING',
        timestamp: DateTime.now(),
        metadata: {
          'type': 'emergency_sos',
          'urgency': 'critical',
        },
      );

      await _dbService.insertIncident(incident);
      logger.i('SOS incident created: ${incident.id}');
      return incident;
    } catch (e) {
      logger.e('Error creating SOS incident: $e');
      return null;
    }
  }

  Future<Incident?> createAlarmIncident({
    required String userId,
    required String alarmTitle,
    required String severity,
  }) async {
    try {
      final location = await _locationService.getCurrentLocation();

      final incident = Incident(
        id: const Uuid().v4(),
        userId: userId,
        title: alarmTitle,
        description: 'Alarm triggered at ${DateTime.now()}',
        category: 'ALARM',
        severity: severity,
        latitude: location?.latitude ?? 0.0,
        longitude: location?.longitude ?? 0.0,
        status: 'PENDING',
        timestamp: DateTime.now(),
        metadata: {
          'type': 'alarm_trigger',
          'hasLocation': location != null,
        },
      );

      await _dbService.insertIncident(incident);
      logger.i('Alarm incident created: ${incident.id}');
      return incident;
    } catch (e) {
      logger.e('Error creating alarm incident: $e');
      return null;
    }
  }

  Future<List<Incident>> getIncidents(String userId,
      {int limit = 50, int offset = 0}) async {
    try {
      return await _dbService.getIncidents(userId, limit: limit, offset: offset);
    } catch (e) {
      logger.e('Error fetching incidents: $e');
      return [];
    }
  }

  Future<List<Incident>> getIncidentsByCategory(String userId, String category,
      {int limit = 50}) async {
    try {
      final incidents = await _dbService.getIncidents(userId, limit: limit);
      return incidents.where((incident) => incident.category == category).toList();
    } catch (e) {
      logger.e('Error fetching incidents by category: $e');
      return [];
    }
  }

  Future<List<Incident>> getIncidentsBySeverity(String userId, String severity,
      {int limit = 50}) async {
    try {
      final incidents = await _dbService.getIncidents(userId, limit: limit);
      return incidents.where((incident) => incident.severity == severity).toList();
    } catch (e) {
      logger.e('Error fetching incidents by severity: $e');
      return [];
    }
  }

  Future<List<Incident>> getUnresolvedIncidents(String userId,
      {int limit = 50}) async {
    try {
      final incidents = await _dbService.getIncidents(userId, limit: limit);
      return incidents
          .where((incident) => incident.status != 'RESOLVED')
          .toList();
    } catch (e) {
      logger.e('Error fetching unresolved incidents: $e');
      return [];
    }
  }

  Future<void> updateIncidentStatus(String incidentId, String status) async {
    try {
      await _dbService.updateIncidentStatus(incidentId, status);
      logger.i('Incident status updated: $incidentId -> $status');
    } catch (e) {
      logger.e('Error updating incident status: $e');
      rethrow;
    }
  }

  Future<void> acknowledgeIncident(String incidentId) async {
    try {
      await updateIncidentStatus(incidentId, 'ACKNOWLEDGED');
      logger.i('Incident acknowledged: $incidentId');
    } catch (e) {
      logger.e('Error acknowledging incident: $e');
      rethrow;
    }
  }

  Future<void> resolveIncident(String incidentId) async {
    try {
      await updateIncidentStatus(incidentId, 'RESOLVED');
      logger.i('Incident resolved: $incidentId');
    } catch (e) {
      logger.e('Error resolving incident: $e');
      rethrow;
    }
  }

  Map<String, int> getIncidentStatistics(List<Incident> incidents) {
    return {
      'total': incidents.length,
      'pending': incidents.where((i) => i.status == 'PENDING').length,
      'acknowledged': incidents.where((i) => i.status == 'ACKNOWLEDGED').length,
      'resolved': incidents.where((i) => i.status == 'RESOLVED').length,
      'critical': incidents.where((i) => i.severity == 'CRITICAL').length,
      'high': incidents.where((i) => i.severity == 'HIGH').length,
      'medium': incidents.where((i) => i.severity == 'MEDIUM').length,
      'low': incidents.where((i) => i.severity == 'LOW').length,
    };
  }

  Future<void> createDummyIncidents(String userId) async {
    try {
      // Check if dummy incidents already exist
      final incidents = await getIncidents(userId);
      if (incidents.isNotEmpty) {
        logger.i('Dummy incidents already exist, skipping creation');
        return;
      }

      final now = DateTime.now();

      // Incident 1: Fall Detected (2 hours ago)
      final fallIncident = Incident(
        id: const Uuid().v4(),
        userId: userId,
        title: 'Fall Detected',
        description: 'User fall detected by accelerometer sensors. Immediate assistance may be needed.',
        category: 'ALERT',
        severity: 'HIGH',
        latitude: 0.0,
        longitude: 0.0,
        status: 'ACKNOWLEDGED',
        timestamp: now.subtract(const Duration(hours: 2)),
        metadata: {
          'type': 'fall_detection',
          'urgency': 'high',
        },
      );

      // Incident 2: Unknown Person Detected (1 hour ago)
      final unknownPersonIncident = Incident(
        id: const Uuid().v4(),
        userId: userId,
        title: 'Unknown Person Detected',
        description: 'Unrecognized visitor detected at the door. Facial recognition failed.',
        category: 'ALERT',
        severity: 'MEDIUM',
        latitude: 0.0,
        longitude: 0.0,
        status: 'PENDING',
        timestamp: now.subtract(const Duration(hours: 1)),
        metadata: {
          'type': 'unknown_person',
          'urgency': 'medium',
        },
      );

      // Incident 3: Medicine Not Taken (30 minutes ago)
      final medicineIncident = Incident(
        id: const Uuid().v4(),
        userId: userId,
        title: 'Medicine Not Taken',
        description: 'Scheduled medicine dose at 2:30 PM was missed. Please take your medication.',
        category: 'ROUTINE',
        severity: 'LOW',
        latitude: 0.0,
        longitude: 0.0,
        status: 'PENDING',
        timestamp: now.subtract(const Duration(minutes: 30)),
        metadata: {
          'type': 'medicine_reminder',
          'medicineTime': '2:30 PM',
          'urgency': 'low',
        },
      );

      await _dbService.insertIncident(fallIncident);
      await _dbService.insertIncident(unknownPersonIncident);
      await _dbService.insertIncident(medicineIncident);

      logger.i('💡 Dummy incidents created successfully:');
      logger.i('  - Fall Detected (2 hours ago)');
      logger.i('  - Unknown Person Detected (1 hour ago)');
      logger.i('  - Medicine Not Taken (30 minutes ago)');
    } catch (e) {
      logger.e('Error creating dummy incidents: $e');
    }
  }

  void dispose() {
    // Cleanup if needed
  }
}
