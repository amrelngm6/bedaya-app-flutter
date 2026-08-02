/// Represents a single fertility reference test returned by
/// `GET /mobile/medical-reports/tests`.
///
/// Fields match the backend `FertilityTestResource`:
/// id, test_name, field_key, category, category_label, unit, input_type,
/// is_required, placeholder, normal_min, normal_max, normal_range_text,
/// critical_low, critical_high, description.
class FertilityTest {
  final int id;
  final String testName;

  /// Machine-readable key used as the JSON key in submitted parameters.
  /// Falls back to [testName] when null.
  final String? fieldKey;

  /// The analysis-type API key this test belongs to (e.g. "hormone").
  final String category;
  final String? categoryLabel;
  final String unit;

  /// How the mobile form should render the input: 'number' | 'text' | 'select'
  final String inputType;

  /// Whether the field must be filled before submitting the report.
  final bool isRequired;

  /// Optional hint displayed inside the input field.
  final String? placeholder;

  final double? normalMin;
  final double? normalMax;

  /// Human-readable range string, e.g. "2.0 - 10.0 mIU/mL".
  final String? normalRangeText;

  final double? criticalLow;
  final double? criticalHigh;

  final String? description;

  const FertilityTest({
    required this.id,
    required this.testName,
    this.fieldKey,
    required this.category,
    this.categoryLabel,
    required this.unit,
    this.inputType = 'number',
    this.isRequired = false,
    this.placeholder,
    this.normalMin,
    this.normalMax,
    this.normalRangeText,
    this.criticalLow,
    this.criticalHigh,
    this.description,
  });

  factory FertilityTest.fromJson(Map<String, dynamic> json) {
    return FertilityTest(
      id: (json['id'] as num?)?.toInt() ?? 0,
      testName: json['test_name'] as String? ?? '',
      fieldKey: json['field_key'] as String?,
      category: json['category'] as String? ?? '',
      categoryLabel: json['category_label'] as String?,
      unit: json['unit'] as String? ?? '',
      inputType: json['input_type'] as String? ?? 'number',
      isRequired: json['is_required'] as bool? ?? false,
      placeholder: json['placeholder'] as String?,
      normalMin: (json['normal_min'] as num?)?.toDouble(),
      normalMax: (json['normal_max'] as num?)?.toDouble(),
      normalRangeText: json['normal_range_text'] as String?,
      criticalLow: (json['critical_low'] as num?)?.toDouble(),
      criticalHigh: (json['critical_high'] as num?)?.toDouble(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'test_name': testName,
      if (fieldKey != null) 'field_key': fieldKey,
      'category': category,
      if (categoryLabel != null) 'category_label': categoryLabel,
      'unit': unit,
      'input_type': inputType,
      'is_required': isRequired,
      if (placeholder != null) 'placeholder': placeholder,
      if (normalMin != null) 'normal_min': normalMin,
      if (normalMax != null) 'normal_max': normalMax,
      if (normalRangeText != null) 'normal_range_text': normalRangeText,
      // if (criticalLow != null) 'critical_low': criticalLow,
      // if (criticalHigh != null) 'critical_high': criticalHigh,
      if (description != null) 'description': description,
    };
  }

  /// The key used as the parameter JSON key when submitting.
  String get submissionKey => fieldKey ?? testName;

  /// Human-readable normal range string.
  String get normalRange {
    if (normalRangeText != null && normalRangeText!.isNotEmpty) {
      return normalRangeText!;
    }
    if (normalMin != null && normalMax != null) {
      return '$normalMin - $normalMax';
    }
    if (normalMin != null) return '>= $normalMin';
    if (normalMax != null) return '<= $normalMax';
    return 'N/A';
  }

  /// Whether this test has any range thresholds defined.
  bool get hasRange =>
      normalMin != null ||
      normalMax != null ||
      criticalLow != null ||
      criticalHigh != null;

  /// Returns a status key for the given [value] - mirrors the backend logic.
  String getStatus(double value) {
    if (criticalLow != null && value < criticalLow!) return 'critically_low';
    if (criticalHigh != null && value > criticalHigh!) return 'critically_high';
    if (normalMin != null && value < normalMin!) return 'low';
    if (normalMax != null && value > normalMax!) return 'high';
    if (normalMin != null || normalMax != null) return 'normal';
    return 'unknown';
  }

  /// Returns a colour key ('red' | 'orange' | 'green' | 'grey') for [value].
  String getStatusColor(double value) {
    switch (getStatus(value)) {
      case 'critically_low':
      case 'critically_high':
        return 'red';
      case 'low':
      case 'high':
        return 'orange';
      case 'normal':
        return 'green';
      default:
        return 'grey';
    }
  }
}

/// A grouping of [FertilityTest]s returned inside the tests endpoint response.
class FertilityTestCategory {
  final String category; // analysis-type API key, e.g. "hormone"
  final String categoryLabel;
  final List<FertilityTest> tests;

  const FertilityTestCategory({
    required this.category,
    required this.categoryLabel,
    required this.tests,
  });

  factory FertilityTestCategory.fromJson(Map<String, dynamic> json) {
    final rawTests = json['tests'] as List<dynamic>? ?? [];
    return FertilityTestCategory(
      category: json['category'] as String? ?? '',
      categoryLabel: json['category_label'] as String? ?? '',
      tests: rawTests
          .whereType<Map<String, dynamic>>()
          .map(FertilityTest.fromJson)
          .toList(),
    );
  }
}
