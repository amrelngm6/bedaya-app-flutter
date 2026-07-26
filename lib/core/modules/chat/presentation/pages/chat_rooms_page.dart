import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bedaya2/core/modules/chat/models/chat_room_model.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/auth/presentation/cubits/chat_cubit.dart';
import 'chat_room_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Chat Rooms Page  —  lists all support conversations
// ─────────────────────────────────────────────────────────────────────────────

class ChatRoomsPage extends StatelessWidget {
  const ChatRoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatRoomsCubit()..loadRooms(),
      child: const _ChatRoomsView(),
    );
  }
}

class _ChatRoomsView extends StatefulWidget {
  const _ChatRoomsView();

  @override
  State<_ChatRoomsView> createState() => _ChatRoomsViewState();
}

class _ChatRoomsViewState extends State<_ChatRoomsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ChatRoomsCubit>().loadMoreRooms();
    }
  }

  ChatRoomApiModel? selectedRoom;

  Future<ChatRoomApiModel?> _startNewConversation(
    String subject,
    String initialMessage,
  ) async {
    try {
      // For demo, we just create a new empty conversation and open it.
      // In a real app, you might want to show a form to select topic, enter initial message, etc.
      final result = await sl.chat.createConversation(
        subject: subject,
        initialMessage: initialMessage,
      );
      if (result is Success<ChatRoomApiModel>) {
        final newRoom = result.data;
        if (!mounted) return null;
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => ChatRoomPage(room: newRoom)));
        return newRoom;
      } else {
        if (!mounted) return null;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to start conversation')));
      }
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    return null;
  }

  /// Modal to type initial message and select topic before creating conversation (optional)
  Future<ChatRoomApiModel?> _showNewConversationDialog() async {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    final result = await showDialog<ChatRoomApiModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chat new conversation'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(labelText: 'Chat subject'.tr()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Chat initial message'.tr(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              final subject = subjectController.text.trim();
              final initialMessage = messageController.text.trim();
              if (initialMessage.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter your message'.tr())),
                );
                return;
              }
              Navigator.of(context).pop(); // Close the dialog
              final newRoom = await _startNewConversation(
                subject,
                initialMessage,
              );
              if (newRoom != null) {
                // Optionally, you can refresh the rooms list or directly navigate to the new room.
                context.read<ChatRoomsCubit>().loadRooms(refresh: true);
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatRoomPage(room: newRoom),
                  ),
                );
              }
            },
            child: Text('start'.tr()),
          ),
        ],
      ),
    );

    return result;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(context),
      body: BlocBuilder<ChatRoomsCubit, ChatRoomsState>(
        builder: (context, state) {
          return switch (state) {
            ChatRoomsInitial() || ChatRoomsLoading() => _buildLoading(),
            ChatRoomsLoaded() => _buildRoomList(context, state),
            ChatRoomsError(:final message) => _buildError(context, message),
          };
        },
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryTeal,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'chat_support'.tr(),
            style: AppStyles.h3.copyWith(color: Colors.white, fontSize: 18),
          ),
          Text(
            'chat_support_subtitle'.tr(),
            style: AppStyles.bodySmall.copyWith(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'chat_refresh'.tr(),
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => context.read<ChatRoomsCubit>().loadRooms(),
        ),
        // Start new conversation button (optional, can be removed if not needed)
        IconButton(
          tooltip: 'chat_new_conversation'.tr(),
          icon: const Icon(Icons.add_comment_rounded),
          onPressed: () {
            _showNewConversationDialog();
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: Container(
          height: 4,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryTeal, AppColors.darkTeal],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Loading ──────────────────────────────────────────────────────────────

  Widget _buildLoading() => const Center(
    child: CircularProgressIndicator(color: AppColors.primaryTeal),
  );

  // ─── Error ────────────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 64,
            color: AppColors.greyOutline,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppStyles.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: Text('chat_retry'.tr()),
            onPressed: () => context.read<ChatRoomsCubit>().loadRooms(),
          ),
        ],
      ),
    ),
  );

  // ─── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              size: 52,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'chat_no_conversations'.tr(),
            style: AppStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'chat_no_conversations_desc'.tr(),
            style: AppStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  // ─── Room list ────────────────────────────────────────────────────────────

  Widget _buildRoomList(BuildContext context, ChatRoomsLoaded state) {
    if (state.rooms.isEmpty) return _buildEmpty(context);

    return RefreshIndicator(
      color: AppColors.primaryTeal,
      onRefresh: () => context.read<ChatRoomsCubit>().loadRooms(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.hasMore ? state.rooms.length + 1 : state.rooms.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 88,
          endIndent: 16,
          color: AppColors.greyOutline,
        ),
        itemBuilder: (context, index) {
          if (index == state.rooms.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryTeal),
              ),
            );
          }
          return _ChatRoomTile(
            room: state.rooms[index],
            onTap: () => _openRoom(context, state.rooms[index]),
          );
        },
      ),
    );
  }

  void _openRoom(BuildContext context, ChatRoomApiModel room) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ChatRoomPage(room: room)));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual room tile
// ─────────────────────────────────────────────────────────────────────────────

class _ChatRoomTile extends StatelessWidget {
  const _ChatRoomTile({required this.room, required this.onTap});

  final ChatRoomApiModel room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lastMsg = room.lastMessage;
    final hasUnread = room.hasUnread;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // ── Avatar ──────────────────────────────────────────────────────
            _SupportAvatar(unread: hasUnread),
            const SizedBox(width: 14),
            // ── Info ─────────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.name.isNotEmpty
                              ? room.name
                              : 'chat_support'.tr(),
                          style: AppStyles.bodyLarge.copyWith(
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (lastMsg != null)
                        Text(
                          _formatTime(lastMsg.createdAt),
                          style: AppStyles.bodySmall.copyWith(
                            color: hasUnread
                                ? AppColors.primaryTeal
                                : AppColors.textSecondary,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _lastMessagePreview(lastMsg),
                          style: AppStyles.bodySmall.copyWith(
                            color: hasUnread
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (hasUnread) _UnreadBadge(count: room.unreadCount),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _lastMessagePreview(ChatMessageApiModel? msg) {
    if (msg == null) return 'chat_no_messages_yet'.tr();
    if (msg.type != 'text') return '📎 ${'chat_attachment'.tr()}';
    return msg.message;
  }

  String _formatTime(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();

      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else if (dt.year == now.year &&
          dt.month == now.month &&
          dt.day == now.day - 1) {
        return 'Yesterday';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (_) {
      return '';
    }
  }
}

// ─── Support avatar widget ────────────────────────────────────────────────────

class _SupportAvatar extends StatelessWidget {
  const _SupportAvatar({required this.unread});

  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryTeal, AppColors.darkTeal],
            ),
          ),
          child: const Icon(
            Icons.support_agent_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        if (unread)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.onlineGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Unread badge ─────────────────────────────────────────────────────────────

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        color: AppColors.primaryTeal,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
