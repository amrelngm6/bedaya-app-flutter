// import 'package:bedaya2/core/models/auth_models.dart';
import 'package:bedaya2/core/modules/auth/models/patient_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';

class PatientProfilePage extends StatefulWidget {
  final PatientModel patient;

  const PatientProfilePage({super.key, required this.patient});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar with profile header
          _buildSliverAppBar(),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryTeal,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppStyles.h3.copyWith(fontSize: 16),
                unselectedLabelStyle: AppStyles.bodyMedium,
                indicatorColor: AppColors.primaryTeal,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: "Personal Info".tr()),
                  // Tab(text: "Medical Profile".tr()),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [_buildPersonalInfoTab()],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.primaryTeal,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.edit, color: Colors.white),
      //     onPressed: () {
      //       // Edit profile action
      //     },
      //   ),
      // ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primaryTeal, AppColors.darkTeal],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Profile Image
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: widget.patient.avatar != null
                        ? NetworkImage(widget.patient.avatar!)
                        : null,
                    child: widget.patient.avatar == null
                        ? Text(
                            widget.patient.firstName[0].toUpperCase() +
                                widget.patient.lastName[0].toUpperCase(),
                            style: AppStyles.h1.copyWith(
                              fontSize: 40,
                              color: AppColors.primaryTeal,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  widget.patient.fullName,
                  style: AppStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 4),
                // Age and Gender
                Text(
                  "• ${widget.patient.gender!.tr()}",
                  style: AppStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Information Card
          _buildSectionCard(
            title: "Contact Information".tr(),
            icon: Icons.contact_phone,
            children: [
              _buildInfoRow(
                Icons.email,
                "Email".tr(),
                widget.patient.email ?? '',
              ),
              const Divider(height: 24),
              _buildInfoRow(Icons.phone, "Phone".tr(), widget.patient.phone),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.location_on,
                "Address".tr(),
                widget.patient.address != null
                    ? widget.patient.address!
                    : "No address provided".tr(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Personal Details Card
          _buildSectionCard(
            title: "Personal Details".tr(),
            icon: Icons.person,
            children: [
              _buildInfoRow(
                Icons.cake,
                "Date of Birth".tr(),
                widget.patient.dateOfBirth != null
                    ? DateFormat(
                        'dd MMM yyyy',
                      ).format(DateTime.parse(widget.patient.dateOfBirth!))
                    : '',
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.badge,
                "Patient ID".tr(),
                widget.patient.id.toString(),
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.bloodtype,
                "Blood Type".tr(),
                widget.patient.medicalProfile?.bloodType ?? "N/A",
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Emergency Contact Card
          if (widget.patient.emergencyContactName != null ||
              widget.patient.emergencyContact != null)
            _buildSectionCard(
              title: "Emergency Contact".tr(),
              icon: Icons.emergency,
              children: [
                if (widget.patient.emergencyContactName != null)
                  _buildInfoRow(
                    Icons.person,
                    "Name".tr(),
                    widget.patient.emergencyContactName!,
                  ),
                if (widget.patient.emergencyContactName != null &&
                    widget.patient.emergencyContact != null)
                  const Divider(height: 24),
                if (widget.patient.emergencyContact != null)
                  _buildInfoRow(
                    Icons.phone,
                    "Phone".tr(),
                    widget.patient.emergencyContact!,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                  child: Icon(icon, color: AppColors.primaryTeal, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title, style: AppStyles.h3),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppStyles.bodySmall),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /*
  Widget _buildMedicalProfileTab() {
    final medical = widget.patient.medicalProfile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health Stats Card
          _buildSectionCard(
            title: "Health Statistics".tr(),
            icon: Icons.monitor_heart,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatBox(
                      "Height".tr(),
                      medical?.height != null
                          ? "${medical!.height!.toStringAsFixed(0)} cm"
                          : "N/A",
                      Icons.height,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatBox(
                      "Weight".tr(),
                      medical?.weight != null
                          ? "${medical!.weight!.toStringAsFixed(1)} kg"
                          : "N/A",
                      Icons.monitor_weight,
                    ),
                  ),
                ],
              ),
              if (medical?.bmi != null) ...[
                const SizedBox(height: 16),
                _buildBMIIndicator(medical!.bmi!, medical.bmiCategory),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Insurance Card
          if (medical?.insuranceProvider != null)
            _buildSectionCard(
              title: "Insurance Information".tr(),
              icon: Icons.medical_services,
              children: [
                _buildInfoRow(
                  Icons.business,
                  "Provider".tr(),
                  medical!.insuranceProvider!,
                ),
                if (medical.insuranceNumber != null) ...[
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.numbers,
                    "Policy Number".tr(),
                    medical.insuranceNumber!,
                  ),
                ],
              ],
            ),
          const SizedBox(height: 16),

          // Allergies Card
          _buildListCard(
            title: "Allergies".tr(),
            icon: Icons.warning_amber,
            items: medical?.allergies ?? [],
            emptyMessage: "No allergies recorded".tr(),
            color: Colors.red,
          ),
          const SizedBox(height: 16),

          // Chronic Diseases Card
          _buildListCard(
            title: "Chronic Diseases".tr(),
            icon: Icons.medical_information,
            items: medical?.chronicDiseases ?? [],
            emptyMessage: "No chronic diseases recorded".tr(),
            color: Colors.orange,
          ),
          const SizedBox(height: 16),

          // Current Medications Card
          _buildMedicationsCard(medical?.currentMedications ?? []),
          const SizedBox(height: 16),

          // Medical History Card
          _buildMedicalHistoryCard(medical?.medicalHistory ?? []),
          const SizedBox(height: 16),

          // Vaccinations Card
          _buildVaccinationsCard(medical?.vaccinations ?? []),

          // Notes Card
          if (medical?.notes != null && medical!.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionCard(
              title: "Medical Notes".tr(),
              icon: Icons.note_alt,
              children: [
                Text(
                  medical.notes!,
                  style: AppStyles.bodyMedium.copyWith(height: 1.5),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryTeal, size: 28),
          const SizedBox(height: 8),
          Text(value, style: AppStyles.h3.copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, style: AppStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildBMIIndicator(double bmi, String category) {
    Color getColorForBMI() {
      if (bmi < 18.5) return Colors.blue;
      if (bmi < 25) return Colors.green;
      if (bmi < 30) return Colors.orange;
      return Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: getColorForBMI().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getColorForBMI().withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.calculate, color: getColorForBMI(), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Body Mass Index (BMI)".tr(), style: AppStyles.bodySmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      bmi.toStringAsFixed(1),
                      style: AppStyles.h3.copyWith(
                        color: getColorForBMI(),
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "• $category".tr(),
                      style: AppStyles.bodyMedium.copyWith(
                        color: getColorForBMI(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required IconData icon,
    required List<String> items,
    required String emptyMessage,
    required Color color,
  }) {
    return _buildSectionCard(
      title: title,
      icon: icon,
      children: [
        if (items.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                emptyMessage,
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item, style: AppStyles.bodyMedium)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMedicationsCard(List<Medication> medications) {
    return _buildSectionCard(
      title: "Current Medications".tr(),
      icon: Icons.medication,
      children: [
        if (medications.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "No current medications".tr(),
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ...medications.map((med) {
            final isActive =
                med.endDate == null || med.endDate!.isAfter(DateTime.now());
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.onlineGreen.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive
                      ? AppColors.onlineGreen.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          med.name,
                          style: AppStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.onlineGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "Active".tr(),
                            style: AppStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${'Dosage'.tr()}: ${med.dosage} • ${med.frequency}",
                    style: AppStyles.bodySmall,
                  ),
                  if (med.prescribedBy != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      "${'Prescribed by'.tr()}: ${med.prescribedBy}",
                      style: AppStyles.bodySmall.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }
  
  Widget _buildMedicalHistoryCard(List<MedicalHistory> history) {
    return _buildSectionCard(
      title: "Medical History".tr(),
      icon: Icons.history,
      children: [
        if (history.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "No medical history recorded".tr(),
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ...history.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryPurple.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.condition,
                          style: AppStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(item.date),
                        style: AppStyles.bodySmall,
                      ),
                    ],
                  ),
                  if (item.treatment != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      "${'Treatment'.tr()}: ${item.treatment}",
                      style: AppStyles.bodySmall,
                    ),
                  ],
                  if (item.doctorName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      "${'Doctor'.tr()}: ${item.doctorName}",
                      style: AppStyles.bodySmall.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (item.notes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.notes!,
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildVaccinationsCard(List<Vaccination> vaccinations) {
    return _buildSectionCard(
      title: "Vaccinations".tr(),
      icon: Icons.vaccines,
      children: [
        if (vaccinations.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "No vaccinations recorded".tr(),
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ...vaccinations.map((vaccine) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryTeal.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vaccine.name,
                          style: AppStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(vaccine.date),
                        style: AppStyles.bodySmall,
                      ),
                    ],
                  ),
                  if (vaccine.administeredBy != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      "${'Administered by'.tr()}: ${vaccine.administeredBy}",
                      style: AppStyles.bodySmall,
                    ),
                  ],
                  if (vaccine.nextDoseDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          size: 14,
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${'Next dose'.tr()}: ${DateFormat('dd MMM yyyy').format(vaccine.nextDoseDate!)}",
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }
  */
}

// Helper class for TabBar delegate
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
