import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../services/incident_service.dart';
import 'auth_provider.dart';

final incidentServiceProvider = Provider((ref) => IncidentService());

final incidentsProvider = StateNotifierProvider<IncidentsNotifier, List<Incident>>(
  (ref) {
    final incidentService = ref.watch(incidentServiceProvider);
    final currentUser = ref.watch(currentUserProvider);

    return IncidentsNotifier(
      incidentService: incidentService,
      userId: currentUser?.id,
    );
  },
);

final incidentLoadingProvider = StateProvider<bool>((ref) => false);

class IncidentsNotifier extends StateNotifier<List<Incident>> {
  final IncidentService incidentService;
  final String? userId;

  IncidentsNotifier({
    required this.incidentService,
    required this.userId,
  }) : super([]) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (userId != null) {
      await refreshIncidents();
    }
  }

  Future<void> refreshIncidents() async {
    if (userId == null) return;

    try {
      final incidents = await incidentService.getIncidents(userId!);
      state = incidents;
    } catch (e) {
      // Handle error silently
    }
  }

  Future<Incident?> createSOSIncident({
    required String title,
    required String description,
    required String severity,
  }) async {
    if (userId == null) return null;

    try {
      final incident = await incidentService.createSOSIncident(
        userId: userId!,
        title: title,
        description: description,
        severity: severity,
      );

      if (incident != null) {
        state = [incident, ...state];
      }

      return incident;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateIncidentStatus(String incidentId, String status) async {
    try {
      await incidentService.updateIncidentStatus(incidentId, status);
      state = [
        for (final incident in state)
          if (incident.id == incidentId)
            incident.copyWith(status: status)
          else
            incident,
      ];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acknowledgeIncident(String incidentId) async {
    try {
      await incidentService.acknowledgeIncident(incidentId);
      await refreshIncidents();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resolveIncident(String incidentId) async {
    try {
      await incidentService.resolveIncident(incidentId);
      await refreshIncidents();
    } catch (e) {
      rethrow;
    }
  }

  List<Incident> getUnresolvedIncidents() {
    return state.where((i) => i.status != 'RESOLVED').toList();
  }

  List<Incident> getCriticalIncidents() {
    return state.where((i) => i.severity == 'CRITICAL').toList();
  }

  Map<String, int> getStatistics() {
    return incidentService.getIncidentStatistics(state);
  }
}
