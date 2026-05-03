import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import '../core/constants/app_constants.dart';
import '../data/models/models.dart';
import 'database_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  final logger = Logger();
  final DatabaseService _dbService = DatabaseService();

  StreamSubscription<Position>? _positionStream;
  late StreamController<LocationData> _locationStream;
  String? _currentUserId;

  LocationService._internal() {
    _locationStream = StreamController<LocationData>.broadcast();
  }

  factory LocationService() {
    return _instance;
  }

  Stream<LocationData> get locationStream => _locationStream.stream;

  Future<bool> checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        logger.w('Location permission permanently denied');
        return false;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        logger.i('Location permission granted');
        return true;
      }

      return false;
    } catch (e) {
      logger.e('Error checking location permission: $e');
      return false;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      logger.e('Error checking location service: $e');
      return false;
    }
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        logger.w('No location permission');
        return null;
      }

      final isEnabled = await isLocationServiceEnabled();
      if (!isEnabled) {
        logger.w('Location service is disabled');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      logger.e('Error getting current location: $e');
      return null;
    }
  }

  void startLocationTracking(String userId) {
    if (_currentUserId == userId && _positionStream != null) {
      logger.i('Location tracking already running for user: $userId');
      return;
    }

    _currentUserId = userId;
    logger.i('Starting location tracking for user: $userId');

    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter:
            10, // Update every 10 meters or every 30 seconds
        timeLimit: Duration(
            seconds: AppConstants.locationUpdateIntervalSeconds),
      ),
    ).listen(
      (Position position) {
        final locationData = LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          altitude: position.altitude,
          speed: position.speed,
          timestamp: DateTime.now(),
        );

        _locationStream.add(locationData);
        _saveLocation(userId, locationData);

        logger.d(
            'Location updated: (${position.latitude}, ${position.longitude})');
      },
      onError: (error) {
        logger.e('Location tracking error: $error');
      },
    );
  }

  void stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    logger.i('Location tracking stopped');
  }

  void _saveLocation(String userId, LocationData locationData) async {
    try {
      await _dbService.insertLocation(userId, locationData);
    } catch (e) {
      logger.e('Error saving location: $e');
    }
  }

  Future<List<LocationData>> getLocationHistory(String userId,
      {int limit = 100}) async {
    try {
      return await _dbService.getLocationHistory(userId, limit: limit);
    } catch (e) {
      logger.e('Error getting location history: $e');
      return [];
    }
  }

  Future<double> calculateDistance(
      double lat1, double lon1, double lat2, double lon2) async {
    try {
      final distance = await Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
      return distance;
    } catch (e) {
      logger.e('Error calculating distance: $e');
      return 0.0;
    }
  }

  void dispose() {
    stopLocationTracking();
    _locationStream.close();
  }
}
