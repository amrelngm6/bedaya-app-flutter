import 'package:flutter/material.dart';

class MedicalProfileCategory {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final String? icon;
  final String? color;
  final int? sortOrder;
  final bool isActive;

  const MedicalProfileCategory({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.icon,
    this.color,
    this.sortOrder,
    this.isActive = true,
  });

  Color get colorValue => _parseHexColor(color);

  factory MedicalProfileCategory.fromJson(Map<String, dynamic> json) =>
      MedicalProfileCategory(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String?,
        description: json['description'] as String?,
        icon: json['icon'] as String?,
        color: json['color'] as String?,
        sortOrder: json['sort_order'] as int?,
        isActive: json['is_active'] as bool? ?? true,
      );
}

class MedicalProfileFile {
  final int id;
  final int? conditionId;
  final int? categoryId;
  final String? title;
  final String? notes;
  final String? fileName;
  final int? fileSize;
  final String? fileType;
  final String? mimeType;
  final String? fileUrl;
  final MedicalProfileCategory? category;

  const MedicalProfileFile({
    required this.id,
    this.conditionId,
    this.categoryId,
    this.title,
    this.notes,
    this.fileName,
    this.fileSize,
    this.fileType,
    this.mimeType,
    this.fileUrl,
    this.category,
  });

  bool get isImage {
    final type = (fileType ?? mimeType ?? '').toLowerCase();
    return type.contains('image') ||
        (fileName ?? '').toLowerCase().endsWith('.jpg') ||
        (fileName ?? '').toLowerCase().endsWith('.jpeg') ||
        (fileName ?? '').toLowerCase().endsWith('.png');
  }

  bool get isPdf {
    final type = (fileType ?? mimeType ?? '').toLowerCase();
    return type.contains('pdf') ||
        (fileName ?? '').toLowerCase().endsWith('.pdf');
  }

  String get displaySize {
    final size = fileSize;
    if (size == null || size <= 0) return '';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory MedicalProfileFile.fromJson(Map<String, dynamic> json) =>
      MedicalProfileFile(
        id: json['id'] as int,
        conditionId: json['condition_id'] as int?,
        categoryId: json['category_id'] as int?,
        title: json['title'] as String?,
        notes: json['notes'] as String?,
        fileName: json['file_name'] as String?,
        fileSize: json['file_size'] as int?,
        fileType: json['file_type'] as String?,
        mimeType: json['mime_type'] as String?,
        fileUrl: json['file_url'] as String?,
        category: json['category'] is Map<String, dynamic>
            ? MedicalProfileCategory.fromJson(
                json['category'] as Map<String, dynamic>,
              )
            : null,
      );
}

class MedicalProfileCondition {
  final int id;
  final int? categoryId;
  final String title;
  final String? description;
  final String? conditionDate;
  final String? notes;

  /// 'active' | 'resolved' | 'chronic' | 'monitoring'
  final String? status;
  final String? statusLabel;
  final String? statusColor;
  final MedicalProfileCategory? category;
  final List<MedicalProfileFile> files;
  final String? createdAt;

  const MedicalProfileCondition({
    required this.id,
    this.categoryId,
    required this.title,
    this.description,
    this.conditionDate,
    this.notes,
    this.status,
    this.statusLabel,
    this.statusColor,
    this.category,
    this.files = const [],
    this.createdAt,
  });

  Color get statusColorValue => _parseHexColor(statusColor);

  factory MedicalProfileCondition.fromJson(Map<String, dynamic> json) =>
      MedicalProfileCondition(
        id: json['id'] as int,
        categoryId: json['category_id'] as int?,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        conditionDate: json['condition_date'] as String?,
        notes: json['notes'] as String?,
        status: json['status'] as String?,
        statusLabel: json['status_label'] as String?,
        statusColor: json['status_color'] as String?,
        category: json['category'] is Map<String, dynamic>
            ? MedicalProfileCategory.fromJson(
                json['category'] as Map<String, dynamic>,
              )
            : null,
        files:
            (json['files'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map(MedicalProfileFile.fromJson)
                .toList() ??
            const [],
        createdAt: json['created_at'] as String?,
      );
}

Color _parseHexColor(String? hex) {
  const fallback = Color(0xFF2491A1);
  if (hex == null || hex.isEmpty) return fallback;
  var value = hex.replaceAll('#', '');
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16);
  return parsed != null ? Color(parsed) : fallback;
}
