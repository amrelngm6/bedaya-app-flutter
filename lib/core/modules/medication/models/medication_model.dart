import 'package:flutter/material.dart';

class MedicationModel {
  final String id;
  final String name;
  final String? description;
  final String? dosage;
  final String? frequency;
  final String? frequencyLabel;
  final List<ReminderTime> reminderTimes;
  final DateTime startDate;
  final DateTime? endDate;
  final int? durationDays;
  final String? notes;
  final bool prescribedByDoctor;
  final String? doctorName;
  final MedicationType type;
  final String? instructions;
  final String? category;
  final String? categoryLabel;
  final String? status;
  final String? statusLabel;
  final String? statusColor;
  final bool isActive;
  final bool isExpired;

  MedicationModel({
    required this.id,
    required this.name,
    this.description,
    this.dosage,
    this.frequency,
    this.frequencyLabel,
    required this.reminderTimes,
    required this.startDate,
    this.endDate,
    this.durationDays,
    this.notes,
    this.prescribedByDoctor = false,
    this.doctorName,
    this.type = MedicationType.tablet,
    this.instructions,
    this.category,
    this.categoryLabel,
    this.status,
    this.statusLabel,
    this.statusColor,
    this.isActive = true,
    this.isExpired = false,
  });

  MedicationModel copyWith({
    String? id,
    String? name,
    String? description,
    String? dosage,
    String? frequency,
    String? frequencyLabel,
    List<ReminderTime>? reminderTimes,
    DateTime? startDate,
    DateTime? endDate,
    int? durationDays,
    String? notes,
    bool? prescribedByDoctor,
    String? doctorName,
    MedicationType? type,
    String? instructions,
    String? category,
    String? categoryLabel,
    String? status,
    String? statusLabel,
    String? statusColor,
    bool? isActive,
    bool? isExpired,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      frequencyLabel: frequencyLabel ?? this.frequencyLabel,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
      notes: notes ?? this.notes,
      prescribedByDoctor: prescribedByDoctor ?? this.prescribedByDoctor,
      doctorName: doctorName ?? this.doctorName,
      type: type ?? this.type,
      instructions: instructions ?? this.instructions,
      category: category ?? this.category,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      statusColor: statusColor ?? this.statusColor,
      isActive: isActive ?? this.isActive,
      isExpired: isExpired ?? this.isExpired,
    );
  }

