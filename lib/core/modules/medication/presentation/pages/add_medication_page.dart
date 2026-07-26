import 'package:bedaya2/core/network/network_result.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/medication/models/medication_model.dart';
import 'package:bedaya2/core/services/rxterms_service.dart';

class AddMedicationPage extends StatefulWidget {
  final MedicationModel? medication;

  const AddMedicationPage({super.key, this.medication});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  final _instructionsController = TextEditingController();

  List<String> _suggestions = [];
  bool _isSearching = false;
  bool _isSaving = false;
  MedicationType _selectedType = MedicationType.tablet;
  List<ReminderTime> _reminderTimes = [];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _frequency = 'Once daily';

  final List<String> _frequencyOptions = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'As needed',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _initializeWithMedication(widget.medication!);
    }
  }

  void _initializeWithMedication(MedicationModel medication) {
    _nameController.text = medication.name;
    _dosageController.text = medication.dosage ?? '';
    _notesController.text = medication.notes ?? '';
    _instructionsController.text = medication.instructions ?? '';
    _selectedType = medication.type;
    _reminderTimes = medication.reminderTimes;
    _startDate = medication.startDate;
    _endDate = medication.endDate;
    _frequency = medication.frequency ?? 'Once daily';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _searchMedications(String query) async {
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await RxTermsService.searchMedications(query);

    setState(() {
      _suggestions = results;
      _isSearching = false;
    });
  }

  void _addReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryTeal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _reminderTimes.add(
          ReminderTime(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            time: picked,
          ),
        );
      });
    }
  }

  void _removeReminderTime(String id) {
    setState(() {
      _reminderTimes.removeWhere((r) => r.id == id);
    });
  }

  Future<void> _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      if (_reminderTimes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add at least one reminder time'.tr()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final medication = MedicationModel(
        id: widget.medication?.id ?? '',
        name: _nameController.text,
        dosage: _dosageController.text.isEmpty ? null : _dosageController.text,
        frequency: _frequency,
        reminderTimes: _reminderTimes,
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        instructions: _instructionsController.text.isEmpty
            ? null
            : _instructionsController.text,
        prescribedByDoctor: false,
        type: _selectedType,
      );

      setState(() => _isSaving = true);

      final result = widget.medication != null
          ? await sl.medications.updateMedication(medication)
          : await sl.medications.addMedication(medication);

      if (!mounted) return;

      switch (result) {
        case Success(:final data):
          // Schedule (or reschedule) daily local reminders for every
          // reminder time.  Runs offline — no network call involved.
          await sl.medicationReminders.scheduleForMedication(data);
          if (!mounted) return;
          Navigator.pop(context, true);

        case Failure(:final exception):
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(exception.message),
              backgroundColor: Colors.red,
            ),
          );
      }
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
          widget.medication != null
              ? 'Edit Medication'.tr()
              : 'Add Medication'.tr(),
          style: AppStyles.h2.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Medication name with autocomplete
            Text('Medication Name'.tr(), style: AppStyles.h3),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Search for medication...'.tr(),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryTeal,
                ),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.greyOutline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryTeal,
                    width: 2,
                  ),
                ),
              ),
              onChanged: _searchMedications,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter medication name'.tr();
                }
                return null;
              },
            ),

            // Suggestions list
            if (_suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _suggestions[index],
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      onTap: () {
                        _nameController.text = _suggestions[index];
                        setState(() {
                          _suggestions = [];
                        });
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // Medication type
            Text('Type'.tr(), style: AppStyles.h3),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MedicationType.values.map((type) {
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(type.icon),
                      const SizedBox(width: 4),
                      Text(type.displayName.tr()),
                    ],
                  ),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  selectedColor: AppColors.primaryTeal.withValues(alpha: 0.3),
                  backgroundColor: Colors.grey[200],
                  labelStyle: AppStyles.bodySmall.copyWith(
                    color: _selectedType == type
                        ? AppColors.primaryTeal
                        : AppColors.textSecondary,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Dosage
            Text('Dosage'.tr(), style: AppStyles.h3),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dosageController,
              decoration: InputDecoration(
                hintText: 'e.g., 500mg, 2 tablets'.tr(),
                prefixIcon: const Icon(
                  Icons.medication,
                  color: AppColors.primaryTeal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.greyOutline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryTeal,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Frequency
            Text('Frequency'.tr(), style: AppStyles.h3),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _frequency,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.repeat,
                  color: AppColors.primaryTeal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.greyOutline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryTeal,
                    width: 2,
                  ),
                ),
              ),
              items: _frequencyOptions
                  .map(
                    (freq) =>
                        DropdownMenuItem(value: freq, child: Text(freq.tr())),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _frequency = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            // Reminder times
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reminder Times'.tr(), style: AppStyles.h3),
                IconButton(
                  onPressed: _addReminderTime,
                  icon: const Icon(
                    Icons.add_circle,
                    color: AppColors.primaryTeal,
                  ),
                  iconSize: 28,
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_reminderTimes.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primaryTeal,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tap + to add reminder times'.tr(),
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.darkTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...(_reminderTimes.map((reminder) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.greyOutline),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppColors.primaryTeal,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${reminder.time.hour.toString().padLeft(2, '0')}:${reminder.time.minute.toString().padLeft(2, '0')}',
                        style: AppStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeReminderTime(reminder.id),
                      ),
                    ],
                  ),
                );
              }).toList()),

            const SizedBox(height: 24),

            // Instructions
            Text('Instructions'.tr(), style: AppStyles.h3),
            const SizedBox(height: 8),
            TextFormField(
              controller: _instructionsController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g., Take with food'.tr(),
                prefixIcon: const Icon(
                  Icons.note,
                  color: AppColors.primaryTeal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.greyOutline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryTeal,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Duration section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Start Date'.tr(), style: AppStyles.h3),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primaryTeal,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              _startDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.greyOutline),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: AppColors.primaryTeal,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMM dd, yyyy').format(_startDate),
                                style: AppStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('End Date'.tr(), style: AppStyles.h3),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                _endDate ??
                                _startDate.add(const Duration(days: 30)),
                            firstDate: _startDate,
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primaryTeal,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          setState(() {
                            _endDate = picked;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.greyOutline),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: AppColors.primaryTeal,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _endDate != null
                                    ? DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(_endDate!)
                                    : 'Optional'.tr(),
                                style: AppStyles.bodyMedium.copyWith(
                                  color: _endDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notes
            Text('Notes'.tr(), style: AppStyles.h3),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Additional notes...'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.greyOutline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryTeal,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveMedication,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.medication != null
                          ? 'Update Medication'.tr()
                          : 'Save Medication'.tr(),
                      style: AppStyles.buttonText.copyWith(fontSize: 16),
                    ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
