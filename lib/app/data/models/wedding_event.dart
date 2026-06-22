import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';

const weddingEventTypes = [
  'Engagement',
  'Mehndi',
  'Haldi',
  'Nikah',
  'Wedding',
  'Reception',
  'Custom',
];

class WeddingEvent {
  final String id;
  final String name;
  final String type;
  final DateTime? date;
  final String venue;
  final String mapUrl;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeddingEvent({
    this.id = '',
    this.name = '',
    this.type = 'Custom',
    this.date,
    this.venue = '',
    this.mapUrl = '',
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  factory WeddingEvent.fromJson(String id, Map<String, dynamic> json) {
    return WeddingEvent(
      id: id,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Custom',
      date: dateFromJson(json['date']),
      venue: json['venue']?.toString() ?? '',
      mapUrl: json['mapUrl']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      createdAt: dateFromJson(json['createdAt']),
      updatedAt: dateFromJson(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'date': date?.toIso8601String(),
      'venue': venue,
      'mapUrl': mapUrl,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WeddingEvent copyWith({
    String? id,
    String? name,
    String? type,
    DateTime? date,
    bool clearDate = false,
    String? venue,
    String? mapUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeddingEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      date: clearDate ? null : date ?? this.date,
      venue: venue ?? this.venue,
      mapUrl: mapUrl ?? this.mapUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

String newEventId() => newId();