  /// Serialise to the API format expected by POST/PUT /patient/medications.
  Map<String, dynamic> toApiJson() {
    return {
      'name': name,
      'dosage_form': type.name,
      if (dosage != null && dosage!.isNotEmpty) 'dosage': dosage,
      if (frequency != null && frequency!.isNotEmpty) 'frequency': frequency,
      'times_of_day': reminderTimes
          .map(
            (r) =>
                '${r.time.hour.toString().padLeft(2, '0')}:${r.time.minute.toString().padLeft(2, '0')}',
          )
          .toList(),
      'start_date':
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      if (endDate != null)
        'end_date':
            '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}',
      if (instructions != null && instructions!.isNotEmpty)
        'instructions': instructions,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    // Parse times_of_day from API format ["08:00", "20:00"]
    final List<ReminderTime> reminderTimes;
    final timesOfDay = json['times_of_day'];
    final takenTimes =
        (json['today_taken_logs'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];
    if (timesOfDay is List && timesOfDay.isNotEmpty) {
      reminderTimes = timesOfDay.asMap().entries.map((entry) {
        final parts = entry.value.toString().split(':');
        final isTaken = takenTimes.asMap().entries.any(
          (e) => e.value['scheduled_time'] == entry.value.toString(),
        );

        return ReminderTime(
          id: '${json['id']}_r${entry.key}',
          taken: isTaken,
          time: TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
          ),
        );
      }).toList();
    } else if (json['reminderTimes'] is List) {
      reminderTimes = (json['reminderTimes'] as List)
          .map((x) => ReminderTime.fromJson(x as Map<String, dynamic>))
          .toList();
    } else {
      reminderTimes = [];
    }

    // Derive dosage string from strength + unit when a dedicated dosage field is absent
    String? dosage = json['dosage'] as String?;
    if ((dosage == null || dosage.isEmpty) && json['strength'] != null) {
      final strength = json['strength']?.toString();
      final unit = json['unit']?.toString();
      if (strength != null && unit != null) dosage = '$strength $unit';
    }

    // Map dosage_form → MedicationType
    final dosageForm =
        (json['dosage_form'] as String? ?? json['type'] as String? ?? 'tablet')
            .toLowerCase();
    final type = MedicationType.values.firstWhere(
      (e) => e.name == dosageForm,
      orElse: () => MedicationType.tablet,
    );

    // A medication is considered doctor-prescribed when it references a
    // catalog entry (default_medication_id is not null).
    final prescribedByDoctor =
        json['default_medication_id'] != null ||
        (json['prescribedByDoctor'] as bool? ?? false);

    return MedicationModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      dosage: dosage,
      frequency: json['frequency'] as String?,
      frequencyLabel: json['frequency_label'] as String?,
      reminderTimes: reminderTimes,
      startDate: (json['start_date'] ?? json['startDate']) != null
          ? DateTime.parse((json['start_date'] ?? json['startDate']) as String)
          : DateTime.now(),
      endDate: (json['end_date'] ?? json['endDate']) != null
          ? DateTime.parse((json['end_date'] ?? json['endDate']) as String)
          : null,
      durationDays: json['duration_days'] as int?,
      notes: json['notes'] as String?,
      prescribedByDoctor: prescribedByDoctor,
      doctorName: json['doctorName'] as String?,
      type: type,
      instructions: json['instructions'] as String?,
      category: json['category'] as String?,
      categoryLabel: json['category_label'] as String?,
      status: json['status'] as String?,
      statusLabel: json['status_label'] as String?,
      statusColor: json['status_color'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isExpired: json['is_expired'] as bool? ?? false,
    );
  }
}

class ReminderTime {
  final String id;
  final TimeOfDay time;
  final bool taken;
  final DateTime? takenAt;

  ReminderTime({
    required this.id,
    required this.time,
    this.taken = false,
    this.takenAt,
  });

  ReminderTime copyWith({
    String? id,
    TimeOfDay? time,
    bool? taken,
    DateTime? takenAt,
  }) {
    return ReminderTime(
      id: id ?? this.id,
      time: time ?? this.time,
      taken: taken ?? this.taken,
      takenAt: takenAt ?? this.takenAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': time.hour,
      'minute': time.minute,
      'taken': taken,
      'takenAt': takenAt?.toIso8601String(),
    };
  }

  factory ReminderTime.fromJson(Map<String, dynamic> json) {
    return ReminderTime(
      id: json['id'],
      time: TimeOfDay(hour: json['hour'], minute: json['minute']),
      taken: json['taken'] ?? false,
      takenAt: json['takenAt'] != null ? DateTime.parse(json['takenAt']) : null,
    );
  }
}

enum MedicationType {
  tablet,
  capsule,
  syrup,
  injection,
  drops,
  cream,
  inhaler,
  other,
}

extension MedicationTypeExtension on MedicationType {
  String get displayName {
    switch (this) {
      case MedicationType.tablet:
        return 'Tablet';
      case MedicationType.capsule:
        return 'Capsule';
      case MedicationType.syrup:
        return 'Syrup';
      case MedicationType.injection:
        return 'Injection';
      case MedicationType.drops:
        return 'Drops';
      case MedicationType.cream:
        return 'Cream';
      case MedicationType.inhaler:
        return 'Inhaler';
      case MedicationType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case MedicationType.tablet:
        return '💊';
      case MedicationType.capsule:
        return '💊';
      case MedicationType.syrup:
        return '🧪';
      case MedicationType.injection:
        return '💉';
      case MedicationType.drops:
        return '💧';
      case MedicationType.cream:
        return '🧴';
      case MedicationType.inhaler:
        return '🫁';
      case MedicationType.other:
        return '🏥';
    }
  }
}
