import 'dart:async';
import 'package:nfc_manager/nfc_manager.dart' as nfc_manager;
import '../models/models.dart';
import 'storage_service.dart';

class NfcService {
  static final NfcService _instance = NfcService._internal();
  factory NfcService() => _instance;
  NfcService._internal();

  static bool _isInitialized = false;
  static StreamController<NfcTag>? _tagStreamController;
  static StreamController<String>? _nfcIdStreamController;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Check if NFC is available
      final isAvailable = await nfc_manager.NfcManager.instance.isAvailable();
      if (!isAvailable) {
        throw Exception('NFC is not available on this device');
      }

      _tagStreamController = StreamController<NfcTag>.broadcast();
      _nfcIdStreamController = StreamController<String>.broadcast();

      _isInitialized = true;
    } catch (e) {
      print('NFC initialization failed: $e');
      // Don't rethrow - allow app to continue without NFC
    }
  }

  static Stream<NfcTag> get tagStream => _tagStreamController?.stream ?? const Stream.empty();
  static Stream<String> get nfcIdStream => _nfcIdStreamController?.stream ?? const Stream.empty();

  static Future<void> startTagSession({
    required Function(String nfcId) onTagDetected,
    required Function(String error) onError,
  }) async {
    if (!_isInitialized) {
      throw Exception('NFC Service not initialized');
    }

    try {
      await nfc_manager.NfcManager.instance.startSession(
        onDiscovered: (nfc_manager.NfcTag tag) async {
          final nfcId = _extractNfcId(tag);
          if (nfcId != null) {
            onTagDetected(nfcId);
            _nfcIdStreamController?.add(nfcId);
          }
        },
        pollingOptions: {
          nfc_manager.NfcPollingOption.iso14443,
          nfc_manager.NfcPollingOption.iso15693,
          nfc_manager.NfcPollingOption.iso18092,
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  static Future<void> stopTagSession() async {
    await nfc_manager.NfcManager.instance.stopSession();
  }

  static String? _extractNfcId(nfc_manager.NfcTag tag) {
    try {
      // Try different tag types to extract ID
      if (tag.data.containsKey('nfca')) {
        final nfca = tag.data['nfca'] as Map<String, dynamic>;
        return nfca['identifier']?.toString();
      }
      if (tag.data.containsKey('nfcb')) {
        final nfcb = tag.data['nfcb'] as Map<String, dynamic>;
        return nfcb['identifier']?.toString();
      }
      if (tag.data.containsKey('nfcf')) {
        final nfcf = tag.data['nfcf'] as Map<String, dynamic>;
        return nfcf['identifier']?.toString();
      }
      if (tag.data.containsKey('nfcv')) {
        final nfcv = tag.data['nfcv'] as Map<String, dynamic>;
        return nfcv['identifier']?.toString();
      }
    } catch (e) {
      print('Error extracting NFC ID: $e');
    }
    return null;
  }

  static Future<NfcTag?> registerNfcTag({
    required String nickname,
    required NfcTagType type,
    required Function(String nfcId) onTagDetected,
    required Function(String error) onError,
  }) async {
    String? detectedNfcId;
    bool tagDetected = false;

    // Start session to detect tag
    await startTagSession(
      onTagDetected: (nfcId) {
        detectedNfcId = nfcId;
        tagDetected = true;
      },
      onError: onError,
    );

    // Wait for tag detection (with timeout)
    final completer = Completer<NfcTag?>();
    Timer(const Duration(seconds: 30), () {
      if (!tagDetected) {
        completer.complete(null);
      }
    });

    // Check if tag is already registered
    if (detectedNfcId != null) {
      final existingTag = StorageService.getNfcTagByNfcId(detectedNfcId!);
      if (existingTag != null) {
        await stopTagSession();
        throw Exception('This NFC tag is already registered');
      }

      // Create new NFC tag
      final now = DateTime.now();
      final newTag = NfcTag(
        id: '${now.millisecondsSinceEpoch}',
        nickname: nickname,
        nfcId: detectedNfcId!,
        type: type,
        createdAt: now,
        lastUsed: now,
      );

      await StorageService.saveNfcTag(newTag);
      await stopTagSession();
      
      _tagStreamController?.add(newTag);
      return newTag;
    }

    await stopTagSession();
    return null;
  }

  static Future<bool> verifyNfcTag(String nfcId) async {
    final tag = StorageService.getNfcTagByNfcId(nfcId);
    if (tag != null) {
      tag.markAsUsed();
      return true;
    }
    return false;
  }

  static Future<void> deleteNfcTag(String tagId) async {
    await StorageService.deleteNfcTag(tagId);
  }

  static List<NfcTag> getAllRegisteredTags() {
    return StorageService.getAllNfcTags();
  }

  static List<NfcTag> getTagsByType(NfcTagType type) {
    return StorageService.getNfcTagsByType(type);
  }

  static Future<void> updateNfcTag(String tagId, {
    String? nickname,
    NfcTagType? type,
  }) async {
    final tag = StorageService.getNfcTag(tagId);
    if (tag != null) {
      final updatedTag = tag.copyWith(
        nickname: nickname,
        type: type,
      );
      await StorageService.saveNfcTag(updatedTag);
    }
  }

  static void dispose() {
    _tagStreamController?.close();
    _nfcIdStreamController?.close();
    _isInitialized = false;
  }
}
