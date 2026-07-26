import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/modules/chat/models/chat_room_model.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/network/paginated_response.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Chat API Service
// ─────────────────────────────────────────────────────────────────────────────

class ChatService extends BaseApiService {
  const ChatService(super.client);

  // ─── Conversations (rooms) ────────────────────────────────────────────────

  /// Returns a paginated list of support conversations for the current user.
  Future<NetworkResult<PaginatedResponse<ChatRoomApiModel>>> getConversations({
    int page = 1,
    int perPage = AppConfig.defaultPageSize,
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.chatConversations,
      queryParameters: {'page': page, 'per_page': perPage},
    );

    final body = response.data!;
    final dataNode = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;
    final rawList = (dataNode['rooms']) as List<dynamic>;
    final pagination = dataNode['pagination'] as Map<String, dynamic>? ?? {};

    return PaginatedResponse(
      data: rawList
          .whereType<Map<String, dynamic>>()
          .map(ChatRoomApiModel.fromJson)
          .toList(),
      currentPage: pagination['current_page'] as int? ?? page,
      lastPage: pagination['last_page'] as int? ?? 1,
      perPage: pagination['per_page'] as int? ?? perPage,
      total: pagination['total'] as int? ?? rawList.length,
      from: pagination['from'] as int?,
      to: pagination['to'] as int?,
    );
  });

  /// Returns the details of a single conversation.
  Future<NetworkResult<ChatRoomApiModel>> getConversationById(int id) =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.chatConversationById(id),
        );
        return ChatRoomApiModel.fromJson(_dataOf(response.data!));
      });

  // ─── Messages ─────────────────────────────────────────────────────────────

  /// Returns a paginated list of messages for a conversation.
  Future<NetworkResult<PaginatedResponse<ChatMessageApiModel>>> getMessages(
    int roomId, {
    int page = 1,
    int perPage = 30,
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.chatConversationMessages(roomId),
      queryParameters: {'page': page, 'per_page': perPage},
    );

    final body = response.data!;
    final dataNode = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;
    final rawList =
        (dataNode['messages'] ?? dataNode['data'] ?? []) as List<dynamic>;
    final pagination = dataNode['pagination'] as Map<String, dynamic>? ?? {};

    return PaginatedResponse(
      data: rawList
          .whereType<Map<String, dynamic>>()
          .map(ChatMessageApiModel.fromJson)
          .toList(),
      currentPage: pagination['current_page'] as int? ?? page,
      lastPage: pagination['last_page'] as int? ?? 1,
      perPage: pagination['per_page'] as int? ?? perPage,
      total: pagination['total'] as int? ?? rawList.length,
      from: pagination['from'] as int?,
      to: pagination['to'] as int?,
    );
  });

  /// Simply creates a new empty conversation. In a real app, you might want to
  /// allow user to enter initial message, select topic, etc. For demo purposes,
  Future<NetworkResult<ChatRoomApiModel>> createConversation({
    String subject = '',
    String initialMessage = '',
  }) => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.chatConversations,
      data: {'subject': subject, 'message': initialMessage},
    );
    return ChatRoomApiModel.fromJson(_dataOf(response.data!));
  });

  /// Sends a text message to a conversation.
  Future<NetworkResult<ChatMessageApiModel>> sendMessage(
    int roomId, {
    required String message,
    String type = 'text',
  }) => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.chatConversationMessages(roomId),
      data: {'message': message, 'type': type},
    );
    return ChatMessageApiModel.fromJson(_dataOf(response.data!));
  });

  /// Polls for new messages since the last known message.
  Future<NetworkResult<List<ChatMessageApiModel>>> checkNewMessages(
    int roomId,
    int lastMessageId,
  ) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.checkNewMessages(roomId, lastMessageId),
    );
    final body = response.data!;
    final rawList =
        (body['data']?['new_messages'] ?? body['new_messages'] ?? [])
            as List<dynamic>;
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(ChatMessageApiModel.fromJson)
        .toList();
  });

  /// Marks all messages in a conversation as read.
  Future<NetworkResult<void>> markAsRead(int roomId) => execute(() async {
    await dio.post<void>(ApiEndpoints.setMessagesRead(roomId));
  });

  /// Returns the total unread messages count across all conversations.
  Future<NetworkResult<int>> getUnreadCount() => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.unredMessagesCount,
    );
    final body = response.data!;
    return (body['data']?['unread_count'] ?? body['unread_count'] ?? 0) as int;
  });

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _dataOf(Map<String, dynamic> json) =>
      json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
}
