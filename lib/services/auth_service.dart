import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../data/models/models.dart';
import 'database_service.dart';
import 'incident_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final logger = Logger();
  final DatabaseService _dbService = DatabaseService();

  User? _currentUser;
  late SharedPreferences _preferences;

  AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      logger.i('AuthService initialized');
    } catch (e) {
      logger.e('Error initializing AuthService: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      // Trim whitespace and log received credentials
      final trimmedUsername = username.trim();
      final trimmedPassword = password.trim();
      
      logger.i('Login attempt - Username: "$trimmedUsername", Password length: ${trimmedPassword.length}');
      logger.i('Expected - Username: "${AppConstants.dummyUsername}", Password: "${AppConstants.dummyPassword}"');
      
      // Dummy authentication - replace with real API call later
      if (trimmedUsername == AppConstants.dummyUsername &&
          trimmedPassword == AppConstants.dummyPassword) {
        
        logger.i('Credentials match! Creating user...');
        
        // Create or get dummy user with emergency contacts
        _currentUser = User(
          id: 'user_001',
          username: trimmedUsername,
          email: 'user@safetypro.com',
          phoneNumber: '+1234567890',
          profileImage: '',
          emergencyContacts: [
            EmergencyContact(
              id: const Uuid().v4(),
              phoneNumber: '+919876543210',
              name: 'Mom (Critical)',
              priority: 'CRITICAL',
            ),
            EmergencyContact(
              id: const Uuid().v4(),
              phoneNumber: '+911122334455',
              name: 'Dad (High)',
              priority: 'HIGH',
            ),
            EmergencyContact(
              id: const Uuid().v4(),
              phoneNumber: '+919988776655',
              name: 'Sister (Medium)',
              priority: 'MEDIUM',
            ),
          ],
          isActive: true,
          lastLogin: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Save user to database (skip on web and ignore errors)
        try {
          if (!kIsWeb) {
            final existingUser = await _dbService.getUser(_currentUser!.id);
            if (existingUser == null) {
              await _dbService.insertUser(_currentUser!);
              logger.i('User saved to database');
            } else {
              await _dbService.updateUser(_currentUser!);
              logger.i('User updated in database');
            }
          }
        } catch (dbError) {
          logger.w('Database operation failed (continuing anyway): $dbError');
          // Continue even if database fails
        }

        // Store auth token in preferences
        try {
          await _preferences.setString(
            'auth_token',
            'dummy_token_${DateTime.now().millisecondsSinceEpoch}',
          );
          await _preferences.setString(
            'user_id',
            _currentUser!.id,
          );
          logger.i('Auth token saved to preferences');
        } catch (prefError) {
          logger.w('SharedPreferences failed: $prefError');
          // Continue even if preferences fail
        }

        logger.i('✅ User logged in successfully: ${_currentUser!.username}');
        
        // Create dummy incidents for testing if none exist
        try {
          final incidentService = IncidentService();
          await incidentService.createDummyIncidents(_currentUser!.id);
        } catch (e) {
          logger.w('Failed to create dummy incidents: $e');
          // Continue even if this fails
        }
        
        return true;
      } else {
        logger.w('❌ Invalid login credentials - Username mismatch or password mismatch');
        logger.w('Username match: ${trimmedUsername == AppConstants.dummyUsername}');
        logger.w('Password match: ${trimmedPassword == AppConstants.dummyPassword}');
        return false;
      }
    } catch (e) {
      logger.e('❌ Unexpected error during login: $e');
      return false;
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      final token = _preferences.getString('auth_token');
      final userId = _preferences.getString('user_id');

      if (token != null && userId != null) {
        // Try to get user from database (skip on web)
        if (!kIsWeb) {
          try {
            final user = await _dbService.getUser(userId);
            if (user != null) {
              _currentUser = user;
              logger.i('Auto-login successful for user: ${user.username}');
              return true;
            }
          } catch (e) {
            logger.w('Database auto-login skipped: $e');
          }
        } else {
          // On web, recreate the dummy user
          _currentUser = User(
            id: userId,
            username: 'admin',
            email: 'user@safetypro.com',
            phoneNumber: '+1234567890',
            profileImage: '',
            emergencyContacts: [
              EmergencyContact(
                id: const Uuid().v4(),
                phoneNumber: '+919876543210',
                name: 'Mom',
                priority: 'CRITICAL',
              ),
              EmergencyContact(
                id: const Uuid().v4(),
                phoneNumber: '+911122334455',
                name: 'Dad',
                priority: 'HIGH',
              ),
              EmergencyContact(
                id: const Uuid().v4(),
                phoneNumber: '+919988776655',
                name: 'Sister',
                priority: 'MEDIUM',
              ),
            ],
            isActive: true,
            lastLogin: DateTime.now(),
            createdAt: DateTime.now(),
          );
          logger.i('Auto-login successful for web user: admin');
          return true;
        }
      }

      logger.i('No valid auth token found');
      return false;
    } catch (e) {
      logger.e('Error during auto-login: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _currentUser = null;
      await _preferences.remove('auth_token');
      await _preferences.remove('user_id');
      logger.i('User logged out');
    } catch (e) {
      logger.e('Error during logout: $e');
    }
  }

  Future<bool> updateUserProfile(User user) async {
    try {
      _currentUser = user;
      await _dbService.updateUser(user);
      logger.i('User profile updated');
      return true;
    } catch (e) {
      logger.e('Error updating user profile: $e');
      return false;
    }
  }

  Future<bool> addEmergencyContact(String phoneNumber, String name, String priority) async {
    try {
      if (_currentUser == null) return false;

      final emergencyContacts = List<EmergencyContact>.from(_currentUser!.emergencyContacts);
      
      if (emergencyContacts.length >= AppConstants.maxEmergencyContacts) {
        logger.w('Maximum emergency contacts reached');
        return false;
      }

      // Check if contact with same number already exists
      if (emergencyContacts.any((c) => c.phoneNumber == phoneNumber)) {
        logger.w('Contact already exists');
        return false;
      }

      final newContact = EmergencyContact(
        id: const Uuid().v4(),
        phoneNumber: phoneNumber,
        name: name.isEmpty ? phoneNumber : name,
        priority: priority,
      );

      emergencyContacts.add(newContact);
      
      final updatedUser = _currentUser!.copyWith(
        emergencyContacts: emergencyContacts,
      );
      
      await updateUserProfile(updatedUser);
      logger.i('Emergency contact added: $name ($priority) - $phoneNumber');
      return true;
    } catch (e) {
      logger.e('Error adding emergency contact: $e');
      return false;
    }
  }

  Future<bool> removeEmergencyContact(String contactId) async {
    try {
      if (_currentUser == null) return false;

      final emergencyContacts = List<EmergencyContact>.from(_currentUser!.emergencyContacts);
      emergencyContacts.removeWhere((c) => c.id == contactId);

      final updatedUser = _currentUser!.copyWith(
        emergencyContacts: emergencyContacts,
      );

      await updateUserProfile(updatedUser);
      logger.i('Emergency contact removed with ID: $contactId');
      return true;
    } catch (e) {
      logger.e('Error removing emergency contact: $e');
      return false;
    }
  }

  String? getAuthToken() {
    return _preferences.getString('auth_token');
  }

  Future<void> dispose() async {
    // Cleanup if needed
  }
}
