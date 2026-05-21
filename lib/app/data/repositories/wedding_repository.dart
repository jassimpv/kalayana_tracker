import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_data.dart';

abstract class WeddingRepository {
  Stream<WeddingData> watch();
  Future<void> save(WeddingData data);
  Future<void> seedIfEmpty();
}

class FirestoreWeddingRepository implements WeddingRepository {
  FirestoreWeddingRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> get _doc {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Wedding data is only available after signing in.');
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('weddings')
        .doc('dashboard');
  }

  @override
  Stream<WeddingData> watch() {
    return _doc.snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? WeddingData.empty() : WeddingData.fromJson(data);
    });
  }

  @override
  Future<void> save(WeddingData data) async {
    await _doc.set({
      ...data.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> seedIfEmpty() async {
    final snapshot = await _doc.get();
    if (!snapshot.exists) {
      await save(WeddingData.withDefaultExpenses());
      return;
    }
    final data = WeddingData.fromJson(snapshot.data() ?? {});
    if (data.expenses.isEmpty || data.reminders.isEmpty) {
      await save(
        data.copyWith(
          expenses: data.expenses.isEmpty ? [] : data.expenses,
          reminders: data.reminders.isEmpty ? [] : data.reminders,
        ),
      );
    }
  }
}
