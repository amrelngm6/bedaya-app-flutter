import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';
import '../../models/medical_condition_model.dart';

class MedicalConditionDetailsPage extends StatelessWidget {
  final MedicalProfileCondition condition;

  const MedicalConditionDetailsPage({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    final categoryColor =
        condition.category?.colorValue ?? AppColors.primaryTeal;
    final statusColor = condition.statusColorValue;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: categoryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 56,
                bottom: 16,
                end: 16,
              ),
              title: Text(
                condition.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.h3.copyWith(color: Colors.white, fontSize: 16),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      categoryColor,
                      categoryColor.withValues(alpha: 0.75),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _categoryIcon(condition.category?.icon),
                    size: 54,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status + category chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (condition.statusLabel != null)
                        _buildChip(
                          icon: Icons.circle,
                          label: condition.statusLabel!.tr(),
                          color: statusColor,
                        ),
                      if (condition.category != null)
                        _buildChip(
                          icon: _categoryIcon(condition.category!.icon),
                          label: condition.category!.name,
                          color: categoryColor,
                        ),
                      if (condition.conditionDate != null &&
                          condition.conditionDate!.isNotEmpty)
                        _buildChip(
                          icon: Icons.event,
                          label: _formatDate(condition.conditionDate!),
                          color: AppColors.textSecondary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (condition.description != null &&
                      condition.description!.isNotEmpty)
                    _buildSectionCard(
                      title: 'Description'.tr(),
                      icon: Icons.description,
                      child: Text(
                        condition.description!,
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),

                  if (condition.notes != null &&
                      condition.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Notes'.tr(),
                      icon: Icons.notes,
                      child: Text(
                        condition.notes!,
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Attached Files'.tr(),
                    icon: Icons.attach_file,
                    child: condition.files.isEmpty
                        ? Text(
                            'No files attached'.tr(),
                            style: AppStyles.bodyMedium,
                          )
                        : Column(
                            children: condition.files
                                .map((file) => _buildFileTile(context, file))
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
              Text(title, style: AppStyles.h3.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildFileTile(BuildContext context, MedicalProfileFile file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.lightBlueBackground.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openFile(context, file),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    file.isImage
                        ? Icons.image
                        : file.isPdf
                        ? Icons.picture_as_pdf
                        : Icons.insert_drive_file,
                    color: AppColors.primaryTeal,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.title?.isNotEmpty == true
                            ? file.title!
                            : (file.fileName ?? ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (file.displaySize.isNotEmpty)
                        Text(file.displaySize, style: AppStyles.bodySmall),
                    ],
                  ),
                ),
                const Icon(
                  Icons.open_in_new,
                  size: 18,
                  color: AppColors.primaryTeal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openFile(BuildContext context, MedicalProfileFile file) async {
    final url = file.fileUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to open file'.tr())));
      }
    }
  }

  IconData _categoryIcon(String? icon) {
    switch (icon) {
      case 'heart':
        return Icons.favorite;
      case 'lungs':
        return Icons.air;
      case 'bone':
        return Icons.accessibility_new;
      case 'brain':
        return Icons.psychology;
      case 'kidney':
        return Icons.opacity;
      case 'diabetes':
        return Icons.bloodtype;
      case 'allergy':
        return Icons.warning_amber;
      case 'surgery':
        return Icons.medical_services;
      default:
        return Icons.folder_shared;
    }
  }

  String _formatDate(String isoDate) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(isoDate));
    } catch (_) {
      return isoDate;
    }
  }
}
