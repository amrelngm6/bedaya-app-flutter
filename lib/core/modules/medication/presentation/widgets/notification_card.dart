import 'package:flutter/material.dart';
import 'package:bedaya2/core/modules/notifications/models/notification_model.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        onDismiss?.call();
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white
                : AppColors.lightBlueBackground.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.greyOutline
                  : AppColors.primaryTeal.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppStyles.h3.copyWith(
                                fontSize: 15,
                                fontWeight: notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            notification.formattedTime,
                            style: AppStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: AppStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (notification.imageUrl != null) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            notification.imageUrl!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _buildTypeChip(),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    margin: const EdgeInsets.only(left: 8, top: 2),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color backgroundColor;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.appointment:
        iconData = Icons.calendar_today;
        backgroundColor = const Color(0xFFE3F2FD);
        iconColor = const Color(0xFF1976D2);
        break;
      case NotificationType.medication:
        iconData = Icons.medication;
        backgroundColor = const Color(0xFFFCE4EC);
        iconColor = const Color(0xFFC2185B);
        break;
      case NotificationType.testResult:
        iconData = Icons.science;
        backgroundColor = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF388E3C);
        break;
      case NotificationType.treatment:
        iconData = Icons.local_hospital;
        backgroundColor = const Color(0xFFFFF3E0);
        iconColor = const Color(0xFFF57C00);
        break;
      case NotificationType.article:
        iconData = Icons.article;
        backgroundColor = const Color(0xFFF3E5F5);
        iconColor = const Color(0xFF7B1FA2);
        break;
      case NotificationType.promotional:
        iconData = Icons.local_offer;
        backgroundColor = const Color(0xFFFFEBEE);
        iconColor = const Color(0xFFD32F2F);
        break;
      case NotificationType.system:
        iconData = Icons.notifications_active;
        backgroundColor = const Color(0xFFE0F2F1);
        iconColor = const Color(0xFF00796B);
        break;
      case NotificationType.educational:
        iconData = Icons.lightbulb;
        backgroundColor = const Color(0xFFFFF9C4);
        iconColor = const Color(0xFFF9A825);
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, color: iconColor, size: 22),
    );
  }

  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getTypeColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getTypeColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        notification.typeLabel,
        style: AppStyles.bodySmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getTypeColor(),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.appointment:
        return const Color(0xFF1976D2);
      case NotificationType.medication:
        return const Color(0xFFC2185B);
      case NotificationType.testResult:
        return const Color(0xFF388E3C);
      case NotificationType.treatment:
        return const Color(0xFFF57C00);
      case NotificationType.article:
        return const Color(0xFF7B1FA2);
      case NotificationType.promotional:
        return const Color(0xFFD32F2F);
      case NotificationType.system:
        return const Color(0xFF00796B);
      case NotificationType.educational:
        return const Color(0xFFF9A825);
    }
  }
}
