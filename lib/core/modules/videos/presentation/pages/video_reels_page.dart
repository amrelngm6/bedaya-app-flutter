import 'package:bedaya2/core/modules/auth/presentation/pages/login_page.dart';
import 'package:bedaya2/core/modules/auth/presentation/pages/register_page.dart';
import 'package:bedaya2/core/modules/bookings/presentation/widgets/auth_required_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/videos/models/video_model.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Video Reels Page  –  full-screen vertical-scroll video feed
// ─────────────────────────────────────────────────────────────────────────────
List<Map<String, dynamic>> commentsList = [];

class VideoReelsPage extends StatefulWidget {
  final int initialIndex;

  const VideoReelsPage({super.key, this.initialIndex = 0});

  @override
  State<VideoReelsPage> createState() => _VideoReelsPageState();
}

class _VideoReelsPageState extends State<VideoReelsPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<VideoApiModel> _videos = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _fetchVideos();
    sl.analytics.trackScreen(
      'VideoReelsPage - Initial Index: ${widget.initialIndex}',
    );
  }

  Future<void> _fetchVideos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await sl.videos.getVideos(page: 1);

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _videos
            ..clear()
            ..addAll(data.data);
          _currentPage = 1;
          _hasMore = data.hasNextPage;
          _isLoading = false;
        });
      case Failure(:final exception):
        setState(() {
          _errorMessage = exception.message;
          _isLoading = false;
        });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    final result = await sl.videos.getVideos(page: _currentPage + 1);

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _videos.addAll(data.data);
          _currentPage++;
          _hasMore = data.hasNextPage;
          _isLoadingMore = false;
        });
      case Failure():
        setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              const Center(
                child: CircularProgressIndicator(color: AppColors.primaryTeal),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null && _videos.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white54,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          style: AppStyles.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _fetchVideos,
                        icon: const Icon(Icons.refresh),
                        label: Text('retry'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videos.length + (_isLoadingMore ? 1 : 0),
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
          if (index >= _videos.length - 2) _loadMore();
        },
        itemBuilder: (context, index) {
          if (index >= _videos.length) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryTeal),
            );
          }
          return VideoReelItem(
            videoItem: _videos[index],
            isCurrentPage: index == _currentIndex,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single video reel item
// ─────────────────────────────────────────────────────────────────────────────

class VideoReelItem extends StatefulWidget {
  final VideoApiModel videoItem;
  final bool isCurrentPage;

  const VideoReelItem({
    super.key,
    required this.videoItem,
    required this.isCurrentPage,
  });

  @override
  State<VideoReelItem> createState() => _VideoReelItemState();
}

class _VideoReelItemState extends State<VideoReelItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  late bool _isLiked;
  late int _likesCount;
  bool _showControls = false;
  bool _descriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.videoItem.isLikedByMe;
    _likesCount = widget.videoItem.likesCount;
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoItem.videoUrl),
    );

    try {
      await _controller.initialize();
      _controller.setLooping(true);

      if (mounted) {
        setState(() => _isInitialized = true);
        if (widget.isCurrentPage) _controller.play();
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(VideoReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentPage && !oldWidget.isCurrentPage) {
      _controller.play();
    } else if (!widget.isCurrentPage && oldWidget.isCurrentPage) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Controls ──────────────────────────────────────────────────────────────

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _showControls = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleLike() async {
    sl.analytics.trackTap(
      'like_button_tap',
      screenName:
          '${!_isLiked ? "Liked" : "Unliked"} Video - ${widget.videoItem.title}',
    );
    if (!sl.storage.isLoggedIn) {
      _checkAuthAndProceed(back: false);
      if (!sl.storage.isLoggedIn) return;
      return;
    }
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    sl.videos.toggleLike(widget.videoItem.id);
  }

  void _checkAuthAndProceed({bool? back = false}) {
    if (!sl.storage.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAuthModal(back: back);
      });
    }
  }

  Future<void> _showAuthModal({bool? back = false}) async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (sheetCtx) => AuthRequiredSheet(
        onNavigateToLogin: () async {
          await Navigator.push(
            sheetCtx,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
          if (sl.storage.isLoggedIn && sheetCtx.mounted) {
            Navigator.pop(sheetCtx);
          }
        },
        onNavigateToRegister: () async {
          await Navigator.push(
            sheetCtx,
            MaterialPageRoute(builder: (_) => const RegisterPage()),
          );
          if (sl.storage.isLoggedIn && sheetCtx.mounted) {
            Navigator.pop(sheetCtx);
          }
        },
        onGoBack: () {
          Navigator.pop(sheetCtx);
          if (mounted && back == true) Navigator.pop(context);
        },
      ),
    );

    // If the modal was closed without authenticating, leave the booking page.
    if (mounted && !sl.storage.isLoggedIn && back == true) {
      Navigator.pop(context);
    }
  }

  void _showCommentsSheet() async {
    // Load the comments
    final result = await sl.videos.getComments(widget.videoItem.id);
    if (!mounted) return;

    switch (result) {
      case Success():
        setState(() {
          commentsList = result.data;
        });
        break; // Comments will be loaded inside the sheet
      case Failure(:final exception):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exception.message),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
    }

    // Pause the video while comments are open
    _controller.pause();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(
        videoId: widget.videoItem.id,
        commentsCount: widget.videoItem.commentsCount,
      ),
    ).then((_) {
      if (widget.isCurrentPage && mounted) _controller.play();
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Video player ──────────────────────────────────────────────
          if (_isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          else
            _buildLoadingPlaceholder(),

          // ── Gradient overlay ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Top bar ───────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.videoItem.viewsCount}',
                            style: AppStyles.bodySmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Right-side action buttons ─────────────────────────────────
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                // Like
                _buildActionButton(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '$_likesCount',
                  onTap: _toggleLike,
                  color: _isLiked ? Colors.red : Colors.white,
                ),
                const SizedBox(height: 24),

                // Comments
                _buildActionButton(
                  icon: Icons.comment,
                  label: '${widget.videoItem.commentsCount}',
                  onTap: _showCommentsSheet,
                ),
                const SizedBox(height: 24),

                // // Share
                // _buildActionButton(
                //   icon: Icons.share,
                //   label: 'share'.tr(),
                //   onTap: () {},
                // ),
              ],
            ),
          ),

          // ── Bottom info (title + description) ─────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 80,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Channel avatar + name
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                            'https://cdn-icons-png.flaticon.com/512/3063/3063205.png',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'bedaya_hospital'.tr(),
                          style: AppStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      widget.videoItem.title,
                      style: AppStyles.h3.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Description with read more / less
                    GestureDetector(
                      onTap: () => setState(
                        () => _descriptionExpanded = !_descriptionExpanded,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.videoItem.description,
                            style: AppStyles.bodyMedium.copyWith(
                              color: Colors.white70,
                            ),
                            maxLines: _descriptionExpanded ? null : 2,
                            overflow: _descriptionExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                          ),
                          if (widget.videoItem.description.length > 80)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _descriptionExpanded
                                    ? 'read_less'.tr()
                                    : 'read_more'.tr(),
                                style: AppStyles.bodySmall.copyWith(
                                  color: AppColors.primaryTeal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Play / Pause overlay ──────────────────────────────────────
          if (_showControls && _isInitialized)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    final thumbnail = widget.videoItem.thumbnailUrl;
    if (thumbnail != null && thumbnail.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(thumbnail, fit: BoxFit.cover),
          const Center(
            child: CircularProgressIndicator(color: AppColors.primaryTeal),
          ),
        ],
      );
    }
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryTeal),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Comments bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CommentsSheet extends StatefulWidget {
  final int videoId;
  final int commentsCount;

  const _CommentsSheet({required this.videoId, required this.commentsCount});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final bool isLoggedIn = sl.storage.isLoggedIn;
  late String userAvatar;

  @override
  void initState() {
    super.initState();
    setUser();
  }

  void setUser() async {
    final user = await sl.storage.getUser();
    setState(() {
      userAvatar =
          user?.avatar ??
          'https://cdn-icons-png.flaticon.com/512/3063/3063205.png';
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitComment() async {
    // Show alert with sending the comment
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sending comment...'.tr()),
        backgroundColor: AppColors.primaryTeal,
      ),
    );

    final result = await sl.videos.addComment(
      widget.videoId,
      _commentController.text.trim(),
    );

    switch (result) {
      case Success(:final data):
        final text = _commentController.text.trim();
        if (text.isEmpty) return;
        _commentController.clear();
        _focusNode.unfocus();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'].tr()),
            backgroundColor: AppColors.primaryTeal,
          ),
        );

      // Optionally, you can also show a success message or update the comments list immediately.
      case Failure(:final exception):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exception.message),
            backgroundColor: Colors.red.shade700,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Handle ──────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'comments'.tr(),
                  style: AppStyles.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.commentsCount}',
                    style: AppStyles.bodySmall.copyWith(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 24),

          // ── Comments list ────────────────────────────────────────────
          Expanded(
            child: widget.commentsCount == 0
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white24,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'no_comments_yet'.tr(),
                          style: AppStyles.bodyMedium.copyWith(
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.commentsCount,
                    itemBuilder: (_, index) =>
                        _CommentPlaceholderTile(index: index),
                  ),
          ),

          // ── Comment input ────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 50 + bottomInset),
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2E),
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(userAvatar),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _focusNode,
                    style: AppStyles.bodyMedium.copyWith(color: Colors.white),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submitComment(),
                    decoration: InputDecoration(
                      hintText: 'add_comment'.tr(),
                      hintStyle: AppStyles.bodyMedium.copyWith(
                        color: Colors.white38,
                      ),
                      filled: true,
                      fillColor: Colors.white10,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _submitComment,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton tile shown while real comments are not yet loaded from the API
// ─────────────────────────────────────────────────────────────────────────────

class _CommentPlaceholderTile extends StatelessWidget {
  final int index;

  const _CommentPlaceholderTile({required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white12,
            child: Icon(Icons.person, color: Colors.white38, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commentsList[index]['user_name'] ?? 'User'.tr(),
                  style: AppStyles.bodyMedium.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),

                Text(
                  commentsList[index]['message'] ?? 'Message'.tr(),
                  style: AppStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
