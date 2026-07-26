import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/modules/bookings/models/appointment_model.dart';
import 'package:bedaya2/core/modules/auth/presentation/cubits/auth_cubit.dart';
import 'package:bedaya2/core/modules/auth/presentation/pages/login_page.dart';
import 'package:bedaya2/core/modules/bookings/presentation/pages/booking_appointment_page.dart';
import 'package:bedaya2/core/modules/bookings/presentation/pages/booking_details_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';

class BookingsListPage extends StatefulWidget {
  const BookingsListPage({super.key});

  @override
  State<BookingsListPage> createState() => _BookingsListPageState();
}

class _BookingsListPageState extends State<BookingsListPage>
    with SingleTickerProviderStateMixin {
  static const _statuses = [
    'all',
    'pending',
    'confirmed',
    'completed',
    'cancelled',
  ];

  late TabController _tabController;
  int _currentTab = 0;

  // Per-tab state
  final Map<int, List<AppointmentModel>> _items = {};
  final Map<int, bool> _loading = {};
  final Map<int, bool> _loadingMore = {};
  final Map<int, String?> _errors = {};
  final Map<int, int> _currentPage = {};
  final Map<int, bool> _hasMore = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) return;
        setState(() => _currentTab = _tabController.index);
        _loadTab(_tabController.index, refresh: false);
      });
    _loadTab(0, refresh: true);

    sl.analytics.trackScreen('BookingsListPage');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // String? get _statusFilter {
  //   final s = _statuses[_currentTab];
  //   return s == 'all' ? null : s;
  // }

  Future<void> _loadTab(int tabIndex, {required bool refresh}) async {
    if (refresh) {
      setState(() {
        _items[tabIndex] = [];
        _currentPage[tabIndex] = 1;
        _hasMore[tabIndex] = true;
        _errors[tabIndex] = null;
        _loading[tabIndex] = true;
      });
    } else if (_items.containsKey(tabIndex) && !(_hasMore[tabIndex] ?? true)) {
      return; // already fully loaded
    }

    final page = _currentPage[tabIndex] ?? 1;
    final status = tabIndex == 0 ? null : _statuses[tabIndex];

    final result = await sl.bookings.getMyBookings(page: page, status: status);
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        final existing = List<AppointmentModel>.from(_items[tabIndex] ?? []);
        existing.addAll(data.data);
        setState(() {
          _items[tabIndex] = existing;
          _loading[tabIndex] = false;
          _loadingMore[tabIndex] = false;
          _hasMore[tabIndex] = data.currentPage < data.lastPage;
          _currentPage[tabIndex] = page + 1;
          _errors[tabIndex] = null;
        });
      case Failure(:final exception):
        setState(() {
          _loading[tabIndex] = false;
          _loadingMore[tabIndex] = false;
          _errors[tabIndex] = exception.message;
        });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore[_currentTab] == true) return;
    if (!(_hasMore[_currentTab] ?? false)) return;
    setState(() => _loadingMore[_currentTab] = true);
    await _loadTab(_currentTab, refresh: false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: _buildAppBar(context),
          body: user == null ? _buildLoginPrompt(context) : _buildBody(context),
          floatingActionButton: user != null
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookingAppointmentPage(),
                      ),
                    ).then((_) => _loadTab(_currentTab, refresh: true));
                  },
                  backgroundColor: AppColors.primaryTeal,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'book_new_appointment'.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : null,
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'my_appointments'.tr(),
        style: AppStyles.h2.copyWith(fontSize: 20),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primaryTeal,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: AppStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            unselectedLabelStyle: AppStyles.bodyMedium.copyWith(fontSize: 13),
            indicatorColor: AppColors.primaryTeal,
            indicatorWeight: 3,
            tabAlignment: TabAlignment.start,
            tabs: _statuses
                .map((s) => Tab(text: 'booking_status_$s'.tr()))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final isLoading = _loading[_currentTab] ?? false;
    final error = _errors[_currentTab];
    final items = _items[_currentTab] ?? [];
    final isLoadingMore = _loadingMore[_currentTab] ?? false;
    final hasMore = _hasMore[_currentTab] ?? false;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryTeal),
      );
    }

    if (error != null && items.isEmpty) {
      return _buildError(error);
    }

    if (items.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      color: AppColors.primaryTeal,
      onRefresh: () => _loadTab(_currentTab, refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: items.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _buildLoadMoreButton(isLoadingMore);
          }
          return _AppointmentCard(
            appointment: items[index],
            onTap: () => _openDetails(context, items[index]),
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton(bool isLoadingMore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: isLoadingMore
            ? const CircularProgressIndicator(color: AppColors.primaryTeal)
            : TextButton(
                onPressed: _loadMore,
                child: Text(
                  'load_more'.tr(),
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: AppColors.primaryTeal,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'no_bookings'.tr(),
              style: AppStyles.h2.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'no_bookings_desc'.tr(),
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _loadTab(_currentTab, refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: AppColors.primaryTeal,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'appointments_login_required'.tr(),
              style: AppStyles.h2.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'appointments_login_required_desc'.tr(),
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'auth_login'.tr(),
                  style: AppStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, AppointmentModel appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingDetailsPage(appointment: appointment),
      ),
    ).then((_) => _loadTab(_currentTab, refresh: true));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Appointment Card
// ─────────────────────────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment, required this.onTap});

  final AppointmentModel appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.0),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor info row
                Row(
                  children: [
                    _DoctorAvatar(imageUrl: appointment.doctorImageUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.doctorName,
                            style: AppStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkTeal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appointment.doctorSpecialty,
                            style: AppStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _StatusChip(status: appointment.status),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 14),

                // Date / time / type row
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: _formatDate(appointment.appointmentDate),
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.access_time_rounded,
                      label: appointment.appointmentTime,
                    ),
                    const SizedBox(width: 8),
                    _BookingTypeBadge(isOnline: appointment.isOnline),
                  ],
                ),

                const SizedBox(height: 10),

                // Cost row
                Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${'booking_cost'.tr()}: ',
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'EGP ${appointment.cost.toStringAsFixed(0)}',
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.darkTeal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

// ─── Doctor Avatar ────────────────────────────────────────────────────────────

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final fullUrl = imageUrl.startsWith('http')
        ? imageUrl
        : '${AppConfig.baseUrl}/$imageUrl';

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.darkTeal, AppColors.primaryTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipOval(
        child: imageUrl.isEmpty
            ? const Icon(Icons.person, color: Colors.white, size: 28)
            : Image.network(
                fullUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.person, color: Colors.white, size: 28),
              ),
      ),
    );
  }
}

