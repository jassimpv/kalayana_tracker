import 'package:kalayanaexpresstracker/app/core/localization/localized_widgets.dart';
import 'package:kalayanaexpresstracker/app/core/services/guest_rsvp_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/data/models/guest.dart';
import 'package:kalayanaexpresstracker/app/data/models/repay_person.dart';
import 'package:kalayanaexpresstracker/app/data/models/rsvp_response.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_data.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_event.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';

/// Portable data backup. Account credentials, members and invitation codes are
/// deliberately excluded; importing never grants access to a workspace.
class WorkspaceBackupPage extends StatefulWidget {
  const WorkspaceBackupPage({super.key});
  @override
  State<WorkspaceBackupPage> createState() => _WorkspaceBackupPageState();
}

class _WorkspaceBackupPageState extends State<WorkspaceBackupPage> {
  final input = TextEditingController();
  final controller = Get.find<DashboardController>();
  bool busy = false;
  static const collections = [
    'guests',
    'guestEvents',
    'rsvpResponses',
    'repayPersons',
  ];

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  DocumentReference<Map<String, dynamic>> _workspace() {
    final id = controller.workspaceId.value;
    if (id == null) throw StateError('Workspace is not ready.');
    return FirebaseFirestore.instance.collection('weddingWorkspaces').doc(id);
  }

