import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../services/location_service.dart';
import 'auth_provider.dart';

final locationServiceProvider = Provider((ref) => LocationService());

final currentLocationProvider =
    StateNotifierProvider<CurrentLocationNotifier, LocationData?>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  return CurrentLocationNotifier(
    locationService: locationService,
    userId: currentUser?.id,
  );
});

final locationHistoryProvider =
    StateNotifierProvider<LocationHistoryNotifier, List<LocationData>>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  return LocationHistoryNotifier(
    locationService: locationService,
    userId: currentUser?.id,
  );
});

final locationTrackingProvider = StateProvider<bool>((ref) => false);
final locationPermissionProvider = StateProvider<bool>((ref) => false);

class CurrentLocationNotifier extends StateNotifier<LocationData?> {
  final LocationService locationService;
  final String? userId;

  CurrentLocationNotifier({
    required this.locationService,
    required this.userId,
  }) : super(null) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (userId != null) {
      final location = await locationService.getCurrentLocation();
      state = location;

      // Listen to location updates
      locationService.locationStream.listen((location) {
        state = location;
      });
    }
  }

  Future<bool> checkPermission() async {
    return await locationService.checkLocationPermission();
  }

  Future<bool> isServiceEnabled() async {
    return await locationService.isLocationServiceEnabled();
  }

  Future<LocationData?> refreshLocation() async {
    try {
      final location = await locationService.getCurrentLocation();
      state = location;
      return location;
    } catch (e) {
      rethrow;
    }
  }
}

class LocationHistoryNotifier extends StateNotifier<List<LocationData>> {
  final LocationService locationService;
  final String? userId;

  LocationHistoryNotifier({
    required this.locationService,
    required this.userId,
  }) : super([]) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (userId != null) {
      await refreshHistory();
    }
  }

  Future<void> refreshHistory({int limit = 100}) async {
    if (userId == null) return;

    try {
      final history = await locationService.getLocationHistory(userId!, limit: limit);
      state = history;
    } catch (e) {
      // Handle error silently
    }
  }

  Future<double> calculateDistance(
      double lat1, double lon1, double lat2, double lon2) async {
    try {
      return await locationService.calculateDistance(lat1, lon1, lat2, lon2);
    } catch (e) {
      rethrow;
    }
  }
}
