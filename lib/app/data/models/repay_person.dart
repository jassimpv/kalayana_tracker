import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';

class RepayPerson {
  const RepayPerson({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RepayPerson.fromJson(String id, Map<String, dynamic> json) {
    final createdAt =
        dateFromJson(json['createdAt']) ?? dateFromJson(json['createdDate']);
    final updatedAt =
        dateFromJson(json['updatedAt']) ?? dateFromJson(json['updatedDate']);
    final fallbackDate = createdAt ?? updatedAt ?? DateTime.now();
    return RepayPerson(
      id: id,
      name: json['name']?.toString().trim() ?? '',
      createdAt: createdAt ?? fallbackDate,
      updatedAt: updatedAt ?? fallbackDate,
    );
  }

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name.trim(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  RepayPerson copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RepayPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
