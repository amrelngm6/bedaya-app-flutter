import 'package:bedaya2/core/modules/doctors/models/doctor_service.dart';

class DoctorApiModel {
  DoctorApiModel({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.specialty,
    required this.arabicSpecialty,
    required this.categoryId,
    required this.imageUrl,
    required this.rating,
    required this.reviewsCount,
    required this.experienceYears,
    required this.consultationFee,
    this.bio,
    this.bioArabic,
    this.languages,
    this.availableBookingTypes,
    this.isOnlineNow = false,
    this.nextAvailableSlot,
    this.isLikedByMe,
    this.services,
    this.hasOnlineBooking,
  });

  final int id;
  final String name;
  final String arabicName;
  final String specialty;
  final String arabicSpecialty;
  final int categoryId;
  final String imageUrl;
  final double rating;
  final int? reviewsCount;
  final int experienceYears;
  final double consultationFee;
  final String? bio;
  final String? bioArabic;
  final List<String>? languages;
  final List<String>? availableBookingTypes;
  final bool isOnlineNow;
  final String? nextAvailableSlot;
  bool? isLikedByMe;
  List<DoctorService>? services;
  bool? hasOnlineBooking;

  factory DoctorApiModel.fromJson(Map<String, dynamic> json) {
    return DoctorApiModel(
      id: json['doctor_id'] as int,
      name: json['name'] as String? ?? '',
      arabicName: json['arabic_name'] as String? ?? '',
      specialty: json['category']['name'] as String,
      arabicSpecialty: json['category']['arabic_name'] as String? ?? '--',
      categoryId: json['category']['category_id'] as int,
      imageUrl: json['picture'] as String? ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 160,
      experienceYears: json['experience_years'] as int? ?? 0,
      consultationFee: (json['consultation_fee'] as num?)?.toDouble() ?? 0.0,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      bio: json['about'] as String?,
      bioArabic: json['about_ar'] as String?,
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      availableBookingTypes: (json['available_booking_types'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      isOnlineNow: json['is_online_now'] as bool? ?? false,
      hasOnlineBooking: json['has_online_booking'] as bool? ?? false,
      nextAvailableSlot: json['next_available_slot'] as String?,
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => DoctorService.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
