import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../providers/incident_provider.dart';

class IncidentsScreen extends ConsumerStatefulWidget {
  const IncidentsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends ConsumerState<IncidentsScreen> {
  String _filterStatus = 'ALL';
  String _filterSeverity = 'ALL';

  @override
  Widget build(BuildContext context) {
    final incidents = ref.watch(incidentsProvider);

    final filteredIncidents = incidents.where((incident) {
      final statusMatch = _filterStatus == 'ALL' || incident.status == _filterStatus;
      final severityMatch = _filterSeverity == 'ALL' || incident.severity == _filterSeverity;
      return statusMatch && severityMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              ref.read(incidentsProvider.notifier).refreshIncidents();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status Filter
                DropdownButton<String>(
                  value: _filterStatus,
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('All Status')),
                    DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                    DropdownMenuItem(value: 'ACKNOWLEDGED', child: Text('Acknowledged')),
                    DropdownMenuItem(value: 'RESOLVED', child: Text('Resolved')),
                  ],
                  onChanged: (value) {
                    setState(() => _filterStatus = value ?? 'ALL');
                  },
                ),
                const SizedBox(width: 16),

                // Severity Filter
                DropdownButton<String>(
                  value: _filterSeverity,
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('All Severity')),
                    DropdownMenuItem(value: 'LOW', child: Text('Low')),
                    DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                    DropdownMenuItem(value: 'HIGH', child: Text('High')),
                    DropdownMenuItem(value: 'CRITICAL', child: Text('Critical')),
                  ],
                  onChanged: (value) {
                    setState(() => _filterSeverity = value ?? 'ALL');
                  },
                ),
              ],
            ),
          ),

          // Statistics
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(
                  'Total',
                  incidents.length.toString(),
                  Colors.blue,
                ),
                _buildStat(
                  'Pending',
                  incidents.where((i) => i.status == 'PENDING').length.toString(),
                  Colors.orange,
                ),
                _buildStat(
                  'Critical',
                  incidents.where((i) => i.severity == 'CRITICAL').length.toString(),
                  Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Incidents List
          Expanded(
            child: filteredIncidents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Incidents',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No incidents match your filters',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredIncidents.length,
                    itemBuilder: (context, index) {
                      final incident = filteredIncidents[index];
                      return _buildIncidentTile(context, incident, ref);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _buildIncidentTile(
    BuildContext context,
    Incident incident,
    WidgetRef ref,
  ) {
    final severityColor = _getSeverityColor(incident.severity);
    final statusColor = _getStatusColor(incident.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showIncidentDetails(context, incident, ref);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      color: severityColor,
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
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
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
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      incident.status,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                incident.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (incident.status != 'RESOLVED')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (incident.status == 'PENDING')
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text('Acknowledge'),
                          onPressed: () {
                            ref
                                .read(incidentsProvider.notifier)
                                .acknowledgeIncident(incident.id);
                          },
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.done_all_outlined, size: 16),
                        label: const Text('Resolve'),
                        onPressed: () {
                          ref
                              .read(incidentsProvider.notifier)
                              .resolveIncident(incident.id);
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIncidentDetails(
    BuildContext context,
    Incident incident,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Incident Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            _detailRow('Title:', incident.title),
            _detailRow('Category:', incident.category),
            _detailRow('Severity:', incident.severity),
            _detailRow('Status:', incident.status),
            _detailRow('Time:', incident.formattedTime),
            _detailRow('Location:', '${incident.latitude}, ${incident.longitude}'),
            const SizedBox(height: 16),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(incident.description),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
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
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MEDIUM':
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'ACKNOWLEDGED':
        return Colors.blue;
      case 'RESOLVED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
