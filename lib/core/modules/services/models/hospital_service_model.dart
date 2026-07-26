import 'dart:ui';

import 'package:bedaya2/core/config/app_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart' show BuildContext;

class HospitalServiceApiModel {
  const HospitalServiceApiModel({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.subtitle,
    required this.description,
    required this.descriptionText,
    required this.arabicDescription,
    required this.arabicDescriptionText,
    required this.category,
    required this.coverImageUrl,
    this.iconUrl,
    this.successRate,
    this.priceFrom,
    this.priceTo,
    this.currency,
    this.durationDays,
    this.features = const [],
    this.benefits = const [],
    this.faqs = const [],
    this.videos = const [],
    this.successStories = const [],
    this.isHighlighted = false,
  });

  final int id;
  final String title;
  final String arabicTitle;
  final String subtitle;
  final String description;
  final String descriptionText;
  final String arabicDescription;
  final String arabicDescriptionText;
  final String category;
  final String coverImageUrl;
  final String? iconUrl;
  final double? successRate;
  final double? priceFrom;
  final double? priceTo;
  final String? currency;
  final int? durationDays;
  final List<String> features;
  final List<String> benefits;
  final List<Map<String, String>> faqs; // [{question, answer}]
  final List<ServiceVideoApiModel> videos;
  final List<SuccessStoryApiModel> successStories;
  final bool isHighlighted;

  factory HospitalServiceApiModel.fromJson(Map<String, dynamic> json) {
    // Check if image starts with http to avoid adding base URL again
    if (json['hero_image_url'] != null &&
        json['hero_image_url'] is String &&
        !(json['hero_image_url'] as String).startsWith('http')) {
      json['hero_image_url'] = '${AppConfig.baseUrl}${json['hero_image_url']}';
    }

    return HospitalServiceApiModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      arabicTitle: json['arabic_title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionText: json['description_text'] as String? ?? '',
      arabicDescription: json['arabic_description'] as String? ?? '',
      arabicDescriptionText: json['arabic_description_text'] as String? ?? '',
      category: json['group']['name'] as String? ?? '',
      coverImageUrl: json['hero_image_url'] as String? ?? '',
      iconUrl: json['icon_url'] as String?,
      successRate: (json['success_rate'] as num?)?.toDouble(),
      priceFrom: (json['cost'] as num?)?.toDouble(),
      priceTo: (json['cost'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'EGP',
      durationDays: int.tryParse(json['duration']?.toString() ?? ''),
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      benefits:
          (json['benefits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      faqs:
          (json['faqs'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(
                (e) => {
                  'question': e['question']?.toString() ?? '',
                  'answer': e['answer']?.toString() ?? '',
                },
              )
              .toList() ??
          [],
      videos:
          (json['videos'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ServiceVideoApiModel.fromJson)
              .toList() ??
          [],
      // successStories:
      //     (json['success_stories'] as List<dynamic>?)
      //         ?.whereType<Map<String, dynamic>>()
      //         .map(SuccessStoryApiModel.fromJson)
      //         .toList() ??
      //     [],
      isHighlighted: json['is_highlighted'] as bool? ?? false,
    );
  }

  String titleLocalized(BuildContext context) =>
      context.locale == const Locale('ar') ? arabicTitle : title;

  String descriptionLocalized(BuildContext context) =>
      context.locale == const Locale('ar') ? arabicDescription : description;

  String shortDescription(BuildContext context, {int maxLength = 100}) {
    final descriptionText = context.locale == const Locale('ar')
        ? arabicDescriptionText
        : this.descriptionText;

    return descriptionText.substring(
          0,
          descriptionText.length > maxLength
              ? maxLength
              : descriptionText.length,
        ) +
        (descriptionText.length > maxLength ? '...' : '');
  }
}

class ServiceVideoApiModel {
  const ServiceVideoApiModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    this.thumbnailUrl,
    this.durationSeconds,
  });

  final int id;
  final String title;
  final String videoUrl;
  final String? thumbnailUrl;
  final int? durationSeconds;

  factory ServiceVideoApiModel.fromJson(Map<String, dynamic> json) =>
      ServiceVideoApiModel(
        id: json['id'] ?? 1,
        title: json['title'] as String? ?? '',
        videoUrl: json['video_url'] as String? ?? '',
        thumbnailUrl: json['thumbnail_url'] as String?,
        durationSeconds: json['duration'] as int?,
      );
}

class SuccessStoryApiModel {
  const SuccessStoryApiModel({
    required this.id,
    required this.patientName,
    required this.story,
    required this.rating,
    this.patientImageUrl,
    this.serviceUsed,
    this.year,
  });

  final int id;
  final String patientName;
  final String story;
  final double rating;
  final String? patientImageUrl;
  final String? serviceUsed;
  final int? year;

  factory SuccessStoryApiModel.fromJson(Map<String, dynamic> json) =>
      SuccessStoryApiModel(
        id: json['id'] as int,
        patientName: json['patient_name'] as String? ?? '',
        story: json['story'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
        patientImageUrl: json['patient_image_url'] as String?,
        serviceUsed: json['service_used'] as String?,
        year: json['year'] as int?,
      );
}
