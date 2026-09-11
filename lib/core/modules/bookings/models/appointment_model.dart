import 'package:bedaya2/core/modules/doctors/models/doctor_model.dart';
import 'package:bedaya2/core/modules/meetings/models/meeting_model.dart';

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorImageUrl,
    required this.bookingType,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.cost,
    this.statusId,
    this.meeting,
    this.doctor,
    this.notes,
    this.meetingLink,
    this.clinicAddress,
    this.cancellationReason,
    this.createdAt,
  });

  final int id;
  final int doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorImageUrl;

  /// 'in_person' | 'online'
  final String bookingType;
  final String appointmentDate; // 'YYYY-MM-DD'
  final String appointmentTime; // 'HH:MM'

  /// 'pending' | 'confirmed' | 'completed' | 'cancelled'
  final String status;

  final double cost;
  final int? statusId;
  final String? notes;
  final String? meetingLink;
  final String? clinicAddress;
  final String? cancellationReason;
  final String? createdAt;
  final DoctorApiModel? doctor;
  final MeetingModel? meeting;

  bool get isOnline => bookingType == 'online';
  bool get isConfirmed => status == 'Confirmed';
  bool get isCancelled => status == 'Cancelled';
  bool get isCompleted => status == 'Completed';

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as int,
      doctorId: json['doctor']['id'] as int? ?? 0,
      doctorName: json['doctor']['name'] as String? ?? '',
      doctorSpecialty: json['doctor']['category']['name'] as String? ?? '',
      doctorImageUrl: json['doctor']['picture'] as String? ?? '',
      bookingType: json['booking_type'] as String? ?? 'in_person',
      appointmentDate: json['scheduled_date'] as String? ?? '',
      appointmentTime: json['start_time'] as String? ?? '',
      status: json['status']['name'] as String? ?? 'pending',
      statusId: json['status']['status_id'] as int?,
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      meetingLink: json['meeting_link'] as String?,
      clinicAddress: json['clinic_address'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: json['created_at'] as String?,
      doctor: json['doctor'] != null
          ? DoctorApiModel.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
      meeting: json['meeting'] != null
          ? MeetingModel.fromJson(json['meeting'] as Map<String, dynamic>)
          : null,
    );
  }
}
