import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kalayanaexpresstracker/app/data/models/guest.dart';
import 'package:kalayanaexpresstracker/app/data/models/rsvp_response.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_event.dart';

/// Guest access is restricted to a single, expiring invitation by Firestore
/// rules. No authentication credentials or workspace join codes are shared.
class GuestRsvpService {
  static const webOrigin = String.fromEnvironment(
    'RSVP_WEB_ORIGIN',
    defaultValue: 'https://expense-tracker-20653.web.app',
  );
  static CollectionReference<Map<String, dynamic>> get invitations =>
      FirebaseFirestore.instance.collection('publicRsvpInvitations');

  static RsvpResponse? response(Map<String, dynamic> json) {
    final timestamp = json['respondedAt'];
    if (timestamp is! Timestamp) return null;
    return RsvpResponse(
      guestId: json['guestId'] as String,
      eventId: json['eventId'] as String,
      status: json['status'] as String,
      attendeeCount: (json['attendeeCount'] as num).toInt(),
      specialRequirements: json['specialRequirements'] as String? ?? '',
      responseDate: timestamp.toDate(),
    );
  }

  static Future<String?> rotate(
    String workspaceId,
    Guest guest,
    WeddingEvent event, {
    bool revoke = false,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final workspace = firestore
        .collection('weddingWorkspaces')
        .doc(workspaceId);
    final pointer = workspace
        .collection('rsvpLinks')
        .doc(RsvpResponse.docId(guest.id, event.id));
    final random = Random.secure();
    final token = base64UrlEncode(
      List.generate(32, (_) => random.nextInt(256)),
    ).replaceAll('=', '');
    await firestore.runTransaction((transaction) async {
      final previous = await transaction.get(pointer);
      final oldToken = previous.data()?['token'] as String?;
      DocumentSnapshot<Map<String, dynamic>>? old;
      if (oldToken != null) {
        old = await transaction.get(invitations.doc(oldToken));
      }
      final responseRef = workspace
          .collection('rsvpResponses')
          .doc(RsvpResponse.docId(guest.id, event.id));
      final currentResponse = await transaction.get(responseRef);
      if (old != null && old.exists) {
        final guestResponse = response(old.data()!);
        final current = RsvpResponse.fromJson(currentResponse.data() ?? {});
        if (guestResponse != null &&
            (current.responseDate == null ||
                guestResponse.responseDate!.isAfter(current.responseDate!))) {
          transaction.set(
            responseRef,
            guestResponse.toJson(),
            SetOptions(merge: true),
          );
        }
        transaction.delete(old.reference);
      }
      if (revoke) {
        transaction.delete(pointer);
      } else {
        transaction.set(invitations.doc(token), {
          'workspaceId': workspaceId,
          'guestId': guest.id,
          'eventId': event.id,
          'guestName': guest.name,
          'eventName': event.name,
          'venue': event.venue,
          'eventDate': event.date?.toIso8601String() ?? '',
          'maxAttendees': guest.numberInvited,
          'expiresAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 30)),
          ),
          'status': rsvpStatusPending,
          'attendeeCount': 0,
          'specialRequirements': '',
        });
        transaction.set(pointer, {'token': token});
      }
    });
    return revoke ? null : '$webOrigin/#/guest-rsvp?token=$token';
  }
}