// ─── Status Chip ─────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, bgColor, icon) = switch (status) {
      'confirmed' => (
        const Color(0xFF2E7D32),
        const Color(0xFFE8F5E9),
        Icons.check_circle_outline_rounded,
      ),
      'completed' => (
        const Color(0xFF1D7885),
        const Color(0xFFE0F7FA),
        Icons.task_alt_rounded,
      ),
      'cancelled' => (
        const Color(0xFFC62828),
        const Color(0xFFFFEBEE),
        Icons.cancel_outlined,
      ),
      _ => (
        // pending
        const Color(0xFFF57F17),
        const Color(0xFFFFFDE7),
        Icons.hourglass_top_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            'booking_status_$status'.tr(),
            style: AppStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Visit Type Badge ─────────────────────────────────────────────────────────

class _BookingTypeBadge extends StatelessWidget {
  const _BookingTypeBadge({required this.isOnline});
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline
            ? AppColors.onlineGreen.withValues(alpha: 0.1)
            : AppColors.primaryTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.videocam_outlined : Icons.local_hospital_outlined,
            size: 13,
            color: isOnline ? AppColors.onlineGreen : AppColors.primaryTeal,
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? 'booking_online'.tr() : 'booking_in_person'.tr(),
            style: AppStyles.bodySmall.copyWith(
              color: isOnline ? AppColors.onlineGreen : AppColors.primaryTeal,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Chip ────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
