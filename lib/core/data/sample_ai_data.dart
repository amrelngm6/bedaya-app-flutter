import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bedaya2/core/modules/chat/models/chat_message_model.dart';
import 'package:bedaya2/core/modules/medication/models/medical_report_model.dart';
import 'package:bedaya2/core/modules/ai/models/fertility_test_model.dart';

class SampleAIData {
  static List<FertilityTest>? _fertilityTests;

  // Load fertility tests from JSON
  static Future<void> loadFertilityTests() async {
    if (_fertilityTests != null) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/fertility_reports.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      _fertilityTests = jsonList
          .map((json) => FertilityTest.fromJson(json))
          .toList();
    } catch (e) {
      _fertilityTests = [];
    }
  }

  // Get tests by category
  static List<FertilityTest> getTestsByCategory(String category) {
    return _fertilityTests
            ?.where((test) => test.category == category)
            .toList() ??
        [];
  }

  // Get test by name
  static FertilityTest? getTestByName(String name) {
    return _fertilityTests?.firstWhere(
      (test) => test.testName.toLowerCase() == name.toLowerCase(),
      orElse: () => _fertilityTests!.first,
    );
  }

  // Sample chat responses for common IVF-related questions
  static Map<String, String> getChatResponses() {
    return {
      'ivf': 'chat_ivf_response',
      'cost': 'chat_cost_response',
      'success': 'chat_success_response',
      'preparation': 'chat_preparation_response',
      'timeline': 'chat_timeline_response',
      'medication': 'chat_medication_response',
      'risks': 'chat_risks_response',
      'age': 'chat_age_response',
      'default': 'chat_default_response',
    };
  }

  // Get sample chat messages for initial conversation
  static List<ChatMessage> getSampleChatMessages() {
    return [
      ChatMessage(
        id: '1',
        content: 'chat_greeting',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  // Sample medical report templates for IVF analysis
  static List<Map<String, dynamic>> getAnalysisTypeTemplates() {
    return [
      {
        'type': AnalysisType.hormone,
        'name': 'analysis_hormone_name',
        'icon': '🧪',
        'description': 'analysis_hormone_desc',
        'category': 'Hormone',
        'parameters': getTestsByCategory('Hormone'),
      },
      {
        'type': AnalysisType.ovarianReserve,
        'name': 'analysis_ovarian_name',
        'icon': '🥚',
        'description': 'analysis_ovarian_desc',
        'category': 'Ovarian Reserve',
        'parameters': getTestsByCategory('Ovarian Reserve'),
      },
      {
        'type': AnalysisType.thyroid,
        'name': 'analysis_thyroid_name',
        'icon': '⚡',
        'description': 'analysis_thyroid_desc',
        'category': 'Thyroid',
        'parameters': getTestsByCategory('Thyroid'),
      },
      {
        'type': AnalysisType.semen,
        'name': 'analysis_semen_name',
        'icon': '🔬',
        'description': 'analysis_semen_desc',
        'category': 'Semen',
        'parameters': getTestsByCategory('Semen'),
      },
      {
        'type': AnalysisType.ultrasound,
        'name': 'analysis_ultrasound_name',
        'icon': '📊',
        'description': 'analysis_ultrasound_desc',
        'category': 'Ultrasound',
        'parameters': getTestsByCategory('Ultrasound'),
      },
      {
        'type': AnalysisType.metabolic,
        'name': 'analysis_metabolic_name',
        'icon': '🩺',
        'description': 'analysis_metabolic_desc',
        'category': 'Metabolic',
        'parameters': getTestsByCategory('Metabolic'),
      },
      {
        'type': AnalysisType.blood,
        'name': 'analysis_blood_name',
        'icon': '💉',
        'description': 'analysis_blood_desc',
        'category': 'Blood',
        'parameters': getTestsByCategory('Blood'),
      },
      {
        'type': AnalysisType.infection,
        'name': 'analysis_infection_name',
        'icon': '🦠',
        'description': 'analysis_infection_desc',
        'category': 'Infection',
        'parameters': getTestsByCategory('Infection'),
      },
      {
        'type': AnalysisType.immunology,
        'name': 'analysis_immunology_name',
        'icon': '🛡️',
        'description': 'analysis_immunology_desc',
        'category': 'Immunology',
        'parameters': getTestsByCategory('Immunology'),
      },
      {
        'type': AnalysisType.embryology,
        'name': 'analysis_embryology_name',
        'icon': '👶',
        'description': 'analysis_embryology_desc',
        'category': 'Embryology',
        'parameters': getTestsByCategory('Embryology'),
      },
      {
        'type': AnalysisType.pregnancy,
        'name': 'analysis_pregnancy_name',
        'icon': '🤰',
        'description': 'analysis_pregnancy_desc',
        'category': 'Pregnancy',
        'parameters': getTestsByCategory('Pregnancy'),
      },
      {
        'type': AnalysisType.genetic,
        'name': 'analysis_genetic_name',
        'icon': '🧬',
        'description': 'analysis_genetic_desc',
        'category': 'Genetic',
        'parameters': getTestsByCategory('Genetic'),
      },
      {
        'type': AnalysisType.vitamin,
        'name': 'analysis_vitamin_name',
        'icon': '💊',
        'description': 'analysis_vitamin_desc',
        'category': 'Vitamin',
        'parameters': getTestsByCategory('Vitamin'),
      },
      {
        'type': AnalysisType.androgen,
        'name': 'analysis_androgen_name',
        'icon': '💪',
        'description': 'analysis_androgen_desc',
        'category': 'Androgen',
        'parameters': getTestsByCategory('Androgen'),
      },
    ];
  }

  // Generate AI analysis based on report parameters using fertility test data
  static String generateMockAnalysis(
    AnalysisType type,
    Map<String, dynamic> parameters,
  ) {
    if (_fertilityTests == null || _fertilityTests!.isEmpty) {
      return 'analysis_loading';
    }

    final template = getAnalysisTypeTemplates().firstWhere(
      (t) => t['type'] == type,
      orElse: () => getAnalysisTypeTemplates().first,
    );

    final category = template['category'] as String;
    final tests = getTestsByCategory(category);

    if (tests.isEmpty) {
      return 'analysis_no_reference';
    }

    final StringBuffer analysis = StringBuffer();
    analysis.writeln('analysis_title'.tr(args: [template['name']]));

    int normalCount = 0;
    int abnormalCount = 0;
    List<String> criticalFindings = [];
    List<String> findings = [];

    for (var test in tests) {
      final paramValue = parameters[test.testName];
      if (paramValue != null) {
        final value = double.tryParse(paramValue.toString());
        if (value != null) {
          final status = test.getStatus(value);

          if (status == 'normal') {
            normalCount++;
            findings.add(
              '✓ ${test.testName}: $value ${test.unit} - ${'normal_range'}',
            );
          } else if (status == 'critically_low' ||
              status == 'critically_high') {
            abnormalCount++;
            final statusText = 'status_$status';
            criticalFindings.add(
              '⚠️ ${test.testName}: $value ${test.unit} - ${statusText.toUpperCase()} (${'Normal'}: ${test.normalRange} ${test.unit})',
            );
          } else {
            abnormalCount++;
            final statusText = 'status_$status';
            findings.add(
              '⚡ ${test.testName}: $value ${test.unit} - ${statusText.toUpperCase()} (${'Normal'}: ${test.normalRange} ${test.unit})',
            );
          }
        }
      }
    }

    // Add critical findings first
    if (criticalFindings.isNotEmpty) {
      analysis.writeln('analysis_critical_findings');
      for (var finding in criticalFindings) {
        analysis.writeln(finding);
      }
      analysis.writeln();
    }

    // Add other findings
    for (var finding in findings) {
      analysis.writeln(finding);
    }

    // Overall assessment
    analysis.writeln('analysis_overall');
    if (abnormalCount == 0 && normalCount > 0) {
      analysis.writeln('analysis_all_normal');
    } else if (criticalFindings.isNotEmpty) {
      analysis.writeln('analysis_critical_detected');
    } else if (abnormalCount > 0) {
      analysis.writeln('analysis_abnormal_detected');
    } else {
      analysis.writeln('analysis_enter_values');
    }

    return analysis.toString();
  }

  // Generate recommendations based on analysis type and results
  static String generateMockRecommendation(AnalysisType type) {
    final recommendations = {
      AnalysisType.hormone: 'rec_hormone',
      AnalysisType.ovarianReserve: 'rec_ovarian',
      AnalysisType.thyroid: 'rec_thyroid',
      AnalysisType.semen: 'rec_semen',
      AnalysisType.ultrasound: 'rec_ultrasound',
      AnalysisType.metabolic: 'rec_metabolic',
      AnalysisType.blood: 'rec_blood',
      AnalysisType.infection: 'rec_infection',
      AnalysisType.immunology: 'rec_immunology',
      AnalysisType.embryology: 'rec_embryology',
      AnalysisType.pregnancy: 'rec_pregnancy',
      AnalysisType.genetic: 'rec_genetic',
      AnalysisType.vitamin: 'rec_vitamin',
      AnalysisType.androgen: 'rec_androgen',
    };

    return recommendations[type] ?? 'rec_default';
  }

  // Get sample previous reports
  static List<MedicalReport> getSampleReports() {
    return [
      MedicalReport(
        id: 1,
        analysisTypeLabel: 'Sarah Ahmed',
        analysisType: AnalysisType.hormone.name,
        reportDate: DateTime.now().subtract(const Duration(days: 7)),
        parameters: {
          'FSH': 6.5,
          'LH': 5.2,
          'Estradiol (E2)': 145.0,
          'Progesterone': 1.2,
          'Prolactin': 8.5,
        },
        status: 'completed',
        aiAnalysis:
            'Sample analysis - load fertility data to view detailed results',
        recommendation: generateMockRecommendation(AnalysisType.hormone),
      ),
      MedicalReport(
        id: 2,
        analysisTypeLabel: 'Sarah Ahmed',
        analysisType: AnalysisType.ultrasound.displayName,
        reportDate: DateTime.now().subtract(const Duration(days: 14)),
        parameters: {
          'Follicle Count': 8,
          'Endometrial Thickness': 9.5,
          'Ovarian Volume': 6.2,
        },
        status: 'completed',
        aiAnalysis:
            'Sample analysis - load fertility data to view detailed results',
        recommendation: generateMockRecommendation(AnalysisType.ultrasound),
      ),
    ];
  }
}
