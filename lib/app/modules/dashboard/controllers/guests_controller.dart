import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/data/models/guest.dart';
import 'package:kalayanaexpresstracker/app/data/models/rsvp_response.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_event.dart';
import 'package:kalayanaexpresstracker/app/data/repositories/guest_repository.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class EventAttendance {
  EventAttendance({
    required this.event,
    this.confirmed = 0,
    this.declined = 0,
    this.maybe = 0,
    this.pending = 0,
    this.expectedAttendees = 0,
  });

  final WeddingEvent event;
  final int confirmed;
  final int declined;
  final int maybe;
  final int pending;
  final int expectedAttendees;

  int get totalGuests => confirmed + declined + maybe + pending;
}

class GuestsController extends GetxController {
  GuestsController(this._repository);

  final GuestRepository _repository;

  final guests = <Guest>[].obs;
  final events = <WeddingEvent>[].obs;
  final responses = <RsvpResponse>[].obs;
  final loading = true.obs;
  final error = RxnString();

  final tabIndex = 0.obs;
  final searchQuery = ''.obs;
  final statusFilter = RxnString();
  final categoryFilter = RxnString();
  final sideFilter = RxnString();
  final selectedEventId = RxnString();

  StreamSubscription<List<Guest>>? _guestsSub;
  StreamSubscription<List<WeddingEvent>>? _eventsSub;
  StreamSubscription<List<RsvpResponse>>? _responsesSub;
  StreamSubscription<String?>? _workspaceSub;
  String? _workspaceId;

  @override
  void onInit() {
    super.onInit();
    final dashboard = Get.find<DashboardController>();
    _workspaceSub = dashboard.workspaceId.listen(_bindWorkspace);
    _bindWorkspace(dashboard.workspaceId.value);
  }

  void _bindWorkspace(String? workspaceId) {
    if (workspaceId == null || workspaceId == _workspaceId) return;
    _workspaceId = workspaceId;
    loading.value = true;
    _guestsSub?.cancel();
    _eventsSub?.cancel();
    _responsesSub?.cancel();
    _guestsSub = _repository.watchGuests(workspaceId).listen((value) {
      guests.assignAll(value);
      loading.value = false;
    }, onError: (e) => error.value = e.toString());
    _eventsSub = _repository.watchEvents(workspaceId).listen((value) {
      events.assignAll(value);
      if (selectedEventId.value == null && value.isNotEmpty) {
        selectedEventId.value = value.first.id;
      }
    }, onError: (e) => error.value = e.toString());
    _responsesSub = _repository.watchResponses(workspaceId).listen((value) {
      responses.assignAll(value);
    }, onError: (e) => error.value = e.toString());
  }

  @override
  void onClose() {
    _guestsSub?.cancel();
    _eventsSub?.cancel();
    _responsesSub?.cancel();
    _workspaceSub?.cancel();
    super.onClose();
  }

  String get _requireWorkspaceId {
    final id = _workspaceId;
    if (id == null) {
      throw StateError('Workspace is not ready yet.');
    }
    return id;
  }

  // ---- Guest CRUD ----

  Future<void> addGuest(Guest guest) =>
      _repository.addGuest(_requireWorkspaceId, guest);

  Future<void> updateGuest(Guest guest) =>
      _repository.updateGuest(_requireWorkspaceId, guest);

  Future<void> deleteGuest(String guestId) =>
      _repository.deleteGuest(_requireWorkspaceId, guestId);

  // ---- Event CRUD ----

  Future<void> addEvent(WeddingEvent event) =>
      _repository.addEvent(_requireWorkspaceId, event);

  Future<void> updateEvent(WeddingEvent event) =>
      _repository.updateEvent(_requireWorkspaceId, event);

  Future<void> deleteEvent(String eventId) =>
      _repository.deleteEvent(_requireWorkspaceId, eventId);

  // ---- RSVP ----

  RsvpResponse? responseFor(String guestId, String eventId) {
    return responses.firstWhereOrNull(
      (response) => response.guestId == guestId && response.eventId == eventId,
    );
  }

  Future<void> setRsvp({
    required String guestId,
    required String eventId,
    required String status,
    int attendeeCount = 0,
    String specialRequirements = '',
    String message = '',
  }) {
    final existing = responseFor(guestId, eventId);
    final response = RsvpResponse(
      guestId: guestId,
      eventId: eventId,
      status: status,
      attendeeCount: attendeeCount,
      specialRequirements: specialRequirements,
      message: message,
      responseDate: DateTime.now(),
      lastReminderSentAt: existing?.lastReminderSentAt,
    );
    return _repository.upsertResponse(_requireWorkspaceId, response);
  }

  Future<void> markReminderSent(String guestId, String eventId) {
    final existing =
        responseFor(guestId, eventId) ??
        RsvpResponse(guestId: guestId, eventId: eventId);
    return _repository.upsertResponse(
      _requireWorkspaceId,
      existing.copyWith(lastReminderSentAt: DateTime.now()),
    );
  }

  // ---- Filtering ----

