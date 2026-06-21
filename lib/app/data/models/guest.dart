import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';

const guestSideBride = 'Bride Side';
const guestSideGroom = 'Groom Side';
const guestSideBoth = 'Both';
const guestSides = [guestSideBride, guestSideGroom, guestSideBoth];

const guestCategories = [
  'Family',
  'Friends',
  'Office',
  'Neighbours',
  'VIP',
  'Other',
];

class Guest {
  final String id;
  final String name;
  final String phone;
  final String whatsapp;
  final String side;
  final String category;
  final int numberInvited;
  final String address;
  final String notes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Guest({
    this.id = '',
    this.name = '',
    this.phone = '',
    this.whatsapp = '',
    this.side = guestSideBoth,
    this.category = 'Family',
    this.numberInvited = 1,
    this.address = '',
    this.notes = '',
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  factory Guest.fromJson(String id, Map<String, dynamic> json) {
    return Guest(
      id: id,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      whatsapp: json['whatsapp']?.toString() ?? '',
      side: json['side']?.toString() ?? guestSideBoth,
      category: json['category']?.toString() ?? 'Family',
      numberInvited: (numberFromJson(json['numberInvited']) ?? 1).toInt(),
      address: json['address']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: dateFromJson(json['createdAt']),
      updatedAt: dateFromJson(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'whatsapp': whatsapp,
      'side': side,
      'category': category,
      'numberInvited': numberInvited,
      'address': address,
      'notes': notes,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get effectiveWhatsapp => whatsapp.trim().isNotEmpty ? whatsapp : phone;

  Guest copyWith({
    String? id,
    String? name,
    String? phone,
    String? whatsapp,
    String? side,
    String? category,
    int? numberInvited,
    String? address,
    String? notes,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Guest(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      side: side ?? this.side,
      category: category ?? this.category,
      numberInvited: numberInvited ?? this.numberInvited,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

String newGuestId() => newId();
