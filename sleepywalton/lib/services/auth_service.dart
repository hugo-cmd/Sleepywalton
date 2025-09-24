import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _pinKey = 'user_pin_hash';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _isSetupCompleteKey = 'setup_complete';

  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<void> init() async {
    // Check if biometric authentication is available
    final isAvailable = await _localAuth.canCheckBiometrics;
    if (isAvailable) {
      final biometrics = await _localAuth.getAvailableBiometrics();
      print('Available biometrics: $biometrics');
    }
  }

  static Future<bool> isSetupComplete() async {
    return StorageService.getSetting<bool>(_isSetupCompleteKey) ?? false;
  }

  static Future<void> markSetupComplete() async {
    await StorageService.setSetting(_isSetupCompleteKey, true);
  }

  static Future<bool> isBiometricEnabled() async {
    return StorageService.getSetting<bool>(_biometricEnabledKey) ?? false;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await StorageService.setSetting(_biometricEnabledKey, enabled);
  }

  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) return false;

      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> setPin(String pin) async {
    if (pin.length < 4) return false;

    final hashedPin = _hashPin(pin);
    await StorageService.setSetting(_pinKey, hashedPin);
    return true;
  }

  static Future<bool> verifyPin(String pin) async {
    final storedHash = StorageService.getSetting<String>(_pinKey);
    if (storedHash == null) return false;

    final inputHash = _hashPin(pin);
    return storedHash == inputHash;
  }

  static Future<bool> authenticateWithBiometric() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) return false;

      final result = await _localAuth.authenticate(
        localizedReason: 'Use biometric authentication to dismiss alarm',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return result;
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }

  static Future<bool> authenticateWithPin(String pin) async {
    return await verifyPin(pin);
  }

  static Future<bool> authenticate({
    String? pin,
    bool useBiometric = true,
  }) async {
    // Try biometric first if enabled and available
    if (useBiometric) {
      final biometricEnabled = await isBiometricEnabled();
      final biometricAvailable = await isBiometricAvailable();
      
      if (biometricEnabled && biometricAvailable) {
        final biometricResult = await authenticateWithBiometric();
        if (biometricResult) return true;
      }
    }

    // Fall back to PIN if provided
    if (pin != null) {
      return await authenticateWithPin(pin);
    }

    return false;
  }

  static Future<bool> changePin(String oldPin, String newPin) async {
    // Verify old PIN first
    final isOldPinCorrect = await verifyPin(oldPin);
    if (!isOldPinCorrect) return false;

    // Set new PIN
    return await setPin(newPin);
  }

  static Future<void> resetAuth() async {
    await StorageService.removeSetting(_pinKey);
    await StorageService.setSetting(_biometricEnabledKey, false);
    await StorageService.setSetting(_isSetupCompleteKey, false);
  }

  static String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<bool> hasPin() async {
    final storedHash = StorageService.getSetting<String>(_pinKey);
    return storedHash != null;
  }

  static Future<Map<String, dynamic>> getAuthStatus() async {
    final hasPinSet = await hasPin();
    final biometricEnabled = await isBiometricEnabled();
    final biometricAvailable = await isBiometricAvailable();
    final availableBiometrics = await getAvailableBiometrics();

    return {
      'hasPin': hasPinSet,
      'biometricEnabled': biometricEnabled,
      'biometricAvailable': biometricAvailable,
      'availableBiometrics': availableBiometrics.map((b) => b.toString()).toList(),
    };
  }
}