  List<Guest> get filteredGuests {
    final query = searchQuery.value.trim().toLowerCase();
    return guests.where((guest) {
      if (query.isNotEmpty &&
          !guest.name.toLowerCase().contains(query) &&
          !guest.phone.toLowerCase().contains(query)) {
        return false;
      }
      if (categoryFilter.value != null &&
          guest.category != categoryFilter.value) {
        return false;
      }
      if (sideFilter.value != null && guest.side != sideFilter.value) {
        return false;
      }
      if (statusFilter.value != null) {
        final eventId = selectedEventId.value;
        final status = eventId == null
            ? rsvpStatusPending
            : (responseFor(guest.id, eventId)?.status ?? rsvpStatusPending);
        if (status != statusFilter.value) return false;
      }
      return true;
    }).toList();
  }

  // ---- Analytics ----

  int get totalGuests => guests.length;

  int get totalInvitations =>
      guests.fold(0, (total, guest) => total + guest.numberInvited);

  List<RsvpResponse> get _latestResponses => responses;

  int _countByStatus(String status) =>
      _latestResponses.where((response) => response.status == status).length;

  int get confirmedCount => _countByStatus(rsvpStatusConfirmed);

  int get declinedCount => _countByStatus(rsvpStatusDeclined);

  int get maybeCount => _countByStatus(rsvpStatusMaybe);

  /// Every guest is expected to RSVP to every event, so the total number of
  /// (guest, event) pairs minus the ones that have an explicit response is
  /// how many are still pending.
  int get pendingCount {
    final totalPairs = guests.length * events.length;
    final responded = confirmedCount + declinedCount + maybeCount;
    final pending = totalPairs - responded;
    return pending < 0 ? 0 : pending;
  }

  int get expectedAttendance {
    final confirmedOrMaybe = responses.where(
      (r) => r.status == rsvpStatusConfirmed || r.status == rsvpStatusMaybe,
    );
    var total = 0;
    for (final response in confirmedOrMaybe) {
      total += response.attendeeCount > 0
          ? response.attendeeCount
          : (guests
                    .firstWhereOrNull((g) => g.id == response.guestId)
                    ?.numberInvited ??
                1);
    }
    return total;
  }

  double get confirmationRate {
    final totalPairs = guests.length * events.length;
    if (totalPairs <= 0) return 0;
    return (confirmedCount / totalPairs).clamp(0, 1).toDouble();
  }

  List<EventAttendance> get eventWiseSummary {
    return events.map((event) {
      final eventResponses = responses.where((r) => r.eventId == event.id);
      var confirmed = 0, declined = 0, maybe = 0;
      var expected = 0;
      final respondedGuestIds = <String>{};
      for (final response in eventResponses) {
        respondedGuestIds.add(response.guestId);
        switch (response.status) {
          case rsvpStatusConfirmed:
            confirmed++;
            expected += response.attendeeCount > 0 ? response.attendeeCount : 1;
          case rsvpStatusDeclined:
            declined++;
          case rsvpStatusMaybe:
            maybe++;
            expected += response.attendeeCount > 0 ? response.attendeeCount : 1;
        }
      }
      final pending = guests.length - respondedGuestIds.length;
      return EventAttendance(
        event: event,
        confirmed: confirmed,
        declined: declined,
        maybe: maybe,
        pending: pending < 0 ? 0 : pending,
        expectedAttendees: expected,
      );
    }).toList();
  }

  Map<String, int> get sideSplit {
    final result = <String, int>{};
    for (final guest in guests) {
      result[guest.side] = (result[guest.side] ?? 0) + 1;
    }
    return result;
  }

  Map<String, int> get categorySplit {
    final result = <String, int>{};
    for (final guest in guests) {
      result[guest.category] = (result[guest.category] ?? 0) + 1;
    }
    return result;
  }

  // ---- Reminders ----

  List<Guest> pendingFor(String eventId) {
    return guests.where((guest) {
      final response = responseFor(guest.id, eventId);
      return response == null || response.status == rsvpStatusPending;
    }).toList();
  }

  String buildReminderMessage(Guest guest, WeddingEvent event) {
    final dateText = event.date == null
        ? ''
        : ' on ${event.date!.day}/${event.date!.month}/${event.date!.year}';
    final venueText = event.venue.trim().isEmpty ? '' : ' at ${event.venue}';
    final mapsUrl = event.mapUrl.trim().isEmpty
        ? ''
        : '\n\nVenue on Google Maps: ${event.mapUrl.trim()}';
    return "Hi ${guest.name}, this is a gentle reminder for the ${event.name}$dateText$venueText. "
        "Please let us know if you'll be able to join us. We'd love to have you there!$mapsUrl";
  }

  Future<void> sendWhatsAppReminder(Guest guest, WeddingEvent event) async {
    final number = guest.effectiveWhatsapp.replaceAll(RegExp(r'[^0-9+]'), '');
    final message = buildReminderMessage(guest, event);
    final uri = Uri.parse(
      'https://wa.me/$number?text=${Uri.encodeComponent(message)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    await markReminderSent(guest.id, event.id);
  }

  Future<void> copyReminderMessage(Guest guest, WeddingEvent event) async {
    await Clipboard.setData(
      ClipboardData(text: buildReminderMessage(guest, event)),
    );
  }

  Future<void> sendBulkReminders(
    List<Guest> targets,
    WeddingEvent event,
  ) async {
    for (final guest in targets) {
      if (guest.effectiveWhatsapp.trim().isEmpty) continue;
      await sendWhatsAppReminder(guest, event);
      await Future.delayed(const Duration(milliseconds: 350));
    }
  }
}
