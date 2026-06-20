import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kalayanaexpresstracker/app/data/models/repay_person.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_data.dart';

abstract class WeddingRepository {
  Stream<WeddingData> watch();
  Future<void> save(WeddingData data);
  Future<void> seedIfEmpty();
  Stream<List<RepayPerson>> getRepayPersons();
  Future<void> addRepayPerson(RepayPerson person);
  Future<void> updateRepayPerson(RepayPerson person);
  Future<void> deleteRepayPerson(String personId);
}

class FirestoreWeddingRepository implements WeddingRepository {
  FirestoreWeddingRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> get _legacyDoc {
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

  DocumentReference<Map<String, dynamic>> _doc(String workspaceId) {
    return _firestore
        .collection('weddingWorkspaces')
        .doc(workspaceId)
        .collection('dashboard')
        .doc('main');
  }

  DocumentReference<Map<String, dynamic>> _workspaceDoc(String workspaceId) {
    return _firestore.collection('weddingWorkspaces').doc(workspaceId);
  }

  CollectionReference<Map<String, dynamic>> _repayPersonsCollection(
    String workspaceId,
  ) {
    return _workspaceDoc(workspaceId).collection('repayPersons');
  }

  Future<String> _workspaceId() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Wedding data is only available after signing in.');
    }
    final userRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();
    final existing = snapshot.data()?['workspaceId']?.toString().trim();
    if (existing != null && existing.isNotEmpty) {
      final existingWorkspace = await _workspaceDoc(existing).get();
      if (existingWorkspace.exists) return existing;
      // Points at a workspace doc that no longer exists (e.g. the user left
      // or was removed from a shared workspace before ever creating their
      // own). Fall through and recreate their personal workspace below.
    }

    final workspaceId = (existing != null && existing.isNotEmpty)
        ? existing
        : user.uid;
    await _workspaceDoc(workspaceId).set({
      'ownerId': user.uid,
      'joinCode': _joinCodeFor(user.uid),
      'members': {user.uid: _memberData(user, 'Admin')},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await userRef.set({
      'workspaceId': workspaceId,
      'collaboratorRole': 'Admin',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return workspaceId;
  }

  @override
  Stream<WeddingData> watch() {
    return Stream.fromFuture(_workspaceId())
        .asyncExpand((workspaceId) {
          return _doc(workspaceId).snapshots();
        })
        .map((snapshot) {
          final data = snapshot.data();
          return data == null
              ? WeddingData.empty()
              : WeddingData.fromJson(data);
        });
  }

  @override
  Future<void> save(WeddingData data) async {
    final workspaceId = await _workspaceId();
    await _doc(
      workspaceId,
    ).set({...data.toJson(), 'updatedAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<void> seedIfEmpty() async {
    final workspaceId = await _workspaceId();
    final snapshot = await _doc(workspaceId).get();
    if (!snapshot.exists) {
      final legacySnapshot = await _legacyDoc.get();
      final legacyData = legacySnapshot.data();
      await save(
        legacyData == null
            ? WeddingData.withDefaultExpenses()
            : WeddingData.fromJson(legacyData),
      );
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

  @override
  Stream<List<RepayPerson>> getRepayPersons() {
    return Stream.fromFuture(_workspaceId())
        .asyncExpand((workspaceId) {
          return _repayPersonsCollection(
            workspaceId,
          ).orderBy('name').snapshots();
        })
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RepayPerson.fromJson(doc.id, doc.data()))
              .where((person) => person.name.trim().isNotEmpty)
              .toList();
        });
  }

  @override
  Future<void> addRepayPerson(RepayPerson person) async {
    final workspaceId = await _workspaceId();
    await _repayPersonsCollection(
      workspaceId,
    ).doc(person.id).set(person.toJson());
  }

  @override
  Future<void> updateRepayPerson(RepayPerson person) async {
    final workspaceId = await _workspaceId();
    await _repayPersonsCollection(
      workspaceId,
    ).doc(person.id).set(person.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteRepayPerson(String personId) async {
    final workspaceId = await _workspaceId();
    await _repayPersonsCollection(workspaceId).doc(personId).delete();
  }
}

String _joinCodeFor(String uid) {
  final source = uid.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
  final padded = '$source${'7X9Q2Z8L'}'.padRight(8, 'K');
  return 'KALY-${padded.substring(0, 4)}-${padded.substring(4, 8)}';
}

Map<String, dynamic> _memberData(User user, String role) {
  return {
    'uid': user.uid,
    'name': user.displayName ?? user.email?.split('@').first ?? 'Member',
    'email': user.email,
    'photoUrl': user.photoURL,
    'role': role,
    'joinedAt': FieldValue.serverTimestamp(),
  };
}
