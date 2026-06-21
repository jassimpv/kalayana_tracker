import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';

const rsvpStatusPending = 'Pending';
const rsvpStatusConfirmed = 'Confirmed';
const rsvpStatusDeclined = 'Declined';
const rsvpStatusMaybe = 'Maybe';
const rsvpStatuses = [
  rsvpStatusPending,
  rsvpStatusConfirmed,
  rsvpStatusDeclined,
  rsvpStatusMaybe,
];

class RsvpResponse {
  final String guestId;
  final String eventId;
  final String status;
  final int attendeeCount;
  final String specialRequirements;
  final String message;
  final DateTime? responseDate;
  final DateTime? lastReminderSentAt;

  RsvpResponse({
    required this.guestId,
    required this.eventId,
    this.status = rsvpStatusPending,
    this.attendeeCount = 0,
    this.specialRequirements = '',
    this.message = '',
    this.responseDate,
    this.lastReminderSentAt,
  });

  static String docId(String guestId, String eventId) => '${guestId}_$eventId';

  factory RsvpResponse.fromJson(Map<String, dynamic> json) {
    return RsvpResponse(
      guestId: json['guestId']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? '',
      status: json['status']?.toString() ?? rsvpStatusPending,
      attendeeCount: (numberFromJson(json['attendeeCount']) ?? 0).toInt(),
      specialRequirements: json['specialRequirements']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      responseDate: dateFromJson(json['responseDate']),
      lastReminderSentAt: dateFromJson(json['lastReminderSentAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guestId': guestId,
      'eventId': eventId,
      'status': status,
      'attendeeCount': attendeeCount,
      'specialRequirements': specialRequirements,
      'message': message,
      'responseDate': responseDate?.toIso8601String(),
      'lastReminderSentAt': lastReminderSentAt?.toIso8601String(),
    };
  }

  bool get hasResponded => status != rsvpStatusPending;

  RsvpResponse copyWith({
    String? status,
    int? attendeeCount,
    String? specialRequirements,
    String? message,
    DateTime? responseDate,
    DateTime? lastReminderSentAt,
  }) {
    return RsvpResponse(
      guestId: guestId,
      eventId: eventId,
      status: status ?? this.status,
      attendeeCount: attendeeCount ?? this.attendeeCount,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      message: message ?? this.message,
      responseDate: responseDate ?? this.responseDate,
      lastReminderSentAt: lastReminderSentAt ?? this.lastReminderSentAt,
    );
  }
}
