import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/service_locator.dart';
import '../../../notifications/models/notification_model.dart';
import '../../../../network/network_result.dart';

// ─────────────────────────────────────────────────────────────────────────────
// States
// ─────────────────────────────────────────────────────────────────────────────

sealed class NotificationState {
  const NotificationState();
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

final class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

final class NotificationLoaded extends NotificationState {
  /// Full list fetched from the backend (all pages loaded so far).
  final List<NotificationModel> all;

  /// Subset of [all] currently displayed (after tab + unread filters).
  final List<NotificationModel> displayed;

  final int unreadCount;
  final bool hasMore;
  final int currentPage;

  /// True while the next page is being fetched (pagination spinner).
  final bool isLoadingMore;

  const NotificationLoaded({
    required this.all,
    required this.displayed,
    required this.unreadCount,
    required this.hasMore,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  NotificationLoaded copyWith({
    List<NotificationModel>? all,
    List<NotificationModel>? displayed,
    int? unreadCount,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return NotificationLoaded(
      all: all ?? this.all,
      displayed: displayed ?? this.displayed,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
}

// ─────────────────────────────────────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────────────────────────────────────

/// Manages notification data for [NotificationsPage].
///
/// Data flow
/// ---------
/// 1. [load] / [refresh] fetches the first page from the Laravel API and
///    stores items in [NotificationLoaded.all].
/// 2. [loadMore] appends subsequent pages.
/// 3. [setTabFilter] / [toggleUnreadFilter] apply client-side filtering to
///    produce [NotificationLoaded.displayed] without extra API calls.
/// 4. [markAsRead], [markAllAsRead], [delete] apply an optimistic local update
///    immediately, then confirm with the backend.
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(const NotificationInitial());

  /// Active tab-based type filter (null = show all).
  List<NotificationType>? _typeFilter;

  /// Whether the "unread only" toggle is active.
  bool _unreadOnly = false;

  // ─── Load ─────────────────────────────────────────────────────────────────

  Future<void> load({bool refresh = false}) async {
    if (refresh || state is! NotificationLoaded) {
      emit(const NotificationLoading());
    }

    final result = await sl.notifications.getNotifications(page: 1);
    switch (result) {
      case Success(:final data):
        final models = data.data.map(NotificationModel.fromApiModel).toList();
        _emitLoaded(
          all: models,
          hasMore: data.hasNextPage,
          page: data.currentPage,
        );

      case Failure(:final exception):
        emit(NotificationError(exception.message));
    }
  }

  // ─── Pagination ───────────────────────────────────────────────────────────

  Future<void> loadMore() async {
    if (state is! NotificationLoaded) return;
    final current = state as NotificationLoaded;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await sl.notifications.getNotifications(page: nextPage);

    switch (result) {
      case Success(:final data):
        final moreModels = data.data
            .map(NotificationModel.fromApiModel)
            .toList();
        _emitLoaded(
          all: [...current.all, ...moreModels],
          hasMore: data.hasNextPage,
          page: data.currentPage,
        );

      case Failure():
        // Roll back the spinner on failure; keep existing data.
        emit(current.copyWith(isLoadingMore: false));
    }
  }

  // ─── Filters ──────────────────────────────────────────────────────────────

  /// Called when the user selects a tab.
  ///
  /// [types] is the set of [NotificationType] values for that tab,
  /// or `null` for the "All" tab.
  void setTabFilter(List<NotificationType>? types) {
    _typeFilter = types;
    _reEmitFiltered();
  }

  void toggleUnreadFilter() {
    _unreadOnly = !_unreadOnly;
    _reEmitFiltered();
  }

  // ─── Mark as read ─────────────────────────────────────────────────────────

  Future<void> markAsRead(String id) async {
    if (state is! NotificationLoaded) return;
    final current = state as NotificationLoaded;

    // Optimistic update.
    final updated = current.all.map((n) {
      return n.id == id ? n.copyWith(isRead: true) : n;
    }).toList();
    _emitLoaded(
      all: updated,
      hasMore: current.hasMore,
      page: current.currentPage,
    );

    // Confirm with backend (fire-and-forget; failure is silent).
    await sl.notifications.markAsRead(int.tryParse(id) ?? 0);
  }

  Future<void> markAllAsRead() async {
    if (state is! NotificationLoaded) return;
    final current = state as NotificationLoaded;

    // Optimistic update.
    final updated = current.all.map((n) => n.copyWith(isRead: true)).toList();
    _emitLoaded(
      all: updated,
      hasMore: current.hasMore,
      page: current.currentPage,
    );

    await sl.notifications.markAllAsRead();
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<void> delete(String id) async {
    if (state is! NotificationLoaded) return;
    final current = state as NotificationLoaded;

    // Optimistic update.
    final updated = current.all.where((n) => n.id != id).toList();
    _emitLoaded(
      all: updated,
      hasMore: current.hasMore,
      page: current.currentPage,
    );

    await sl.notifications.deleteNotification(int.tryParse(id) ?? 0);
  }

  /// Restores a previously deleted notification (undo action).
  void restore(NotificationModel notification) {
    if (state is! NotificationLoaded) return;
    final current = state as NotificationLoaded;

    final restored = [...current.all, notification]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _emitLoaded(
      all: restored,
      hasMore: current.hasMore,
      page: current.currentPage,
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _emitLoaded({
    required List<NotificationModel> all,
    required bool hasMore,
    required int page,
    bool isLoadingMore = false,
  }) {
    final unread = all.where((n) => !n.isRead).length;
    final displayed = _applyFilters(all);
    emit(
      NotificationLoaded(
        all: all,
        displayed: displayed,
        unreadCount: unread,
        hasMore: hasMore,
        currentPage: page,
        isLoadingMore: isLoadingMore,
      ),
    );
  }

  List<NotificationModel> _applyFilters(List<NotificationModel> source) {
    var result = source;

    if (_typeFilter != null) {
      result = result.where((n) => _typeFilter!.contains(n.type)).toList();
    }
    if (_unreadOnly) {
      result = result.where((n) => !n.isRead).toList();
    }
    return result;
  }

  void _reEmitFiltered() {
    if (state is! NotificationLoaded) return;
    final current = state as NotificationLoaded;
    final displayed = _applyFilters(current.all);
    emit(current.copyWith(displayed: displayed));
  }

  // ─── Accessors ────────────────────────────────────────────────────────────

  bool get isUnreadFilterActive => _unreadOnly;
}
