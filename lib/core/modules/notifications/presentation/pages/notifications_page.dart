// import 'package:bedaya2/core/modules/medication/models/medication_model.dart';
// import 'package:bedaya2/core/modules/medication/presentation/pages/medication_details_page.dart';
import 'package:bedaya2/core/modules/auth/presentation/cubits/notification_cubit.dart';
import 'package:bedaya2/core/modules/medication/presentation/pages/medications_list_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/notification_model.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';
import '../../../medication/presentation/widgets/notification_card.dart';

class _Tab {
  const _Tab({required this.label, required this.types});
  final String label;
  final List<NotificationType>? types; // null = All
}

const List<_Tab> _tabs = [
  _Tab(label: 'All', types: null),
  _Tab(
    label: 'Medical',
    types: [NotificationType.appointment, NotificationType.medication],
  ),
  _Tab(
    label: 'Treatment',
    types: [NotificationType.treatment, NotificationType.testResult],
  ),
  _Tab(
    label: 'Learning',
    types: [NotificationType.educational, NotificationType.article],
  ),
  _Tab(
    label: 'Offers',
    types: [NotificationType.promotional, NotificationType.system],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// NotificationsPage
// ─────────────────────────────────────────────────────────────────────────────

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCubit()..load(),
      child: const _NotificationsView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal stateful view
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<NotificationCubit>().setTabFilter(
          _tabs[_tabController.index].types,
        );
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Handlers ─────────────────────────────────────────────────────────────

  void _onMarkAsRead(NotificationModel n) =>
      context.read<NotificationCubit>().markAsRead(n.id);

  void _onDelete(NotificationModel n) {
    context.read<NotificationCubit>().delete(n.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification deleted'.tr()),
        backgroundColor: AppColors.darkTeal,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Undo'.tr(),
          textColor: Colors.white,
          onPressed: () => context.read<NotificationCubit>().restore(n),
        ),
      ),
    );
  }

  void _onMarkAllAsRead(BuildContext ctx) {
    ctx.read<NotificationCubit>().markAllAsRead();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('All notifications marked as read'.tr()),
        backgroundColor: AppColors.primaryTeal,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (ctx, state) {
        final unread = state is NotificationLoaded ? state.unreadCount : 0;
        final cubit = ctx.read<NotificationCubit>();

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
              onPressed: () => Navigator.pop(ctx),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications'.tr(),
                  style: AppStyles.h2.copyWith(fontSize: 20),
                ),
                if (unread > 0)
                  Text(
                    '$unread ${'unread'.tr()}',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            actions: [
              // Unread filter toggle
              IconButton(
                icon: Icon(
                  cubit.isUnreadFilterActive
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined,
                  color: cubit.isUnreadFilterActive
                      ? AppColors.primaryTeal
                      : AppColors.darkTeal,
                ),
                onPressed: () =>
                    ctx.read<NotificationCubit>().toggleUnreadFilter(),
                tooltip: 'Show unread only'.tr(),
              ),
              // Options menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.darkTeal),
                onSelected: (value) {
                  if (value == 'mark_all_read') _onMarkAllAsRead(ctx);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        const Icon(Icons.done_all, size: 20),
                        const SizedBox(width: 12),
                        Text('Mark all as read'.tr()),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.primaryTeal,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primaryTeal,
                  indicatorWeight: 3,
                  labelStyle: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: AppStyles.bodyMedium.copyWith(
                    fontSize: 14,
                  ),
                  tabs: _tabs.map((t) => Tab(text: t.label.tr())).toList(),
                ),
              ),
            ),
          ),
          body: _buildBody(state, cubit),
        );
      },
    );
  }

  Widget _buildBody(NotificationState state, NotificationCubit cubit) {
    return switch (state) {
      NotificationInitial() || NotificationLoading() => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryTeal),
      ),
      NotificationError(:final message) => _ErrorState(
        message: message,
        onRetry: () => cubit.load(refresh: true),
      ),
      NotificationLoaded() => _buildList(state, cubit),
    };
  }

  Widget _buildList(NotificationLoaded state, NotificationCubit cubit) {
    if (state.displayed.isEmpty) {
      return _EmptyState(
        isUnreadFilter: cubit.isUnreadFilterActive,
        onShowAll: cubit.toggleUnreadFilter,
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryTeal,
      onRefresh: () => cubit.load(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.displayed.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.displayed.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryTeal),
              ),
            );
          }

          final notification = state.displayed[index];
          return NotificationCard(
            notification: notification,
            onTap: () {
              _onMarkAsRead(notification);
              _showDetail(notification);
            },
            onDismiss: () => _onDelete(notification),
          );
        },
      ),
    );
  }

  void _showDetail(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationDetailSheet(notification: notification),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isUnreadFilter, required this.onShowAll});

  final bool isUnreadFilter;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnreadFilter
                  ? Icons.notifications_off_outlined
                  : Icons.notifications_none,
              size: 60,
              color: AppColors.primaryTeal.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isUnreadFilter
                ? 'No unread notifications'.tr()
                : 'No notifications yet'.tr(),
            style: AppStyles.h3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isUnreadFilter
                  ? 'You\'re all caught up!'.tr()
                  : 'When you receive notifications, they will appear here'
                        .tr(),
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (isUnreadFilter) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onShowAll,
              icon: const Icon(Icons.visibility),
              label: Text('Show all notifications'.tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryTeal,
                side: const BorderSide(color: AppColors.primaryTeal),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 72,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong'.tr(),
              style: AppStyles.h3.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text('Try again'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification detail bottom-sheet
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationDetailSheet extends StatelessWidget {
  const _NotificationDetailSheet({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.greyOutline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _titleForType(notification.type).tr(),
                          style: AppStyles.h2.copyWith(fontSize: 22),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.formattedTime,
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    notification.title,
                    style: AppStyles.h3.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notification.message,
                    style: AppStyles.bodyLarge.copyWith(
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (notification.imageUrl != null) ...[
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        notification.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ],
                  if (notification.metadata != null &&
                      notification.metadata!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Additional Information'.tr(),
                      style: AppStyles.h3.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ...notification.metadata!.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${e.key}:',
                                style: AppStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                e.value.toString(),
                                style: AppStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onAction(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _actionLabel(notification.type).tr(),
                        style: AppStyles.buttonText,
                      ),
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

  void _onAction(BuildContext context) {
    if (notification.type == NotificationType.medication) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MedicationsListPage()),
      );
    } else {
      Navigator.pop(context);
    }
  }

  static String _titleForType(NotificationType type) => switch (type) {
    NotificationType.appointment => 'Appointment Details',
    NotificationType.medication => 'Medication Reminder',
    NotificationType.testResult => 'Test Results',
    NotificationType.treatment => 'Treatment Update',
    NotificationType.article => 'Article',
    NotificationType.promotional => 'Special Offer',
    NotificationType.educational => 'Health Tip',
    NotificationType.system => 'System Notification',
  };

  static String _actionLabel(NotificationType type) => switch (type) {
    NotificationType.appointment => 'View Appointment',
    NotificationType.medication => 'View Medication',
    NotificationType.testResult => 'View Results',
    NotificationType.treatment => 'View Details',
    NotificationType.article => 'Read Article',
    NotificationType.promotional => 'View Offer',
    NotificationType.educational => 'Learn More',
    NotificationType.system => 'Okay',
  };
}
