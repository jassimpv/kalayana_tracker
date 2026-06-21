import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kalayanaexpresstracker/app/data/models/guest.dart';
import 'package:kalayanaexpresstracker/app/data/models/rsvp_response.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_event.dart';

abstract class GuestRepository {
  Stream<List<Guest>> watchGuests(String workspaceId);
  Future<void> addGuest(String workspaceId, Guest guest);
  Future<void> updateGuest(String workspaceId, Guest guest);
  Future<void> deleteGuest(String workspaceId, String guestId);

  Stream<List<WeddingEvent>> watchEvents(String workspaceId);
  Future<void> addEvent(String workspaceId, WeddingEvent event);
  Future<void> updateEvent(String workspaceId, WeddingEvent event);
  Future<void> deleteEvent(String workspaceId, String eventId);

  Stream<List<RsvpResponse>> watchResponses(String workspaceId);
  Future<void> upsertResponse(String workspaceId, RsvpResponse response);
}

class FirestoreGuestRepository implements GuestRepository {
  FirestoreGuestRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _workspaceDoc(String workspaceId) {
    return _firestore.collection('weddingWorkspaces').doc(workspaceId);
  }

  CollectionReference<Map<String, dynamic>> _guestsCollection(
    String workspaceId,
  ) => _workspaceDoc(workspaceId).collection('guests');

  CollectionReference<Map<String, dynamic>> _eventsCollection(
    String workspaceId,
  ) => _workspaceDoc(workspaceId).collection('guestEvents');

  CollectionReference<Map<String, dynamic>> _responsesCollection(
    String workspaceId,
  ) => _workspaceDoc(workspaceId).collection('rsvpResponses');

  @override
  Stream<List<Guest>> watchGuests(String workspaceId) {
    return _guestsCollection(workspaceId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Guest.fromJson(doc.id, doc.data()))
          .where((guest) => guest.name.trim().isNotEmpty)
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
  }

  @override
  Future<void> addGuest(String workspaceId, Guest guest) async {
    await _guestsCollection(workspaceId).doc(guest.id).set(guest.toJson());
  }

  @override
  Future<void> updateGuest(String workspaceId, Guest guest) async {
    await _guestsCollection(
      workspaceId,
    ).doc(guest.id).set(guest.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteGuest(String workspaceId, String guestId) async {
    await _guestsCollection(workspaceId).doc(guestId).delete();
  }

  @override
  Stream<List<WeddingEvent>> watchEvents(String workspaceId) {
    return _eventsCollection(workspaceId).snapshots().map((snapshot) {
      final events = snapshot.docs
          .map((doc) => WeddingEvent.fromJson(doc.id, doc.data()))
          .where((event) => event.name.trim().isNotEmpty)
          .toList();
      events.sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return a.date!.compareTo(b.date!);
      });
      return events;
    });
  }

  @override
  Future<void> addEvent(String workspaceId, WeddingEvent event) async {
    await _eventsCollection(workspaceId).doc(event.id).set(event.toJson());
  }

  @override
  Future<void> updateEvent(String workspaceId, WeddingEvent event) async {
    await _eventsCollection(
      workspaceId,
    ).doc(event.id).set(event.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteEvent(String workspaceId, String eventId) async {
    await _eventsCollection(workspaceId).doc(eventId).delete();
  }

  @override
  Stream<List<RsvpResponse>> watchResponses(String workspaceId) {
    return _responsesCollection(workspaceId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => RsvpResponse.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> upsertResponse(
    String workspaceId,
    RsvpResponse response,
  ) async {
    await _responsesCollection(workspaceId)
        .doc(RsvpResponse.docId(response.guestId, response.eventId))
        .set(response.toJson(), SetOptions(merge: true));
  }
}
