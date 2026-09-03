// import 'package:bedaya2/core/models/auth_models.dart';
import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/auth/models/auth_models.dart';
import 'package:bedaya2/core/modules/auth/models/patient_model.dart';
import 'package:bedaya2/core/modules/auth/presentation/cubits/auth_cubit.dart';
import 'package:bedaya2/core/modules/patients/models/medical_condition_model.dart';
import 'package:bedaya2/core/modules/patients/services/image-service.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/presentation/widgets/main-navigation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';
import 'medical_condition_details_page.dart';

class PatientProfilePage extends StatefulWidget {
  final PatientModel patient;

  const PatientProfilePage({super.key, required this.patient});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // PatientModel get patient => widget.patient;
  late PatientModel patient;

  List<MedicalProfileCondition>? _conditions;
  bool _loadingConditions = false;
  String? _conditionsError;

  @override
  void initState() {
    super.initState();
    patient = widget.patient;
    _tabController = TabController(length: 2, vsync: this);
    _fetchConditions();
  }

  Future<void> _fetchConditions() async {
    setState(() {
      _loadingConditions = true;
      _conditionsError = null;
    });

    final result = await sl.patient.getMedicalConditions();

    if (!mounted) return;
    setState(() {
      _loadingConditions = false;
      switch (result) {
        case Success(:final data):
          _conditions = data;
        case Failure(:final exception):
          _conditionsError = exception.message;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        UserModel? user = state is AuthAuthenticated ? state.user : null;
        return user == null
            ? Center()
            : Scaffold(
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
                            Tab(text: "Medical Profile".tr()),
                          ],
                        ),
                      ),
                    ),

                    // Tab Content
                    SliverFillRemaining(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPersonalInfoTab(),
                          _buildMedicalProfileTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
      },
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
                GestureDetector(
                  onTap:
                      changeProfilePicture, // Function to change profile picture
                  child: Container(
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
                      backgroundImage: patient.avatar != null
                          ? NetworkImage(patient.avatar!)
                          : null,
                      child: patient.avatar == null
                          ? Text(
                              patient.firstName[0].toUpperCase() +
                                  patient.lastName[0].toUpperCase(),
                              style: AppStyles.h1.copyWith(
                                fontSize: 40,
                                color: AppColors.primaryTeal,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  patient.fullName,
                  style: AppStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 4),
                // Age and Gender
                Text(
                  "• ${patient.gender!.tr()}",
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
              _buildInfoRow(Icons.email, "Email".tr(), patient.email ?? ''),
              const Divider(height: 24),
              _buildInfoRow(Icons.phone, "Phone".tr(), patient.phone),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.location_on,
                "Address".tr(),
                patient.address != null
                    ? patient.address!
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
                patient.dateOfBirth != null
                    ? DateFormat(
                        'dd MMM yyyy',
                      ).format(DateTime.parse(patient.dateOfBirth!))
                    : '',
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.badge,
                "Patient ID".tr(),
                patient.id.toString(),
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.bloodtype,
                "Blood Type".tr(),
                patient.medicalProfile?.bloodType ?? "N/A",
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Emergency Contact Card
          if (patient.emergencyContactName != null ||
              patient.emergencyContact != null)
            _buildSectionCard(
              title: "Emergency Contact".tr(),
              icon: Icons.emergency,
              children: [
                if (patient.emergencyContactName != null)
                  _buildInfoRow(
                    Icons.person,
                    "Name".tr(),
                    patient.emergencyContactName!,
                  ),
                if (patient.emergencyContactName != null &&
                    patient.emergencyContact != null)
                  const Divider(height: 24),
                if (patient.emergencyContact != null)
                  _buildInfoRow(
                    Icons.phone,
                    "Phone".tr(),
                    patient.emergencyContact!,
                  ),
              ],
            ),

          // Delete account button
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Handle delete account action
                showDeleteAccountConfirmation(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete Account'.tr()),
            ),
          ),
          const SizedBox(height: 50),
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

  void changeProfilePicture() {
    // Pick an image from gallery or camera, then upload and update the profile picture.
    pickAndUpload(ImageSource.gallery); // For example, picking from gallery
  }

  Future<void> pickAndUpload(ImageSource source) async {
    final imageService = ImageService();

    final image = await imageService.pickImage(source);

    if (image == null) return;

    final url = await imageService.uploadImage(image);

    if (url != null) {
      setState(() {
        patient.avatar =
            '${AppConfig.baseUrl}/$url'; // Update the patient's avatar URL
      });
    } else {}
  }

  Widget _buildMedicalProfileTab() {
    if (_loadingConditions && _conditions == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryTeal),
      );
    }

    if (_conditionsError != null && _conditions == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_conditionsError!, style: AppStyles.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchConditions,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
              ),
              child: Text('Retry'.tr()),
            ),
          ],
        ),
      );
    }

    final conditions = _conditions ?? [];

    if (conditions.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchConditions,
        color: AppColors.primaryTeal,
        child: Stack(
          children: [
            ListView(),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_shared_outlined,
                      size: 56,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No medical conditions recorded'.tr(),
                      style: AppStyles.h3.copyWith(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your medical conditions will appear here'.tr(),
                      style: AppStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchConditions,
      color: AppColors.primaryTeal,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: conditions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildConditionCard(conditions[index]),
      ),
    );
  }

  Widget _buildConditionCard(MedicalProfileCondition condition) {
    final categoryColor =
        condition.category?.colorValue ?? AppColors.primaryTeal;
    final statusColor = condition.statusColorValue;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MedicalConditionDetailsPage(condition: condition),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.greyOutline.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.folder_shared, color: categoryColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition.title,
                    style: AppStyles.h3.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (condition.category != null) ...[
                        Flexible(
                          child: Text(
                            condition.category!.name,
                            style: AppStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (condition.files.isNotEmpty) ...[
                        const Icon(
                          Icons.attach_file,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${condition.files.length}',
                          style: AppStyles.bodySmall,
                        ),
                      ],
                    ],
                  ),
                  if (condition.statusLabel != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        condition.statusLabel!.tr(),
                        style: AppStyles.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'.tr()),
          content: Text('Are you sure you want to delete your account?'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                // Call the delete account function here
                sl.patient
                    .deleteAccount()
                    .then((result) {
                      if (result is Success) {
                        // Handle successful account deletion, e.g., navigate to login page
                        Navigator.of(
                          context,
                        ).pop(); // Go back to previous screen

                        // Handle any unexpected errors
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Account deleted successfully, Your information will be removed from our servers within 30 days.'
                                  .tr(),
                            ),
                          ),
                        );

                        // Logout
                        context.read<AuthCubit>().logout();
                        sl.auth.logout();

                        // Redirect to MainNavigationPage
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const MainNavigationPage(),
                          ),
                          (route) => false,
                        );
                      } else if (result is Failure) {
                        // Handle failure, e.g., show an error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.exception.message)),
                        );
                      }
                    })
                    .catchError((error) {
                      // Handle any unexpected errors
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('An error occurred'.tr())),
                      );
                    });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'.tr()),
            ),
          ],
        );
      },
    );
  }
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
