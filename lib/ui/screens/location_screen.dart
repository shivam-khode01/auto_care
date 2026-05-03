import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';

class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final hasPermission = await ref
        .read(currentLocationProvider.notifier)
        .checkPermission();

    if (mounted) {
      ref.read(locationPermissionProvider.state).state = hasPermission;
    }
  }

  Future<void> _toggleLocationTracking() async {
    if (!_isTracking) {
      // Start tracking
      final isEnabled = await ref
          .read(currentLocationProvider.notifier)
          .isServiceEnabled();

      if (!isEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services')),
          );
        }
        return;
      }

      ref.read(locationServiceProvider).startLocationTracking(
            ref.read(currentUserProvider)?.id ?? '',
          );

      if (mounted) {
        setState(() => _isTracking = true);
        ref.read(locationTrackingProvider.state).state = true;
      }
    } else {
      // Stop tracking
      ref.read(locationServiceProvider).stopLocationTracking();
      if (mounted) {
        setState(() => _isTracking = false);
        ref.read(locationTrackingProvider.state).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = ref.watch(currentLocationProvider);
    final locationHistory = ref.watch(locationHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              ref.read(currentLocationProvider.notifier).refreshLocation();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Current Location Card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Location',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _isTracking ? Colors.green : Colors.grey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (currentLocation != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(
                            'Latitude',
                            currentLocation.latitude.toString(),
                          ),
                          _infoRow(
                            'Longitude',
                            currentLocation.longitude.toString(),
                          ),
                          _infoRow(
                            'Accuracy',
                            '${currentLocation.accuracy.toStringAsFixed(2)} m',
                          ),
                          _infoRow(
                            'Altitude',
                            '${currentLocation.altitude.toStringAsFixed(2)} m',
                          ),
                          _infoRow(
                            'Speed',
                            '${currentLocation.speed.toStringAsFixed(2)} m/s',
                          ),
                          _infoRow(
                            'Updated',
                            currentLocation.timestamp.toString(),
                          ),
                        ],
                      )
                    else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Getting location...',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Location Tracking Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isTracking ? AppTheme.errorColor : AppTheme.primaryColor,
                ),
                icon: Icon(_isTracking ? Icons.stop_circle : Icons.play_arrow),
                label: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
                onPressed: _toggleLocationTracking,
              ),
            ),
            const SizedBox(height: 24),

            // Location History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Location History',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '${locationHistory.length} locations',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (locationHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No location history available',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    locationHistory.length > 10 ? 10 : locationHistory.length,
                itemBuilder: (context, index) {
                  final location = locationHistory[index];
                  return ListTile(
                    leading: Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    title: Text(
                      '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    subtitle: Text(
                      location.timestamp.toString(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    trailing: Text(
                      '±${location.accuracy.toStringAsFixed(0)}m',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
