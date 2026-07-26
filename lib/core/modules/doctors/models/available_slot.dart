class AvailabilitySlot {
  const AvailabilitySlot({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.slotId,
  });

  final String date;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final int? slotId;

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json, String date) =>
      AvailabilitySlot(
        date: date,
        startTime: json['start_time'] as String? ?? '',
        endTime: json['end_time'] as String? ?? '',
        isAvailable: json['available'] as bool? ?? false,
        slotId: json['id'] as int?,
      );
}
