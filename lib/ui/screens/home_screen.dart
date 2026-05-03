import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/alarm_provider.dart';
import 'sos_screen.dart';
import 'alarms_screen.dart';
import 'incidents_screen.dart';
import 'location_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final incidents = ref.watch(incidentsProvider);
    final alarms = ref.watch(alarmsProvider);

    final pages = [
      _buildDashboard(context, incidents, alarms),
      const SOSScreen(),
      const AlarmsScreen(),
      const IncidentsScreen(),
      const LocationScreen(),
      const ProfileScreen(),
    ];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SafetyPro Dashboard'),
          elevation: 0,
          actions: [
            Badge(
              isLabelVisible: incidents.any((i) => i.status == 'PENDING'),
              label: Text(
                incidents.where((i) => i.status == 'PENDING').length.toString(),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  setState(() => _currentIndex = 3);
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () {
                setState(() => _currentIndex = 5);
              },
            ),
          ],
        ),
        body: pages[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.emergency_share_outlined),
              selectedIcon: Icon(Icons.emergency_share),
              label: 'SOS',
            ),
            NavigationDestination(
              icon: Icon(Icons.alarm_outlined),
              selectedIcon: Icon(Icons.alarm),
              label: 'Alarms',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Incidents',
            ),
            NavigationDestination(
              icon: Icon(Icons.location_on_outlined),
              selectedIcon: Icon(Icons.location_on),
              label: 'Location',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, List incidents, List alarms) {
    final unresolvedCount =
        incidents.where((i) => i.status != 'RESOLVED').length;
    final criticalCount = incidents.where((i) => i.severity == 'CRITICAL').length;
    final activeAlarms = alarms.where((a) => a.isActive).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Unresolved',
                  unresolvedCount.toString(),
                  Colors.orange,
                  Icons.warning_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Critical',
                  criticalCount.toString(),
                  Colors.red,
                  Icons.emergency_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Active Alarms',
                  activeAlarms.toString(),
                  Colors.blue,
                  Icons.alarm_on_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Incidents',
                  incidents.length.toString(),
                  Colors.purple,
                  Icons.history_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildActionCard(
                context,
                'SOS Alert',
                Icons.emergency_share_outlined,
                AppTheme.errorColor,
                () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('SOS Emergency'),
                      content: const Text('Are you sure you want to send an SOS alert?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() => _currentIndex = 1);
                          },
                          child: const Text('Send SOS'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _buildActionCard(
                context,
                'Create Alarm',
                Icons.add_alarm_outlined,
                AppTheme.primaryColor,
                () {
                  setState(() => _currentIndex = 2);
                },
              ),
              _buildActionCard(
                context,
                'View Location',
                Icons.location_on_outlined,
                AppTheme.secondaryColor,
                () {
                  setState(() => _currentIndex = 4);
                },
              ),
              _buildActionCard(
                context,
                'View Incidents',
                Icons.list_alt_outlined,
                Colors.green,
                () {
                  setState(() => _currentIndex = 3);
                },
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Recent Incidents
          if (incidents.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Incidents',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (incidents.length > 3 ? 3 : incidents.length),
                  itemBuilder: (context, index) {
                    final incident = incidents[index];
                    return _buildIncidentCard(context, incident);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentCard(BuildContext context, dynamic incident) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: incident.severity == 'CRITICAL'
                        ? Colors.red
                        : incident.severity == 'HIGH'
                            ? Colors.orange
                            : Colors.yellow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        incident.formattedTime,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: incident.status == 'RESOLVED'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    incident.status,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: incident.status == 'RESOLVED'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
