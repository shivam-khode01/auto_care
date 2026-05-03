import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../services/alarm_service.dart';
import 'auth_provider.dart';

final alarmServiceProvider = Provider((ref) => AlarmService());

final alarmsProvider = StateNotifierProvider<AlarmsNotifier, List<SafetyAlarm>>(
  (ref) {
    final alarmService = ref.watch(alarmServiceProvider);
    final currentUser = ref.watch(currentUserProvider);

    return AlarmsNotifier(
      alarmService: alarmService,
      userId: currentUser?.id,
    );
  },
);

final alarmLoadingProvider = StateProvider<bool>((ref) => false);

class AlarmsNotifier extends StateNotifier<List<SafetyAlarm>> {
  final AlarmService alarmService;
  final String? userId;

  AlarmsNotifier({
    required this.alarmService,
    required this.userId,
  }) : super([]) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (userId != null) {
      await refreshAlarms();
      alarmService.startAlarmMonitoring(userId!);
    }
  }

  Future<void> refreshAlarms() async {
    if (userId == null) return;
    
    try {
      final alarms = await alarmService.getAlarms(userId!);
      state = alarms;
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> addAlarm(SafetyAlarm alarm) async {
    try {
      await alarmService.createAlarm(alarm);
      state = [...state, alarm];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAlarm(SafetyAlarm alarm) async {
    try {
      await alarmService.updateAlarm(alarm);
      state = [
        for (final a in state)
          if (a.id == alarm.id) alarm else a,
      ];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAlarm(String alarmId) async {
    try {
      await alarmService.deleteAlarm(alarmId);
      state = state.where((a) => a.id != alarmId).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> snoozeAlarm(SafetyAlarm alarm, int minutes) async {
    try {
      await alarmService.snoozeAlarm(alarm, minutes);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> dismissAlarm(SafetyAlarm alarm) async {
    try {
      await alarmService.dismissAlarm(alarm);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    alarmService.stopAlarmMonitoring();
    super.dispose();
  }
}
