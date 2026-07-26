class MeetingModel {
  int id;
  int? doctorId;
  String? doctorName;
  String? doctorImageUrl;
  DateTime? selectedDate;
  String? selectedTime;
  String? notes;
  String? meetingID;

  MeetingModel({
    required this.id,
    this.doctorId,
    this.doctorName,
    this.doctorImageUrl,
    this.selectedDate,
    this.selectedTime,
    this.notes,
    this.meetingID,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'start_date': selectedDate?.toIso8601String().split('T').first,
      'start_time': selectedTime,
      'notes': notes,
      'meeting_id': meetingID,
    };
  }

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    print('MeetingModel.fromJson: $json');
    return MeetingModel(
      id: json['id'] as int,
      doctorId: json['doctor']['id'] as int?,
      doctorName: json['doctor']['name'] as String?,
      doctorImageUrl: json['doctor']['image_url'] as String?,
      selectedDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      selectedTime: json['start_time'] as String?,
      notes: json['notes'] as String?,
      meetingID: json['video_meeting'] != null
          ? json['video_meeting']['meeting_id'] as String?
          : null,
    );
  }
}