  Future<void> _export() async {
    setState(() => busy = true);
    try {
      final ref = _workspace();
      final result = <String, dynamic>{
        'format': 'wedding360-workspace',
        'version': 1,
        'exportedAt': DateTime.now().toUtc().toIso8601String(),
        'currencyCode': controller.profile['currencyCode'] ?? 'INR',
      };
      final snapshot = await ref.collection('dashboard').doc('main').get();
      result['dashboard'] = WeddingData.fromJson(
        snapshot.data() ?? {},
      ).toJson();
      for (final name in collections) {
        final snapshot = await ref.collection(name).get();
        result[name] = [
          for (final doc in snapshot.docs) {'id': doc.id, 'data': doc.data()},
        ];
      }
      final public = await GuestRsvpService.invitations
          .where('workspaceId', isEqualTo: ref.id)
          .get();
      final responses = {
        for (final row in result['rsvpResponses'] as List)
          row['id'] as String: Map<String, dynamic>.from(row['data'] as Map),
      };
      for (final document in public.docs) {
        final response = GuestRsvpService.response(document.data());
        if (response == null) continue;
        final id = RsvpResponse.docId(response.guestId, response.eventId);
        final old = responses[id] == null
            ? null
            : RsvpResponse.fromJson(responses[id]!);
        if (old?.responseDate == null ||
            response.responseDate!.isAfter(old!.responseDate!)) {
          responses[id] = response
              .copyWith(lastReminderSentAt: old?.lastReminderSentAt)
              .toJson();
        }
      }
      result['rsvpResponses'] = [
        for (final entry in responses.entries)
          {'id': entry.key, 'data': entry.value},
      ];
      final workspace = (await ref.get()).data() ?? {};
      result['weddingProfile'] = {
        for (final key in ['groomName', 'brideName', 'marriageDate'])
          key: workspace[key],
      };
      if (controller.workspaceId.value != ref.id) {
        throw StateError('Workspace changed. Please retry.');
      }
      await Clipboard.setData(
        ClipboardData(
          text: jsonEncode(
            result,
            toEncodable: (value) {
              if (value is Timestamp) return value.toDate().toIso8601String();
              throw FormatException(
                'Unsupported backup value: ${value.runtimeType}',
              );
            },
          ),
        ),
      );
      _message('Backup copied. Save it to a private JSON file.');
    } catch (error) {
      _message('Backup failed: $error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _restore() async {
    if (!controller.isWorkspaceAdmin) {
      _message('Only the workspace admin can restore backups.');
      return;
    }
    final text = input.text.trim();
    try {
      if (utf8.encode(text).length > 4000000) {
        throw const FormatException('Backup is too large.');
      }
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic> ||
          decoded['format'] != 'wedding360-workspace' ||
          decoded['version'] != 1) {
        throw const FormatException('Choose a Wedding360 version 1 backup.');
      }
      if (decoded['currencyCode'] !=
          (controller.profile['currencyCode'] ?? 'INR')) {
        throw const FormatException(
          'Choose the backup currency in your profile before restoring. Amounts are not converted automatically.',
        );
      }
      final dashboardJson = decoded['dashboard'];
      if (dashboardJson is! Map<String, dynamic>) {
        throw const FormatException('Dashboard is missing.');
      }
      final imported = WeddingData.fromJson(dashboardJson).toJson();
      final records = <String, List<Map<String, dynamic>>>{};
      for (final name in collections) {
        if (decoded[name] is! List) throw FormatException('$name is missing.');
        records[name] = (decoded[name] as List).map((row) {
          if (row is! Map<String, dynamic> ||
              row['id'] is! String ||
              row['data'] is! Map<String, dynamic>) {
            throw const FormatException('Invalid record.');
          }
          final id = row['id'] as String;
          if (id.isEmpty ||
              id.contains('/') ||
              id == '.' ||
              id == '..' ||
              utf8.encode(id).length > 1500) {
            throw const FormatException('Invalid record ID.');
          }
          final json = row['data'] as Map<String, dynamic>;
          final normalized = switch (name) {
            'guests' => Guest.fromJson(id, json).toJson(),
            'guestEvents' => WeddingEvent.fromJson(id, json).toJson(),
            'rsvpResponses' => RsvpResponse.fromJson(json).toJson(),
            'repayPersons' => RepayPerson.fromJson(id, json).toJson(),
            _ => throw const FormatException('Unknown collection'),
          };
          if (name == 'rsvpResponses') {
            final response = RsvpResponse.fromJson(normalized);
            if (id != RsvpResponse.docId(response.guestId, response.eventId)) {
              throw const FormatException('Invalid RSVP ID.');
            }
          }
          return <String, dynamic>{'id': id, 'data': normalized};
        }).toList();
        if (records[name]!.map((row) => row['id']).toSet().length !=
            records[name]!.length) {
          throw const FormatException('Duplicate record IDs.');
        }
      }
      final count = records.values.fold<int>(
        0,
        (totalCount, rows) => totalCount + rows.length,
      );
      if (count > 450) {
        throw const FormatException(
          'This backup exceeds the 450-record atomic restore limit.',
        );
      }
      final ref = _workspace();
      final confirmed = await _confirmRestore();
      if (!confirmed || !mounted) return;
      if (controller.workspaceId.value != ref.id) {
        throw StateError('Workspace changed.');
      }
      setState(() => busy = true);
      final dashboardRef = ref.collection('dashboard').doc('main');
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw StateError('Sign in again.');
        final profile = await transaction.get(
          FirebaseFirestore.instance.collection('users').doc(user.uid),
        );
        if (profile.data()?['workspaceId'] != ref.id) {
          throw StateError('Workspace changed.');
        }
        final workspace = await transaction.get(ref);
        if (workspace.data()?['ownerId'] !=
            FirebaseAuth.instance.currentUser?.uid) {
          throw StateError(
            'Workspace ownership changed. Reload before restoring.',
          );
        }
        final current = await transaction.get(dashboardRef);
        final merged = WeddingData.fromJson(current.data() ?? {}).toJson();
        for (final key in ['expenses', 'reminders', 'purchases', 'planning']) {
          final existing = {
            for (final row in merged[key] as List) row['id']: row,
          };
          for (final row in imported[key] as List) {
            existing.putIfAbsent(row['id'], () => row);
          }
          merged[key] = existing.values.toList();
        }
        if ((merged['budgetGoal'] as num) == 0) {
          merged['budgetGoal'] = imported['budgetGoal'];
        }
        WeddingData.fromJson(merged).validatePlanning();
        if (utf8.encode(jsonEncode(merged)).length > 850000) {
          throw StateError('Merged dashboard is too large to restore.');
        }
        final missing =
            <(DocumentReference<Map<String, dynamic>>, Map<String, dynamic>)>[];
        for (final name in collections) {
          for (final row in records[name]!) {
            final destination = ref.collection(name).doc(row['id'] as String);
            final snapshot = await transaction.get(destination);
            if (!snapshot.exists) {
              missing.add((destination, row['data'] as Map<String, dynamic>));
            }
          }
        }
        if (controller.workspaceId.value != ref.id ||
            !controller.isWorkspaceAdmin) {
          throw StateError('Workspace changed.');
        }
        transaction.set(dashboardRef, {
          ...merged,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        for (final item in missing) {
          transaction.set(item.$1, item.$2);
        }
        final weddingProfile = decoded['weddingProfile'];
        if (weddingProfile is Map<String, dynamic>) {
          final update = <String, dynamic>{};
          for (final key in ['groomName', 'brideName', 'marriageDate']) {
            if (workspace.data()?[key] == null &&
                weddingProfile[key] is String) {
              update[key] = weddingProfile[key];
            }
          }
          if (update.isNotEmpty) {
            transaction.set(ref, update, SetOptions(merge: true));
          }
        }
      });
      _message('Backup merged. Existing records were preserved.');
    } catch (error) {
      _message('Restore failed: $error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<bool> _confirmRestore() async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const LocalizedText('Merge backup into this workspace?'),
          content: const LocalizedText(
            'Missing records will be added. Existing records with matching IDs are preserved. Account access and invitation codes are unchanged.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const LocalizedText('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const LocalizedText('Merge backup'),
            ),
          ],
        ),
      ) ??
      false;

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: LocalizedText(text)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const LocalizedText('Backup & restore')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const LocalizedText(
          'Export includes planning, gifts, expenses, payment history, guests, events, RSVP responses and repayment people. Document links are included; externally stored files are not copied.',
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: busy ? null : _export,
          icon: const Icon(Icons.copy),
          label: const LocalizedText('Copy workspace backup'),
        ),
        const SizedBox(height: 24),
        const LocalizedText(
          'Restore adds missing records without replacing existing data. Only the workspace admin can restore.',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: input,
          minLines: 5,
          maxLines: 12,
          decoration: const LocalizedInputDecoration(
            labelText: 'Paste backup JSON',
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: busy ? null : _restore,
          icon: const Icon(Icons.restore),
          label: const LocalizedText('Merge backup'),
        ),
        if (busy) const LinearProgressIndicator(),
      ],
    ),
  );
}
