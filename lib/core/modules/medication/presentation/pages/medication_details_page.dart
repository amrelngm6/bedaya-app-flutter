import 'package:bedaya2/core/network/network_result.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/medication/models/medication_model.dart';
import 'package:bedaya2/core/modules/medication/presentation/pages/add_medication_page.dart';

class MedicationDetailsPage extends StatefulWidget {
  final MedicationModel medication;

  const MedicationDetailsPage({super.key, required this.medication});

  @override
  State<MedicationDetailsPage> createState() => _MedicationDetailsPageState();
}

class _MedicationDetailsPageState extends State<MedicationDetailsPage> {
  late MedicationModel _medication;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _medication = widget.medication;
  }

  void _deleteMedication() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Medication'.tr()),
        content: Text('Are you sure you want to delete this medication?'.tr()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isDeleting = true);
              final result = await sl.medications.deleteMedication(
                _medication.id,
              );
              if (!mounted) return;
              switch (result) {
                case Success():
                  // Cancel all local reminders scheduled for this medication.
                  await sl.medicationReminders.cancelForMedication(
                    _medication.id,
                  );
                  if (!mounted) return;
                  Navigator.pop(context, true);
                case Failure(:final exception):
                  setState(() => _isDeleting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(exception.message),
                      backgroundColor: Colors.red,
                    ),
                  );
              }
            },
            child: Text(
              'Delete'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _markReminderAsTaken(ReminderTime reminder) async {
    setState(() {
      final rIdx = _medication.reminderTimes.indexWhere(
        (r) => r.id == reminder.id,
      );
      if (rIdx == -1) return;
      final reminders = List<ReminderTime>.from(_medication.reminderTimes);
      reminders[rIdx] = reminders[rIdx].copyWith(
        taken: true,
        takenAt: DateTime.now(),
      );
      _medication = _medication.copyWith(reminderTimes: reminders);
    });

    // Send request to backend to mark as taken
    await sl.medications.takeMedication(_medication, reminder.time, 'custom');

    // Show confirmation notification
    sl.medicationReminders.showTakenConfirmation(_medication);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Medication is taken'.tr()),
        backgroundColor: AppColors.onlineGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        title: Text(
          'Medication Details'.tr(),
          style: AppStyles.h2.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_medication.prescribedByDoctor)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddMedicationPage(medication: _medication),
                  ),
                );
                if (result == true) {
                  final updated = await sl.medications.getMedicationById(
                    _medication.id,
                  );
                  if (!mounted) return;
                  if (updated case Success(:final data)) {
                    setState(() => _medication = data);
                  }
                }
              },
            ),
          if (!_medication.prescribedByDoctor)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteMedication,
            ),
        ],
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryTeal, AppColors.darkTeal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _medication.type.icon,
                                style: const TextStyle(fontSize: 40),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _medication.name,
                                    style: AppStyles.h2.copyWith(
                                      color: Colors.white,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _medication.type.displayName.tr(),
                                    style: AppStyles.bodyMedium.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_medication.dosage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.medical_services,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _medication.dosage!,
                                  style: AppStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Prescribed info
                        if (_medication.prescribedByDoctor) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlueBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryTeal.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.verified,
                                  color: AppColors.primaryTeal,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Prescribed by Doctor'.tr(),
                                        style: AppStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkTeal,
                                        ),
                                      ),
                                      if (_medication.doctorName != null)
                                        Text(
                                          _medication.doctorName!,
                                          style: AppStyles.bodySmall.copyWith(
                                            color: AppColors.darkTeal,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Frequency
                        if (_medication.frequency != null)
                          _buildInfoSection(
                            'Frequency'.tr(),
                            _medication.frequency!.tr(),
                            Icons.repeat,
                          ),

                        const SizedBox(height: 20),

                        // Reminder times
                        Text('Daily Reminders'.tr(), style: AppStyles.h3),
                        const SizedBox(height: 12),
                        ..._medication.reminderTimes.map((reminder) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: reminder.taken
                                    ? AppColors.onlineGreen
                                    : AppColors.greyOutline,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: reminder.taken
                                        ? AppColors.onlineGreen.withValues(
                                            alpha: 0.1,
                                          )
                                        : AppColors.primaryTeal.withValues(
                                            alpha: 0.1,
                                          ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    reminder.taken
                                        ? Icons.check_circle
                                        : Icons.access_time,
                                    color: reminder.taken
                                        ? AppColors.onlineGreen
                                        : AppColors.primaryTeal,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${reminder.time.hour.toString().padLeft(2, '0')}:${reminder.time.minute.toString().padLeft(2, '0')}',
                                        style: AppStyles.h3.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (reminder.taken &&
                                          reminder.takenAt != null)
                                        Text(
                                          '${'Taken at'.tr()} ${DateFormat('hh:mm a').format(reminder.takenAt!)}',
                                          style: AppStyles.bodySmall.copyWith(
                                            color: AppColors.onlineGreen,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (!reminder.taken &&
                                    reminder.time.isBefore(TimeOfDay.now()))
                                  ElevatedButton(
                                    onPressed: () =>
                                        _markReminderAsTaken(reminder),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryTeal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: Text(
                                      'Take'.tr(),
                                      style: AppStyles.buttonText,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 20),

                        // Duration
                        Text('Duration'.tr(), style: AppStyles.h3),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.greyOutline),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Start Date'.tr(),
                                      style: AppStyles.bodySmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(_medication.startDate),
                                      style: AppStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: AppColors.greyOutline,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'End Date'.tr(),
                                      style: AppStyles.bodySmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _medication.endDate != null
                                          ? DateFormat(
                                              'MMM dd, yyyy',
                                            ).format(_medication.endDate!)
                                          : 'Ongoing'.tr(),
                                      style: AppStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Instructions
                        if (_medication.instructions != null) ...[
                          const SizedBox(height: 20),
                          _buildInfoSection(
                            'Instructions'.tr(),
                            _medication.instructions!,
                            Icons.info_outline,
                          ),
                        ],

                        // Notes
                        if (_medication.notes != null &&
                            _medication.notes!.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildInfoSection(
                            'Notes'.tr(),
                            _medication.notes!,
                            Icons.note,
                          ),
                        ],

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppStyles.h3),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greyOutline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primaryTeal, size: 24),
              const SizedBox(width: 12),
              Expanded(child: Text(content, style: AppStyles.bodyMedium)),
            ],
          ),
        ),
      ],
    );
  }
}
