// ignore_for_file: use_build_context_synchronously
import 'package:bedaya2/core/theme/styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../medication/models/medical_report_model.dart';
import '../../models/fertility_test_model.dart';
import '../../services/medical_report_service.dart';
import '../cubits/medical_report_cubit.dart';
import '../../../../theme/colors.dart';

class AIMedicalAnalysisWidget extends StatelessWidget {
  const AIMedicalAnalysisWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MedicalReportCubit()..loadTests(),
      child: const _AIMedicalAnalysisView(),
    );
  }
}

class _AIMedicalAnalysisView extends StatefulWidget {
  const _AIMedicalAnalysisView();

  @override
  State<_AIMedicalAnalysisView> createState() => _AIMedicalAnalysisViewState();
}

class _AIMedicalAnalysisViewState extends State<_AIMedicalAnalysisView> {
  AnalysisType? _selectedAnalysisType;
  final Map<String, TextEditingController> _parameterControllers = {};
  bool _isScanning = false;
  bool _hasScannedImage = false;
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    for (final c in _parameterControllers.values) {
      c.dispose();
    }
    _textRecognizer.close();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── OCR scanning ─────────────────────────────────────────────────────────

  Future<void> _scanDocument(ImageSource source) async {
    setState(() => _isScanning = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image == null) {
        setState(() => _isScanning = false);
        return;
      }
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognised = await _textRecognizer.processImage(
        inputImage,
      );
      _parseAndFillParameters(recognised.text);
      setState(() {
        _isScanning = false;
        _hasScannedImage = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report scanned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (_) {
      setState(() => _isScanning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan report. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── OCR parsing ──────────────────────────────────────────────────────────

  void _parseAndFillParameters(String text) {
    final lower = text.toLowerCase();

    _selectedAnalysisType = _selectedAnalysisType ?? _detectAnalysisType(lower);
    const patterns = <String, List<String>>{
      'FSH': [
        r'fsh[:\s]*(\d+\.?\d*)',
        r'follicle[- ]stimulating[:\s]*(\d+\.?\d*)',
      ],
      'LH': [r'lh[:\s]*(\d+\.?\d*)', r'luteinizing[:\s]*(\d+\.?\d*)'],
      'Estradiol (E2)': [r'estradiol[:\s]*(\d+\.?\d*)', r'e2[:\s]*(\d+\.?\d*)'],
      'Progesterone': [
        r'progesterone[:\s]*(\d+\.?\d*)',
        r'p4[:\s]*(\d+\.?\d*)',
      ],
      'Prolactin': [r'prolactin[:\s]*(\d+\.?\d*)', r'prl[:\s]*(\d+\.?\d*)'],
      'Testosterone': [r'testosterone[:\s]*(\d+\.?\d*)'],
      'AMH (Anti-Mullerian Hormone)': [
        r'amh[:\s]*(\d+\.?\d*)',
        r'anti[- ]?mullerian[:\s]*(\d+\.?\d*)',
      ],
      'TSH': [r'tsh[:\s]*(\d+\.?\d*)'],
      'Free T4': [r'free[- ]?t4[:\s]*(\d+\.?\d*)', r'ft4[:\s]*(\d+\.?\d*)'],
      'Free T3': [r'free[- ]?t3[:\s]*(\d+\.?\d*)', r'ft3[:\s]*(\d+\.?\d*)'],
      'Sperm Count': [r'sperm[- ]?count[:\s]*(\d+\.?\d*)'],
      'Sperm Motility': [r'motility[:\s]*(\d+\.?\d*)'],
      'Sperm Morphology': [r'morphology[:\s]*(\d+\.?\d*)'],
      'Semen Volume': [r'semen[- ]?volume[:\s]*(\d+\.?\d*)'],
      'Antral Follicle Count (AFC)': [
        r'afc[:\s]*(\d+)',
        r'antral[- ]follicle[:\s]*(\d+)',
      ],
      'Endometrial Thickness': [r'endometrial[:\s]*(\d+\.?\d*)'],
      'Ovarian Volume': [r'ovarian[- ]volume[:\s]*(\d+\.?\d*)'],
      'Fasting Glucose': [r'fasting[- ]glucose[:\s]*(\d+\.?\d*)'],
      'HbA1c': [r'hba1c[:\s]*(\d+\.?\d*)'],
      'Fasting Insulin': [r'fasting[- ]insulin[:\s]*(\d+\.?\d*)'],
      'Hemoglobin': [
        r'hemoglobin[:\s]*(\d+\.?\d*)',
        r'\bhb[:\s]*(\d+\.?\d*)',
        r'hgb[:\s]*(\d+\.?\d*)',
      ],
      'Hematocrit': [r'hematocrit[:\s]*(\d+\.?\d*)', r'hct[:\s]*(\d+\.?\d*)'],
      'Platelet Count': [r'platelet[:\s]*(\d+\.?\d*)', r'plt[:\s]*(\d+\.?\d*)'],
      'HIV': [r'hiv[:\s]*(\w+)'],
      'Hepatitis B': [r'hepatitis[- ]?b[:\s]*(\w+)', r'hbs[- ]?ag[:\s]*(\w+)'],
      'Hepatitis C': [r'hepatitis[- ]?c[:\s]*(\w+)', r'hcv[:\s]*(\w+)'],
      'Anticardiolipin Antibody': [r'anticardiolipin[:\s]*(\w+)'],
      'Lupus Anticoagulant': [r'lupus[- ]anticoagulant[:\s]*(\w+)'],
      'Fertilization Rate': [r'fertilization[:\s]*(\d+\.?\d*)'],
      'Blastocyst Formation Rate': [r'blastocyst[:\s]*(\d+\.?\d*)'],
      'Embryo Grade': [r'embryo[- ]?grade[:\s]*(\w+)'],
      'Beta-hCG': [r'beta[- ]?hcg[:\s]*(\d+\.?\d*)', r'\bhcg[:\s]*(\d+\.?\d*)'],
      'Karyotype': [r'karyotype[:\s]*(\w+)'],
      'Vitamin D': [
        r'vitamin[- ]?d[:\s]*(\d+\.?\d*)',
        r'25[- ]oh[- ]?d[:\s]*(\d+\.?\d*)',
      ],
      'DHEA-S': [r'dhea[- ]?s[:\s]*(\d+\.?\d*)'],
    };
    for (final entry in patterns.entries) {
      for (final pattern in entry.value) {
        final match = RegExp(pattern, caseSensitive: false).firstMatch(lower);
        if (match != null && match.groupCount > 0) {
          final value = match.group(1);
          if (value != null && value.isNotEmpty) {
            _parameterControllers
                    .putIfAbsent(entry.key, TextEditingController.new)
                    .text =
                value;
            break;
          }
        }
      }
    }
    setState(() {});
  }

  AnalysisType? _detectAnalysisType(String lower) {
    if (lower.contains('fsh') || lower.contains('estradiol')) {
      return AnalysisType.hormone;
    }
    if (lower.contains('amh')) return AnalysisType.ovarianReserve;
    if (lower.contains('tsh') || lower.contains('thyroid')) {
      return AnalysisType.thyroid;
    }
    if (lower.contains('semen') || lower.contains('sperm')) {
      return AnalysisType.semen;
    }
    if (lower.contains('follicle') || lower.contains('endometrial')) {
      return AnalysisType.ultrasound;
    }
    if (lower.contains('glucose') || lower.contains('hba1c')) {
      return AnalysisType.metabolic;
    }
    if (lower.contains('hemoglobin') || lower.contains('cbc')) {
      return AnalysisType.blood;
    }
    if (lower.contains('hiv') || lower.contains('hepatitis')) {
      return AnalysisType.infection;
    }
    if (lower.contains('anticardiolipin')) return AnalysisType.immunology;
    if (lower.contains('embryo')) return AnalysisType.embryology;
    if (lower.contains('hcg') || lower.contains('pregnancy')) {
      return AnalysisType.pregnancy;
    }
    if (lower.contains('karyotype') || lower.contains('genetic')) {
      return AnalysisType.genetic;
    }
    if (lower.contains('vitamin')) return AnalysisType.vitamin;
    if (lower.contains('dhea') || lower.contains('androgen')) {
      return AnalysisType.androgen;
    }
    return null;
  }

  // ─── Scan sheet ────────────────────────────────────────────────────────────

  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Scan Medical Report',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how to scan your report',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              _scanOptionTile(
                icon: Icons.camera_alt,
                title: 'Take Photo',
                subtitle: 'Use camera to scan report',
                onTap: () {
                  Navigator.pop(context);
                  _scanDocument(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
              _scanOptionTile(
                icon: Icons.photo_library,
                title: 'Choose from Gallery',
                subtitle: 'Select existing photo',
                onTap: () {
                  Navigator.pop(context);
                  _scanDocument(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scanOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryTeal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryTeal),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  // ─── Submit ────────────────────────────────────────────────────────────────

  void _submitReport() {
    if (_selectedAnalysisType == null) return;
    final parameters = <String, dynamic>{};
    // Access current testsData to resolve field_key for each controller entry
    final state = context.read<MedicalReportCubit>().state;
    final testsData = state is MedicalReportReady ? state.testsData : null;

    _parameterControllers.forEach((controllerKey, controller) {
      final value = controller.text.trim();
      if (value.isNotEmpty) {
        // Resolve to field_key if testsData is available
        String paramKey = controllerKey;
        if (testsData != null) {
          for (final cat in testsData.categories) {
            for (final t in cat.tests) {
              if (t.testName == controllerKey) {
                paramKey = t.submissionKey;
                break;
              }
            }
          }
        }
        parameters[paramKey] = double.tryParse(value) ?? value;
      }
    });
    context.read<MedicalReportCubit>().submitReport(
      analysisType: _selectedAnalysisType!,
      parameters: parameters,
    );
  }

  void _resetSelection() {
    setState(() {
      _selectedAnalysisType = null;
      _parameterControllers.clear();
      _hasScannedImage = false;
    });
  }

  void _scrollToInputs() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent * 0.6,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MedicalReportCubit, MedicalReportState>(
      listener: (context, state) {
        if (state is MedicalReportError && !state.isTestsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () =>
                    context.read<MedicalReportCubit>().resetToReady(),
              ),
            ),
          );
          context.read<MedicalReportCubit>().resetToReady();
        }
      },
      builder: (context, state) {
        if (state is MedicalReportSubmitted) {
          return _buildAnalysisResult(
            state.report,
            state.testsData,
            state.previousReports,
          );
        }
        return _buildForm(state);
      },
    );
  }

  Widget _buildForm(MedicalReportState state) {
    final isSubmitting = state is MedicalReportSubmitting;
    MedicalTestsResponse? testsData;
    List<MedicalReport> previousReports = [];
    bool isLoadingTests = false;
    bool isLoadingReports = false;
    String? errorMessage;

    if (state is MedicalReportTestsLoading) {
      isLoadingTests = true;
    } else if (state is MedicalReportReady) {
      testsData = state.testsData;
      previousReports = state.previousReports;
      isLoadingReports = state.isLoadingReports;
    } else if (state is MedicalReportError && state.isTestsError) {
      errorMessage = state.message;
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          if (isLoadingTests)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (errorMessage != null)
            _buildErrorState(errorMessage)
          else if (testsData != null) ...[
            _buildAnalysisTypeSelector(testsData),
            const SizedBox(height: 24),
            if (_selectedAnalysisType != null) ...[
              _buildScanButton(),
              const SizedBox(height: 16),
              if (_hasScannedImage)
                _buildScannedValuesSummary()
              else
                _buildParameterInputs(testsData),
              const SizedBox(height: 24),
              _buildAnalyzeButton(isSubmitting),
            ],
          ],
          const SizedBox(height: 32),
          _buildPreviousReports(previousReports, testsData, isLoadingReports),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryTeal.withValues(alpha: 0.1),
            AppColors.primaryTeal.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.analytics, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical Report Analysis',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get AI-powered insights for your IVF tests',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Error state ───────────────────────────────────────────────────────────

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<MedicalReportCubit>().retry(),
              icon: const Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Analysis type selector ────────────────────────────────────────────────

  static const Map<AnalysisType, String> _typeIcons = {
    AnalysisType.hormone: '🧪',
    AnalysisType.ovarianReserve: '🥚',
    AnalysisType.thyroid: '⚡',
    AnalysisType.semen: '🔬',
    AnalysisType.ultrasound: '📊',
    AnalysisType.metabolic: '🩺',
    AnalysisType.blood: '💉',
    AnalysisType.infection: '🦠',
    AnalysisType.immunology: '🛡️',
    AnalysisType.embryology: '👶',
    AnalysisType.pregnancy: '🤰',
    AnalysisType.genetic: '🧬',
    AnalysisType.vitamin: '💊',
    AnalysisType.androgen: '💪',
  };

  Widget _buildAnalysisTypeSelector(MedicalTestsResponse testsData) {
    final types = testsData.analysisTypes.isNotEmpty
        ? testsData.analysisTypes.entries
              .map(
                (e) => (
                  type: AnalysisType.fromApiKey(e.key),
                  label: e.value.toString(),
                ),
              )
              .where((t) => t.type != null)
              .map((t) => (type: t.type!, label: t.label))
              .toList()
        : AnalysisType.values
              .map((t) => (type: t, label: t.displayName))
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Analysis Type:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: types.length,
          itemBuilder: (_, index) {
            final item = types[index];
            final isSelected = _selectedAnalysisType == item.type;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _selectedAnalysisType = item.type;
                  _parameterControllers.clear();
                  _hasScannedImage = false;
                });
                _scrollToInputs();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryTeal.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryTeal
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _typeIcons[item.type] ?? '🔬',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primaryTeal
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─── Scan button ───────────────────────────────────────────────────────────

  Widget _buildScanButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.document_scanner, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan Medical Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Use OCR to auto-fill values from image',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isScanning ? null : _showScanOptions,
              icon: _isScanning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.camera_alt),
              label: Text(_isScanning ? 'Scanning...' : 'Scan Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Scanned values summary ────────────────────────────────────────────────

  Widget _buildScannedValuesSummary() {
    final filled = <String, String>{};
    _parameterControllers.forEach((k, c) {
      if (c.text.isNotEmpty) filled[k] = c.text;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Scanned Values',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.green.shade700),
                tooltip: 'Edit values',
                onPressed: () => setState(() => _hasScannedImage = false),
              ),
              IconButton(
                icon: Icon(Icons.clear, color: Colors.red.shade700),
                tooltip: 'Clear all',
                onPressed: () => setState(() {
                  _hasScannedImage = false;
                  for (final c in _parameterControllers.values) {
                    c.clear();
                  }
                }),
              ),
            ],
          ),
          const Divider(height: 16),
          if (filled.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No values detected. Tap edit to enter manually.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...filled.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Review the extracted values above. Tap edit to make changes or proceed with analysis.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Parameter inputs ──────────────────────────────────────────────────────

  Widget _buildParameterInputs(MedicalTestsResponse testsData) {
    if (_selectedAnalysisType == null) return const SizedBox();

    final matches = testsData.categories
        .where((c) => c.category == _selectedAnalysisType!.apiKey)
        .toList();

    final catObj = matches.isNotEmpty
        ? matches.first
        : FertilityTestCategory(
            category: _selectedAnalysisType!.apiKey,
            categoryLabel: _selectedAnalysisType!.displayName,
            tests: [],
          );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _typeIcons[_selectedAnalysisType!] ?? '🔬',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  catObj.categoryLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          if (catObj.tests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No reference tests available for this category. Enter values manually.',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            )
          else
            ...catObj.tests.map(_buildTestField),
        ],
      ),
    );
  }

  Widget _buildTestField(FertilityTest test) {
    // Always key by testName for OCR compatibility; remapped to fieldKey at submit
    final controller = _parameterControllers.putIfAbsent(
      test.testName,
      TextEditingController.new,
    );

    final keyboardType = test.inputType == 'number'
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.text;

    final hintText = test.placeholder?.isNotEmpty == true
        ? test.placeholder!
        : test.inputType == 'number'
        ? 'Enter value'
        : 'Enter text';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        test.testName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (test.isRequired)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (test.description != null && test.description!.isNotEmpty)
                Tooltip(
                  message: test.description!,
                  child: const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              suffixText: test.unit.isNotEmpty ? test.unit : null,
              helperText: test.hasRange
                  ? '${'Normal range'}: ${test.normalRange}${test.unit.isNotEmpty ? ' ${test.unit}' : ''}'
                  : null,
              helperStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Analyze button ────────────────────────────────────────────────────────

  Widget _buildAnalyzeButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Analyzing...'),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome),
                  const SizedBox(width: 8),
                  Text(
                    'Analyze with AI',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ─── Analysis result ───────────────────────────────────────────────────────

  Widget _buildAnalysisResult(
    MedicalReport report,
    MedicalTestsResponse testsData,
    List<MedicalReport> previous,
  ) {
    Color statusColor() {
      if (report.statusColor != null) {
        switch (report.statusColor) {
          case 'green':
            return Colors.green;
          case 'orange':
            return Colors.orange;
          case 'red':
            return Colors.red;
        }
      }
      switch (report.status) {
        case 'completed':
          return Colors.green;
        case 'reviewed':
          return Colors.blue;
        default:
          return Colors.orange;
      }
    }

    final sc = statusColor();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Analysis Result',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _resetSelection();
                  context.read<MedicalReportCubit>().resetToReady();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Report info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.description,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.analysisTypeDisplayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(report.displayDate),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: sc.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        report.statusLabel ?? report.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: sc,
                        ),
                      ),
                    ),
                  ],
                ),
                if (report.reportNumber != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${'Report'} #${report.reportNumber}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Parameters with status colouring
          if (report.parameters.isNotEmpty)
            _buildParametersCard(report, testsData),
          const SizedBox(height: 16),

          // AI Analysis
          if (report.aiAnalysis != null && report.aiAnalysis!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryTeal.withValues(alpha: 0.1),
                    AppColors.primaryTeal.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryTeal.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.primaryTeal),
                      const SizedBox(width: 8),
                      Text(
                        'AI Analysis:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    report.aiAnalysis!,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Recommendation
          if (report.recommendation != null &&
              report.recommendation!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Recommendations:',
                        style: AppStyles.bodyLarge.copyWith(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    report.recommendation!,
                    style: AppStyles.bodyLarge.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),

          // Doctor notes
          if (report.notes != null && report.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.note, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Notes:',
                        style: AppStyles.bodyLarge.copyWith(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.notes!,
                    style: AppStyles.bodyLarge.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _resetSelection();
                    context.read<MedicalReportCubit>().resetToReady();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text('New Analysis'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryTeal,
                    side: BorderSide(color: AppColors.primaryTeal),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildParametersCard(
    MedicalReport report,
    MedicalTestsResponse testsData,
  ) {
    // Prefer server-computed field_results (richer, authoritative)
    if (report.fieldResults.isNotEmpty) {
      return _buildParametersCardFromFieldResults(report.fieldResults);
    }
    // Fallback: compute status client-side from raw parameters
    return _buildParametersCardLegacy(report, testsData);
  }

  Widget _buildParametersCardFromFieldResults(
    Map<String, dynamic> fieldResults,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test Parameters:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          ...fieldResults.entries.map((entry) {
            final res = entry.value as Map<String, dynamic>? ?? {};
            final testName = res['test_name'] as String? ?? entry.key;
            final value = res['value'];
            final unit = res['unit'] as String? ?? '';
            final status = res['status'] as String? ?? 'unknown';
            final statusLabel =
                res['status_label'] as String? ??
                status.replaceAll('_', ' ').toUpperCase();
            final normalRangeText = res['normal_range_text'] as String?;
            final normalMin = (res['normal_min'] as num?)?.toDouble();
            final normalMax = (res['normal_max'] as num?)?.toDouble();

            Color statusColour() {
              switch (status) {
                case 'critically_low':
                case 'critically_high':
                  return Colors.red;
                case 'low':
                case 'high':
                  return Colors.orange;
                case 'normal':
                  return Colors.green;
                default:
                  return Colors.grey;
              }
            }

            String rangeDisplay() {
              if (normalRangeText != null && normalRangeText.isNotEmpty) {
                return normalRangeText;
              }
              if (normalMin != null && normalMax != null) {
                return '$normalMin - $normalMax $unit';
              }
              if (normalMin != null) return '>= $normalMin $unit';
              if (normalMax != null) return '<= $normalMax $unit';
              return '';
            }

            final range = rangeDisplay();
            final sc = statusColour();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          testName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (range.isNotEmpty)
                          Text(
                            '${'Normal'}: $range',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$value${unit.isNotEmpty ? ' $unit' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (status != 'unknown')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: sc.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: sc,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildParametersCardLegacy(
    MedicalReport report,
    MedicalTestsResponse testsData,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test Parameters:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          ...report.parameters.entries.map((entry) {
            FertilityTest? ref;
            outer:
            for (final cat in testsData.categories) {
              for (final t in cat.tests) {
                if (t.testName.toLowerCase() == entry.key.toLowerCase() ||
                    (t.fieldKey?.toLowerCase() == entry.key.toLowerCase())) {
                  ref = t;
                  break outer;
                }
              }
            }

            final numValue = double.tryParse(entry.value.toString());
            final statusKey = (ref != null && numValue != null)
                ? ref.getStatus(numValue)
                : null;

            Color statusColour() {
              switch (statusKey) {
                case 'critically_low':
                case 'critically_high':
                  return Colors.red;
                case 'low':
                case 'high':
                  return Colors.orange;
                case 'normal':
                  return Colors.green;
                default:
                  return Colors.grey;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key, style: const TextStyle(fontSize: 14)),
                        if (ref != null && ref.hasRange)
                          Text(
                            '${'Normal'}: ${ref.normalRange} ${ref.unit}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${entry.value}${ref != null ? ' ${ref.unit}' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (statusKey != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColour().withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusKey.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColour(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Previous reports ──────────────────────────────────────────────────────

  Widget _buildPreviousReports(
    List<MedicalReport> reports,
    MedicalTestsResponse? testsData,
    bool isLoading,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (reports.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Previous Reports:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reports.length,
          itemBuilder: (_, index) {
            final report = reports[index];
            Color chipColor() {
              switch (report.status) {
                case 'completed':
                  return Colors.green;
                case 'reviewed':
                  return Colors.blue;
                default:
                  return Colors.orange;
              }
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.description, color: AppColors.primaryTeal),
                ),
                title: Text(
                  report.analysisTypeDisplayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy').format(report.displayDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor().withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report.statusLabel ?? report.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: chipColor(),
                    ),
                  ),
                ),
                onTap: () {
                  // Show report modal
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => Container(
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: _buildAnalysisResult(report, testsData!, reports),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
