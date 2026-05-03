import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/models/models.dart';

class PhoneService {
  static final PhoneService _instance = PhoneService._internal();
  final logger = Logger();

  PhoneService._internal();

  factory PhoneService() {
    return _instance;
  }

  /// Make a phone call to the given number
  Future<bool> makeCall(String phoneNumber) async {
    try {
      // Remove any non-digit characters except + for international prefix
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      if (cleanNumber.isEmpty) {
        logger.w('Invalid phone number: $phoneNumber');
        return false;
      }

      final uri = Uri(scheme: 'tel', path: cleanNumber);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        logger.i('📞 Call initiated to: $cleanNumber');
        return true;
      } else {
        logger.w('Could not launch phone call to: $cleanNumber');
        return false;
      }
    } catch (e) {
      logger.e('Error making phone call: $e');
      return false;
    }
  }

  /// Send SMS to the given number
  Future<bool> sendSMS(String phoneNumber, String message) async {
    try {
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      if (cleanNumber.isEmpty) {
        logger.w('Invalid phone number: $phoneNumber');
        return false;
      }

      final uri = Uri(
        scheme: 'sms',
        path: cleanNumber,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        logger.i('📱 SMS sent to: $cleanNumber');
        return true;
      } else {
        logger.w('Could not send SMS to: $cleanNumber');
        return false;
      }
    } catch (e) {
      logger.e('Error sending SMS: $e');
      return false;
    }
  }

  /// Get emergency contacts sorted by priority
  List<EmergencyContact> getContactsByPriority(List<EmergencyContact> contacts) {
    final priorityOrder = {
      'CRITICAL': 0,
      'HIGH': 1,
      'MEDIUM': 2,
      'LOW': 3,
    };

    final sorted = List<EmergencyContact>.from(contacts);
    sorted.sort((a, b) {
      return (priorityOrder[a.priority] ?? 99)
          .compareTo(priorityOrder[b.priority] ?? 99);
    });

    return sorted;
  }

  /// Get contacts matching the given severity level
  List<EmergencyContact> getContactsForSeverity(
    List<EmergencyContact> contacts,
    String severity,
  ) {
    // Map SOS severity to contact priority thresholds
    final severityToPriority = {
      'CRITICAL': ['CRITICAL', 'HIGH'],
      'HIGH': ['CRITICAL', 'HIGH', 'MEDIUM'],
      'MEDIUM': ['HIGH', 'MEDIUM', 'LOW'],
      'LOW': ['MEDIUM', 'LOW'],
    };

    final priorityThreshold = severityToPriority[severity] ?? ['CRITICAL'];
    final filtered = contacts
        .where((contact) => priorityThreshold.contains(contact.priority))
        .toList();

    return getContactsByPriority(filtered);
  }

  /// Call all matching emergency contacts for a given severity
  Future<List<bool>> callEmergencyContacts(
    List<EmergencyContact> contacts,
    String severity,
    String sosMessage,
  ) async {
    final matchingContacts = getContactsForSeverity(contacts, severity);

    if (matchingContacts.isEmpty) {
      logger.w('No emergency contacts found for severity: $severity');
      return [];
    }

    final results = <bool>[];

    for (final contact in matchingContacts) {
      logger.i(
        '🚨 Calling ${contact.name} (${contact.priority}) - ${contact.phoneNumber}',
      );
      try {
        final success = await makeCall(contact.phoneNumber);
        results.add(success);

        // Send SMS with SOS message
        if (success) {
          await Future.delayed(const Duration(milliseconds: 500));
          await sendSMS(contact.phoneNumber, sosMessage);
        }
      } catch (e) {
        logger.e('Error calling ${contact.name}: $e');
        results.add(false);
      }
    }

    logger.i(
      '📞 Emergency contacts call summary: ${results.where((r) => r).length}/${results.length} successful',
    );
    return results;
  }

  /// Call a single emergency contact
  Future<bool> callSingleContact(EmergencyContact contact) async {
    try {
      logger.i('📞 Calling ${contact.name}: ${contact.phoneNumber}');
      return await makeCall(contact.phoneNumber);
    } catch (e) {
      logger.e('Error calling ${contact.name}: $e');
      return false;
    }
  }
}
