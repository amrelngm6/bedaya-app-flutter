// ─────────────────────────────────────────────────────────────────────────────
// Chat – domain models (mirrors ClientChatRoomResource & ClientMessageResource)
// ─────────────────────────────────────────────────────────────────────────────

// ── Sender ───────────────────────────────────────────────────────────────────

class ChatSenderModel {
  const ChatSenderModel({
    required this.id,
    required this.type,
    required this.name,
    required this.isStaff,
    this.avatar,
  });

  final int id;
  final String type;
  final String name;
  final bool isStaff;
  final String? avatar;

  factory ChatSenderModel.fromJson(Map<String, dynamic> json) =>
      ChatSenderModel(
        id: json['id'] as int? ?? 0,
        type: json['type'] as String? ?? '',
        name: json['name'] as String? ?? '',
        isStaff: json['is_staff'] as bool? ?? false,
        avatar: json['avatar'] as String?,
      );
}

// ── Attached file ─────────────────────────────────────────────────────────────

class ChatMessageFileModel {
  const ChatMessageFileModel({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
  });

  final int id;
  final String name;
  final String url;
  final String type;
  final int size;

  factory ChatMessageFileModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageFileModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        url: json['url'] as String? ?? '',
        type: json['type'] as String? ?? '',
        size: json['size'] as int? ?? 0,
      );

  bool get isImage =>
      type.startsWith('image/') ||
      name.toLowerCase().endsWith('.jpg') ||
      name.toLowerCase().endsWith('.jpeg') ||
      name.toLowerCase().endsWith('.png') ||
      name.toLowerCase().endsWith('.gif') ||
      name.toLowerCase().endsWith('.webp');
}

// ── Message ───────────────────────────────────────────────────────────────────

class ChatMessageApiModel {
  const ChatMessageApiModel({
    required this.id,
    required this.roomId,
    required this.message,
    required this.type,
    required this.sender,
    required this.isOwnMessage,
    required this.createdAt,
    this.files = const [],
    this.sentAt,
    this.seenAt,
  });

  final int id;
  final int roomId;
  final String message;

  /// 'text' | 'image' | 'file' | 'audio' | 'video'
  final String type;
  final ChatSenderModel sender;
  final bool isOwnMessage;
  final List<ChatMessageFileModel> files;
  final String? sentAt;
  final String? seenAt;
  final String createdAt;

  bool get isSeen => seenAt != null;
  bool get hasFiles => files.isNotEmpty;

  DateTime? get parsedSentAt {
    try {
      return sentAt != null ? DateTime.parse(sentAt!) : null;
    } catch (_) {
      return null;
    }
  }

  factory ChatMessageApiModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageApiModel(
        id: json['id'] as int? ?? 0,
        roomId: json['room_id'] as int? ?? 0,
        message: json['message'] as String? ?? '',
        type: json['type'] as String? ?? 'text',
        sender: ChatSenderModel.fromJson(
          json['sender'] as Map<String, dynamic>? ?? {},
        ),
        isOwnMessage: json['is_own_message'] as bool? ?? false,
        files:
            (json['files'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map(ChatMessageFileModel.fromJson)
                .toList() ??
            [],
        sentAt: json['sent_at'] as String?,
        seenAt: json['seen_at'] as String?,
        createdAt: json['created_at'] as String? ?? '',
      );
}

// ── Room ──────────────────────────────────────────────────────────────────────

class ChatRoomApiModel {
  const ChatRoomApiModel({
    required this.id,
    required this.name,
    required this.unreadCount,
    required this.participantsCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
  });

  final int id;
  final String name;
  final ChatMessageApiModel? lastMessage;
  final int unreadCount;
  final int participantsCount;
  final String createdAt;
  final String updatedAt;

  bool get hasUnread => unreadCount > 0;

  factory ChatRoomApiModel.fromJson(Map<String, dynamic> json) =>
      ChatRoomApiModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        lastMessage: json['last_message'] != null
            ? ChatMessageApiModel.fromJson(
                json['last_message'] as Map<String, dynamic>,
              )
            : null,
        unreadCount: json['unread_count'] as int? ?? 0,
        participantsCount: json['participants_count'] as int? ?? 0,
        createdAt: json['created_at'] as String? ?? '',
        updatedAt: json['updated_at'] as String? ?? '',
      );
}

// ── Unread summary ────────────────────────────────────────────────────────────

class ChatUnreadCountModel {
  const ChatUnreadCountModel({required this.unreadCount});

  final int unreadCount;

  factory ChatUnreadCountModel.fromJson(Map<String, dynamic> json) =>
      ChatUnreadCountModel(unreadCount: json['unread_count'] as int? ?? 0);
}
