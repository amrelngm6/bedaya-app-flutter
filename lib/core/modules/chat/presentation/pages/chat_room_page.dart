import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bedaya2/core/modules/chat/models/chat_room_model.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/auth/presentation/cubits/chat_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Chat Room Page  —  messages view for a single support conversation
// ─────────────────────────────────────────────────────────────────────────────

class ChatRoomPage extends StatelessWidget {
  const ChatRoomPage({super.key, required this.room});

  final ChatRoomApiModel room;

  @override
  Widget build(BuildContext context) {
    print('Opening chat room: ${room.id}');
    return BlocProvider(
      create: (_) => ChatCubit()..loadRoom(room.id),
      child: _ChatRoomView(room: room),
    );
  }
}

class _ChatRoomView extends StatefulWidget {
  const _ChatRoomView({required this.room});

  final ChatRoomApiModel room;

  @override
  State<_ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<_ChatRoomView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Load older messages when scrolled to the very top.
    if (_scrollController.position.pixels <= 50) {
      context.read<ChatCubit>().loadOlderMessages();
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    await context.read<ChatCubit>().sendMessage(text);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _scrollToBottom(animated: false),
                  );
                }
                if (state is ChatMessageSendFailed) {
                  _showSendErrorSnackbar(context, state.error);
                  context.read<ChatCubit>().retryAfterError();
                }
              },
              builder: (context, state) {
                return switch (state) {
                  ChatInitial() || ChatLoading() => _buildLoading(),
                  ChatLoaded() => _buildMessageList(context, state),
                  ChatError(:final message) => _buildError(context, message),
                  ChatMessageSendFailed(:final messages, :final room) =>
                    _buildMessageList(
                      context,
                      ChatLoaded(
                        room: room,
                        messages: messages,
                        hasMoreMessages: false,
                        currentPage: 1,
                      ),
                    ),
                };
              },
            ),
          ),
          _buildInputBar(context),
        ],
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryTeal,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.darkTeal,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.room.name.isNotEmpty
                      ? widget.room.name
                      : 'chat_support_team'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.onlineGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'chat_online'.tr(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
            Icons.wifi_off_rounded,
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
            onPressed: () => context.read<ChatCubit>().loadRoom(widget.room.id),
          ),
        ],
      ),
    ),
  );

  // ─── Message list ──────────────────────────────────────────────────────────

  Widget _buildMessageList(BuildContext context, ChatLoaded state) {
    if (state.messages.isEmpty) {
      return _buildEmptyConversation();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      itemCount:
          state.messages.length +
          (state.hasMoreMessages ? 1 : 0) +
          (state.isSending ? 1 : 0),
      itemBuilder: (context, index) {
        // Top loader for older messages
        if (state.hasMoreMessages && index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryTeal,
                ),
              ),
            ),
          );
        }

        final msgIndex = state.hasMoreMessages ? index - 1 : index;

        // Sending indicator bubble
        if (state.isSending && msgIndex == state.messages.length) {
          return _SendingBubble(text: _messageController.text);
        }

        final msg = state.messages[msgIndex];
        final previousMsg = msgIndex > 0 ? state.messages[msgIndex - 1] : null;
        final showDateSeparator =
            previousMsg == null ||
            _isNewDay(previousMsg.createdAt, msg.createdAt);

        return Column(
          children: [
            if (showDateSeparator) _DateSeparator(dateStr: msg.createdAt),
            _MessageBubble(message: msg),
          ],
        );
      },
    );
  }

  Widget _buildEmptyConversation() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.lightBlueBackground,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: AppColors.primaryTeal,
          ),
        ),
        const SizedBox(height: 20),
        Text('chat_start_conversation'.tr(), style: AppStyles.h3),
        const SizedBox(height: 8),
        Text(
          'chat_start_conversation_desc'.tr(),
          style: AppStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  bool _isNewDay(String prev, String current) {
    try {
      final a = DateTime.parse(prev);
      final b = DateTime.parse(current);
      return a.year != b.year || a.month != b.month || a.day != b.day;
    } catch (_) {
      return false;
    }
  }

  // ─── Input bar ────────────────────────────────────────────────────────────

  Widget _buildInputBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? 10
            : MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FA),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.greyOutline),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'chat_type_message'.tr(),
                  hintStyle: AppStyles.bodyMedium,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              final isSending = state is ChatLoaded && state.isSending;
              return GestureDetector(
                onTap: isSending ? null : _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isSending
                        ? AppColors.greyOutline
                        : AppColors.primaryTeal,
                    shape: BoxShape.circle,
                    boxShadow: isSending
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.primaryTeal.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: isSending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryTeal,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSendErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message bubble
// ─────────────────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessageApiModel message;

  @override
  Widget build(BuildContext context) {
    final isOwn = message.isOwnMessage;

    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isOwn ? 15 : 0,
        right: isOwn ? 0 : 15,
      ),
      child: Row(
        mainAxisAlignment: isOwn
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Staff avatar (left side only)
          if (!isOwn) ...[
            _StaffAvatar(name: message.sender.name),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              crossAxisAlignment: isOwn
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Sender name for staff
                if (!isOwn && message.sender.isStaff)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      message.sender.name,
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),

                // Bubble body
                GestureDetector(
                  onLongPress: () => _copyToClipboard(context, message.message),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isOwn ? AppColors.primaryTeal : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isOwn ? 18 : 4),
                        bottomRight: Radius.circular(isOwn ? 4 : 18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Files / attachments
                        if (message.hasFiles) ...[
                          ...message.files.map(
                            (f) => _FileAttachmentChip(file: f, isOwn: isOwn),
                          ),
                          if (message.message.isNotEmpty)
                            const SizedBox(height: 6),
                        ],
                        // Text
                        if (message.message.isNotEmpty)
                          Text(
                            message.message,
                            style: TextStyle(
                              color: isOwn
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontSize: 14.5,
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Time + read receipt
                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: AppStyles.bodySmall.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (isOwn) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isSeen
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 14,
                          color: message.isSeen
                              ? AppColors.primaryTeal
                              : AppColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('chat_copied'.tr()),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatTime(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sending indicator bubble (optimistic UI)
// ─────────────────────────────────────────────────────────────────────────────

class _SendingBubble extends StatelessWidget {
  const _SendingBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4, left: 64),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Opacity(
              opacity: 0.6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Staff avatar  (initials)
// ─────────────────────────────────────────────────────────────────────────────

class _StaffAvatar extends StatelessWidget {
  const _StaffAvatar({required this.name});

  final String name;

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryTeal, AppColors.darkTeal],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// File attachment chip
// ─────────────────────────────────────────────────────────────────────────────

class _FileAttachmentChip extends StatelessWidget {
  const _FileAttachmentChip({required this.file, required this.isOwn});

  final ChatMessageFileModel file;
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    final color = isOwn ? Colors.white : AppColors.primaryTeal;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            file.isImage ? Icons.image_rounded : Icons.attach_file_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              file.name,
              style: TextStyle(
                color: color,
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date separator
// ─────────────────────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.dateStr});

  final String dateStr;

  String get _label {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return 'Today';
      }
      if (dt.year == now.year &&
          dt.month == now.month &&
          dt.day == now.day - 1) {
        return 'Yesterday';
      }
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFDDE3EA))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDDE3EA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _label,
                style: AppStyles.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xFFDDE3EA))),
        ],
      ),
    );
  }
}
