import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InvoiceAiSettings {
  const InvoiceAiSettings({
    required this.apiKey,
    this.model = defaultModel,
    this.enabled = true,
  });
  static const defaultModel = 'glm-5.3-flash';
  final String apiKey;
  final String model;
  final bool enabled;
  bool get isConfigured => apiKey.trim().isNotEmpty;
}

/// One app-wide configuration, managed through the Firebase console/Admin SDK.
/// Client access is read-only; the key is excluded from workspace backups.
class InvoiceAiSettingsRepository {
  InvoiceAiSettingsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const collectionPath = 'appConfig';
  static const documentId = 'invoiceAi';

  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in to scan invoices.');
    return user.uid;
  }

  void _checkUser(String uid) {
    if (_auth.currentUser?.uid != uid) {
      throw StateError('Your account changed. Please try scanning again.');
    }
  }

  Future<InvoiceAiSettings> load({String? expectedUserId}) async {
    final uid = expectedUserId ?? currentUserId;
    _checkUser(uid);
    final snapshot = await _firestore
        .collection(collectionPath)
        .doc(documentId)
        .get(const GetOptions(source: Source.server));
    _checkUser(uid);
    final json = snapshot.data();
    final model = (json?['model'] as String?)?.trim();
    final apiKey = (json?['apiKey'] as String? ?? '').trim();
    if ((apiKey.isNotEmpty &&
            (apiKey.length > 2048 || RegExp(r'\s').hasMatch(apiKey))) ||
        (model != null &&
            model.isNotEmpty &&
            !RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._-]{0,79}$').hasMatch(model))) {
      throw const FormatException('Invoice scanning configuration is invalid.');
    }
    return InvoiceAiSettings(
      apiKey: apiKey,
      model: model == null || model.isEmpty
          ? InvoiceAiSettings.defaultModel
          : model,
      enabled: json?['enabled'] as bool? ?? true,
    );
  }
}
