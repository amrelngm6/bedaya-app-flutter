import 'package:bedaya2/core/modules/auth/presentation/pages/login_page.dart';
import 'package:bedaya2/core/modules/auth/presentation/pages/register_page.dart';
import 'package:bedaya2/core/modules/bookings/presentation/widgets/auth_required_sheet.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import '../../models/medication_model.dart';
import 'add_medication_page.dart';
import 'medication_details_page.dart';
import '../widgets/medication_card.dart';

class MedicationsListPage extends StatefulWidget {
  const MedicationsListPage({super.key});

  @override
  State<MedicationsListPage> createState() => _MedicationsListPageState();
}

class _MedicationsListPageState extends State<MedicationsListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MedicationModel> _medications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthAndProceed(back: false);
    _tabController = TabController(length: 3, vsync: this);
    _fetchMedications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Auth Gate ────────────────────────────────────────────────────────────
  void _checkAuthAndProceed({bool? back = false}) {
    if (!sl.storage.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAuthModal(back: back);
      });
    }
  }

  Future<void> _showAuthModal({bool? back = false}) async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (sheetCtx) => AuthRequiredSheet(
        onNavigateToLogin: () async {
          await Navigator.push(
            sheetCtx,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        },
        onNavigateToRegister: () async {
          await Navigator.push(
            sheetCtx,
            MaterialPageRoute(builder: (_) => const RegisterPage()),
          );
        },
        onGoBack: () {
          Navigator.pop(sheetCtx);
          if (mounted) Navigator.pop(context);
        },
      ),
    );

    // If the modal was closed without authenticating, leave the booking page.
    if (mounted && !sl.storage.isLoggedIn && back == true) {
      Navigator.pop(context);
    }
  }

  Future<void> _fetchMedications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await sl.medications.getMedications();
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _medications = data;
          _isLoading = false;
        });
      case Failure(:final exception):
        setState(() {
          _errorMessage = exception.message;
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        title: Text(
          'Pill Reminder'.tr(),
          style: AppStyles.h2.copyWith(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'My Meds'.tr()),
            // Tab(text: 'Presc'.tr()),
            // Tab(text: 'My Meds'.tr()),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildError()
          : Column(
              children: [
                _buildTodaysRemindersSection(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMedicationsList(_medications),
                      // _buildMedicationsList(
                      //   sl.medications.getPrescribed(_medications),
                      // ),
                      // _buildMedicationsList(
                      //   sl.medications.getUserAdded(_medications),
                      // ),
                    ],
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicationPage()),
          );
          _fetchMedications();
        },
        backgroundColor: AppColors.primaryTeal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Medicine'.tr(), style: AppStyles.buttonText),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: AppStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchMedications,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
            ),
            child: Text(
              'Retry'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysRemindersSection() {
    final todaysReminders = sl.medications.getTodaysReminders(_medications);

    if (todaysReminders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryTeal.withValues(alpha: 0.8),
            AppColors.darkTeal,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                "${'Upcoming Medications'.tr()} (${todaysReminders.length})",
                style: AppStyles.h3.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...todaysReminders.take(3).map((reminderData) {
            final medication = reminderData['medication'] as MedicationModel;
            final reminder = reminderData['reminder'] as ReminderTime;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${reminder.time.hour.toString().padLeft(2, '0')}:${reminder.time.minute.toString().padLeft(2, '0')}',
                      style: AppStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      medication.name,
                      style: AppStyles.bodyMedium.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    medication.type.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMedicationsList(List<MedicationModel> medications) {
    if (medications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No medications yet'.tr(),
              style: AppStyles.h3.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text('Add your first medication'.tr(), style: AppStyles.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMedications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final medication = medications[index];
          return MedicationCard(
            medication: medication,
            onTap: () async {
              // final result =
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MedicationDetailsPage(medication: medication),
                ),
              );
              _fetchMedications();
            },
            onMarkTaken: (reminderId) {
              setState(() {
                final idx = _medications.indexWhere(
                  (m) => m.id == medication.id,
                );
                if (idx == -1) return;
                final med = _medications[idx];
                final rIdx = med.reminderTimes.indexWhere(
                  (r) => r.id == reminderId,
                );
                if (rIdx == -1) return;
                final reminders = List<ReminderTime>.from(med.reminderTimes);
                reminders[rIdx] = reminders[rIdx].copyWith(
                  taken: true,
                  takenAt: DateTime.now(),
                );
                _medications[idx] = med.copyWith(reminderTimes: reminders);
              });

              // Show confirmation notification
              sl.medicationReminders.showTakenConfirmation(medication);
            },
          );
        },
      ),
    );
  }
}
