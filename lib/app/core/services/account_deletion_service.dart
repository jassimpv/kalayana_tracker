import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountDeletionService {
  const AccountDeletionService._();

  static const retentionDays = 90;
  static const scheduledStatus = 'scheduled';
  static const archiveCollection = 'deletedAccounts';

  static Future<DateTime> scheduleDeletion(User user) async {
    final firestore = FirebaseFirestore.instance;
    final requestedAt = DateTime.now();
    final scheduledAt = requestedAt.add(const Duration(days: retentionDays));
    final userRef = firestore.collection('users').doc(user.uid);
    final userSnapshot = await userRef.get();
    final workspaceId = userSnapshot.data()?['workspaceId']?.toString().trim();

    await userRef.set({
      'accountDeletionStatus': scheduledStatus,
      'accountDeletionRequestedAt': Timestamp.fromDate(requestedAt),
      'accountDeletionScheduledAt': Timestamp.fromDate(scheduledAt),
      'accountDeletionArchiveCollection': archiveCollection,
      'accountDeletionWorkspaceId': workspaceId?.isEmpty == true
          ? null
          : workspaceId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return scheduledAt;
  }

  static Future<bool> revokeIfScheduled(User user) async {
    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();
    final isScheduled =
        snapshot.data()?['accountDeletionStatus'] == scheduledStatus;
    if (!isScheduled) return false;

    await userRef.set({
      'accountDeletionStatus': FieldValue.delete(),
      'accountDeletionRequestedAt': FieldValue.delete(),
      'accountDeletionScheduledAt': FieldValue.delete(),
      'accountDeletionArchiveCollection': FieldValue.delete(),
      'accountDeletionWorkspaceId': FieldValue.delete(),
      'accountDeletionRevokedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return true;
  }
}
