import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../services/phone_service.dart';

class SOSScreen extends ConsumerStatefulWidget {
  const SOSScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends ConsumerState<SOSScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String _selectedSeverity = 'HIGH';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _sendSOS() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || currentUser.emergencyContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add emergency contacts first')),
      );
      return;
    }

    // Show confirmation dialog with severity info
    _showSOSConfirmationDialog(currentUser);
  }

  void _showSOSConfirmationDialog(User user) {
    final phoneService = PhoneService();
    final matchingContacts = phoneService.getContactsForSeverity(
      user.emergencyContacts,
      _selectedSeverity,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm SOS Alert'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.errorColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_outlined,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Severity: $_selectedSeverity',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Will call ${matchingContacts.length} contact(s)',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Emergency Contacts to Call:',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...matchingContacts.map((contact) {
                final priorityColor = {
                  'CRITICAL': Color(0xFFDC2626),
                  'HIGH': Color(0xFFEA580C),
                  'MEDIUM': Color(0xFFEAB308),
                  'LOW': Color(0xFF16A34A),
                }[contact.priority] ?? Colors.grey;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: priorityColor, width: 2),
                        ),
                        child: Icon(
                          Icons.phone_outlined,
                          color: priorityColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              contact.phoneNumber,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          contact.priority,
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              Text(
                'Incident Details:',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _titleController.text,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                _descriptionController.text,
                style: Theme.of(context).textTheme.labelSmall,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _executeSOS(user, matchingContacts);
            },
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeSOS(
    User user,
    List<EmergencyContact> matchingContacts,
  ) async {
    setState(() => _isSending = true);

    try {
      final phoneService = PhoneService();

      // Create SOS message
      final sosMessage =
          '🚨 EMERGENCY SOS: ${_titleController.text}\n${ _descriptionController.text}\n\nPlease respond immediately!';

      // Create incident record
      final incident = await ref.read(incidentsProvider.notifier).createSOSIncident(
            title: _titleController.text,
            description: _descriptionController.text,
            severity: _selectedSeverity,
          );

      if (incident == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Failed to create incident record')),
          );
        }
      }

      // Call emergency contacts
      await phoneService.callEmergencyContacts(
        matchingContacts,
        _selectedSeverity,
        sosMessage,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ SOS Activated'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your emergency contacts are being called...'),
                const SizedBox(height: 16),
                Text(
                  '${matchingContacts.length} contact(s) will be called:',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...matchingContacts.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('${c.name} - ${c.phoneNumber}'),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _titleController.clear();
                  _descriptionController.clear();
                  _selectedSeverity = 'HIGH';
                  setState(() => _isSending = false);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.errorColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: AppTheme.errorColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Use SOS for immediate emergencies only',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Incident Title',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Personal Safety Threat',
                    prefixIcon: const Icon(Icons.edit_outlined),
                  ),
                  enabled: !_isSending,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Provide details about the emergency...',
                    prefixIcon: const Icon(Icons.description_outlined),
                  ),
                  minLines: 4,
                  maxLines: 6,
                  enabled: !_isSending,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Severity
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Severity Level',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'CRITICAL',
                        label: Text('🔴 Critical'),
                      ),
                      ButtonSegment(
                        value: 'HIGH',
                        label: Text('🟠 High'),
                      ),
                      ButtonSegment(
                        value: 'MEDIUM',
                        label: Text('🟡 Medium'),
                      ),
                    ],
                    selected: <String>{_selectedSeverity},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() => _selectedSeverity = newSelection.first);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedSeverity == 'CRITICAL'
                              ? 'Will call all CRITICAL priority contacts first'
                              : _selectedSeverity == 'HIGH'
                                  ? 'Will call CRITICAL and HIGH priority contacts'
                                  : 'Will call CRITICAL, HIGH, and MEDIUM contacts',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Emergency Contacts Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📞 Emergency Contacts',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your emergency contacts will be called based on severity level. Messages will be sent with your location and incident details.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Send Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isSending ? null : _sendSOS,
              child: _isSending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emergency_share_outlined),
                        const SizedBox(width: 8),
                        Text(
                          'SEND SOS ALERT',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
