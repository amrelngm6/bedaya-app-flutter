import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/service_locator.dart';
import '../../../chat/models/chat_room_model.dart';
import '../../../../network/network_result.dart';

// ═════════════════════════════════════════════════════════════════════════════
// CHAT ROOMS CUBIT  (conversation list screen)
// ═════════════════════════════════════════════════════════════════════════════

// ─── States ───────────────────────────────────────────────────────────────────

sealed class ChatRoomsState {
  const ChatRoomsState();
}

final class ChatRoomsInitial extends ChatRoomsState {
  const ChatRoomsInitial();
}

final class ChatRoomsLoading extends ChatRoomsState {
  const ChatRoomsLoading();
}

final class ChatRoomsLoaded extends ChatRoomsState {
  final List<ChatRoomApiModel> rooms;
  final bool hasMore;
  final int currentPage;
  const ChatRoomsLoaded({
    required this.rooms,
    required this.hasMore,
    required this.currentPage,
  });
}

final class ChatRoomsError extends ChatRoomsState {
  final String message;
  const ChatRoomsError(this.message);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class ChatRoomsCubit extends Cubit<ChatRoomsState> {
  ChatRoomsCubit() : super(const ChatRoomsInitial());

  Future<void> loadRooms({bool refresh = false}) async {
    if (state is ChatRoomsLoading) return;
    emit(const ChatRoomsLoading());

    final result = await sl.chat.getConversations(page: 1);
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        emit(
          ChatRoomsLoaded(
            rooms: data.data,
            hasMore: data.hasNextPage,
            currentPage: data.currentPage,
          ),
        );
      case Failure(:final exception):
        emit(ChatRoomsError(exception.message));
    }
  }

  Future<void> loadMoreRooms() async {
    final current = state;
    if (current is! ChatRoomsLoaded || !current.hasMore) return;

    final result = await sl.chat.getConversations(
      page: current.currentPage + 1,
    );
    if (isClosed) return;

    if (result case Success(:final data)) {
      emit(
        ChatRoomsLoaded(
          rooms: [...current.rooms, ...data.data],
          hasMore: data.hasNextPage,
          currentPage: data.currentPage,
        ),
      );
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// CHAT CUBIT  (single room / message screen)
// ═════════════════════════════════════════════════════════════════════════════

// ─── States ───────────────────────────────────────────────────────────────────

sealed class ChatState {
  const ChatState();
}

final class ChatInitial extends ChatState {
  const ChatInitial();
}

final class ChatLoading extends ChatState {
  const ChatLoading();
}

final class ChatLoaded extends ChatState {
  final ChatRoomApiModel room;
  final List<ChatMessageApiModel> messages;
  final bool hasMoreMessages;
  final int currentPage;
  final bool isSending;
  const ChatLoaded({
    required this.room,
    required this.messages,
    required this.hasMoreMessages,
    required this.currentPage,
    this.isSending = false,
  });

  ChatLoaded copyWith({
    ChatRoomApiModel? room,
    List<ChatMessageApiModel>? messages,
    bool? hasMoreMessages,
    int? currentPage,
    bool? isSending,
  }) => ChatLoaded(
    room: room ?? this.room,
    messages: messages ?? this.messages,
    hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
    currentPage: currentPage ?? this.currentPage,
    isSending: isSending ?? this.isSending,
  );
}

final class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
}

final class ChatMessageSendFailed extends ChatState {
  final List<ChatMessageApiModel> messages;
  final ChatRoomApiModel room;
  final String error;
  const ChatMessageSendFailed({
    required this.messages,
    required this.room,
    required this.error,
  });
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatInitial());

  Timer? _pollTimer;
  int? _currentRoomId;

  // ─── Load room + messages ──────────────────────────────────────────────────

  Future<void> loadRoom(int roomId) async {
    _currentRoomId = roomId;
    emit(const ChatLoading());

    final roomResult = await sl.chat.getConversationById(roomId);
    if (isClosed) return;

    if (roomResult case Failure(:final exception)) {
      emit(ChatError(exception.message));
      return;
    }

    final room = (roomResult as Success<ChatRoomApiModel>).data;

    final msgResult = await sl.chat.getMessages(roomId, page: 1);
    if (isClosed) return;

    switch (msgResult) {
      case Success(:final data):
        // Messages from API are newest-first; reverse for natural display.
        final messages = data.data.reversed.toList();
        emit(
          ChatLoaded(
            room: room,
            messages: messages,
            hasMoreMessages: data.hasNextPage,
            currentPage: data.currentPage,
          ),
        );
        // Mark as read after loading.
        sl.chat.markAsRead(roomId);
        // Start polling for new messages.
        _startPolling(roomId);
      case Failure(:final exception):
        emit(ChatError(exception.message));
    }
  }

  // ─── Load older messages ───────────────────────────────────────────────────

  Future<void> loadOlderMessages() async {
    final current = state;
    if (current is! ChatLoaded || !current.hasMoreMessages) return;

    final roomId = _currentRoomId;
    if (roomId == null) return;

    final result = await sl.chat.getMessages(
      roomId,
      page: current.currentPage + 1,
    );
    if (isClosed) return;

    if (result case Success(:final data)) {
      final older = data.data.reversed.toList();
      emit(
        current.copyWith(
          messages: [...older, ...current.messages],
          hasMoreMessages: data.hasNextPage,
          currentPage: data.currentPage,
        ),
      );
    }
  }

  // ─── Send message ──────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    final current = state;
    if (current is! ChatLoaded || text.trim().isEmpty) return;

    emit(current.copyWith(isSending: true));

    final result = await sl.chat.sendMessage(
      current.room.id,
      message: text.trim(),
    );
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        emit(
          current.copyWith(
            messages: [...current.messages, data],
            isSending: false,
          ),
        );
        sl.chat.markAsRead(current.room.id);
      case Failure(:final exception):
        emit(
          ChatMessageSendFailed(
            messages: current.messages,
            room: current.room,
            error: exception.message,
          ),
        );
    }
  }

  // ─── Polling ───────────────────────────────────────────────────────────────

  void _startPolling(int roomId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _pollNewMessages(roomId);
    });
  }

  Future<void> _pollNewMessages(int roomId) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    int lastMessageId = current.messages.firstOrNull?.id ?? 0;
    final result = await sl.chat.checkNewMessages(roomId, lastMessageId);
    if (isClosed) return;

    if (result case Success<List<ChatMessageApiModel>>(
      :final data,
    ) when data.isNotEmpty) {
      final current = state;

      if (current is! ChatLoaded) return;

      final existingIds = current.messages.map((m) => m.id).toSet();
      final newMsgs = data.where((m) => !existingIds.contains(m.id)).toList();
      if (newMsgs.isNotEmpty) {
        emit(current.copyWith(messages: [...current.messages, ...newMsgs]));
        sl.chat.markAsRead(roomId);
      }
    }
  }

  // ─── Restore from send-failed ──────────────────────────────────────────────

  void retryAfterError() {
    final current = state;
    if (current is ChatMessageSendFailed) {
      emit(
        ChatLoaded(
          room: current.room,
          messages: current.messages,
          hasMoreMessages: false,
          currentPage: 1,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
