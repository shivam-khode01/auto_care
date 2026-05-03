import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alarm_provider.dart';

class AlarmsScreen extends ConsumerStatefulWidget {
  const AlarmsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends ConsumerState<AlarmsScreen> {
  @override
  void initState() {
    super.initState();
    // Listen to alarm events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alarmServiceProvider).alarmTriggeredStream.listen((alarm) {
        if (mounted) {
          _showAlarmTriggeredDialog(alarm);
        }
      });
    });
  }

  void _showAlarmTriggeredDialog(SafetyAlarm alarm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Alarm Triggered! 🔔'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${alarm.title}'),
            const SizedBox(height: 8),
            Text('Description: ${alarm.description}'),
            const SizedBox(height: 8),
            Text('Time: ${alarm.formattedTime}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(alarmServiceProvider).snoozeAlarm(alarm, 5);
            },
            child: const Text('Snooze 5min'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(alarmServiceProvider).dismissAlarm(alarm);
            },
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alarms = ref.watch(alarmsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Alarms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              ref.read(alarmsProvider.notifier).refreshAlarms();
            },
          ),
        ],
      ),
      body: alarms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.alarm_off_outlined,
                    size: 64,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Alarms',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new alarm to get started',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return _buildAlarmCard(context, alarm, ref);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateAlarmDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAlarmCard(
    BuildContext context,
    SafetyAlarm alarm,
    WidgetRef ref,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alarm.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alarm.formattedTime,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: alarm.isActive,
                  onChanged: (value) {
                    ref
                        .read(alarmsProvider.notifier)
                        .updateAlarm(alarm.copyWith(isActive: value));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (alarm.recurrence != 'NONE')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Repeats: ${alarm.recurrence}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                  onPressed: () {
                    // TODO: Implement edit
                  },
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  onPressed: () {
                    ref.read(alarmsProvider.notifier).deleteAlarm(alarm.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAlarmDialog(BuildContext context, WidgetRef ref) {
    late final TextEditingController titleController;
    late final TextEditingController descriptionController;
    late TimeOfDay selectedTime;
    String selectedRecurrence = 'NONE';

    titleController = TextEditingController();
    descriptionController = TextEditingController();
    selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Alarm'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  minLines: 2,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Text(
                  'Time: ${selectedTime.format(context)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                  child: const Text('Pick Time'),
                ),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  value: selectedRecurrence,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'NONE', child: Text('No Repeat')),
                    DropdownMenuItem(value: 'DAILY', child: Text('Daily')),
                    DropdownMenuItem(value: 'WEEKLY', child: Text('Weekly')),
                    DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedRecurrence = value ?? 'NONE');
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final now = DateTime.now();
                final scheduledTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                final alarm = SafetyAlarm(
                  id: const Uuid().v4(),
                  userId: ref.read(currentUserProvider)!.id,
                  title: titleController.text,
                  description: descriptionController.text,
                  alarmType: 'SCHEDULED',
                  scheduledTime: scheduledTime,
                  recurrence: selectedRecurrence,
                  createdAt: DateTime.now(),
                );

                ref.read(alarmsProvider.notifier).addAlarm(alarm);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alarm created successfully')),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
