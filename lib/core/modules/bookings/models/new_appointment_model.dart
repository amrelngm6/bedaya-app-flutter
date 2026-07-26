class NewAppointmentModel {
  int? doctorId;
  String? doctorName;
  String? doctorSpecialty;
  String? doctorImageUrl;
  BookingType? bookingType;
  DateTime? selectedDate;
  String? selectedTime;
  int? serviceId;
  String? serviceName;
  double? cost;
  String? notes;

  NewAppointmentModel({
    this.doctorId,
    this.doctorName,
    this.doctorSpecialty,
    this.doctorImageUrl,
    this.bookingType,
    this.selectedDate,
    this.selectedTime,
    this.serviceId,
    this.serviceName,
    this.cost,
    this.notes,
  });

  bool get isDoctorSelected => doctorId != null;
  bool get isBookingTypeSelected => bookingType != null;
  bool get isScheduleSelected => selectedDate != null && selectedTime != null;
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  bool get isComplete =>
      isDoctorSelected && isBookingTypeSelected && isScheduleSelected;

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'doctor_specialty': doctorSpecialty,
      'booking_type': bookingType == BookingType.online
          ? 'online'
          : 'in_person',
      'appointment_date': selectedDate?.toIso8601String().split('T').first,
      'appointment_time': selectedTime,
      'service_id': serviceId,
      'service_name': serviceName,
      'cost': cost,
      'notes': notes,
    };
  }
}

enum BookingType { inPerson, online }

class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final String imageUrl;
  final double rating;
  final int experienceYears;
  final double consultationFee;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.rating,
    required this.experienceYears,
    required this.consultationFee,
  });
}

class TimeSlot {
  final String time;
  final bool isAvailable;

  TimeSlot({required this.time, this.isAvailable = true});
}
