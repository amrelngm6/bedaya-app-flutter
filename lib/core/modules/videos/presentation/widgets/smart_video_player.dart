import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../theme/colors.dart';
import '../../models/video_model.dart';

/// Plays a video from any of the supported sources (YouTube or direct
/// upload url), choosing the right underlying player based on the url.
class SmartVideoPlayer extends StatefulWidget {
  const SmartVideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = true,
    this.looping = false,
    this.onPlayingChanged,
    this.onReady,
  });

  /// Raw video url (YouTube link of any format, or a direct video file url).
  final String videoUrl;
  final bool autoPlay;
  final bool looping;
  final void Function(bool isPlaying)? onPlayingChanged;
  final VoidCallback? onReady;

  @override
  State<SmartVideoPlayer> createState() => SmartVideoPlayerState();
}

class SmartVideoPlayerState extends State<SmartVideoPlayer> {
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  bool _isInitialized = false;

  bool get isYoutube => VideoUrlUtils.isYoutubeUrl(widget.videoUrl);
  bool get isInitialized => _isInitialized;

  bool get isPlaying => isYoutube
      ? _youtubeController?.value.playerState == PlayerState.playing
      : (_videoController?.value.isPlaying ?? false);

  double get aspectRatio => _videoController?.value.isInitialized == true
      ? _videoController!.value.aspectRatio
      : 16 / 9;

  Duration get position => _videoController?.value.position ?? Duration.zero;
  Duration get duration => _videoController?.value.duration ?? Duration.zero;

  VideoPlayerController? get rawVideoController => _videoController;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    if (isYoutube) {
      final videoId = VideoUrlUtils.extractYoutubeId(widget.videoUrl) ?? '';
      _youtubeController = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: widget.autoPlay,
        params: const YoutubePlayerParams(showFullscreenButton: true),
      )..stream.listen(_onYoutubeUpdate);
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onReady?.call(),
      );
    } else {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      _videoController = controller;
      controller.initialize().then((_) {
        if (!mounted) return;
        controller.setLooping(widget.looping);
        if (widget.autoPlay) controller.play();
        setState(() => _isInitialized = true);
        widget.onReady?.call();
      });
      controller.addListener(_onVideoUpdate);
    }
  }

  void _onYoutubeUpdate(YoutubePlayerValue value) {
    if (!mounted) return;
    setState(() {});
    widget.onPlayingChanged?.call(value.playerState == PlayerState.playing);
  }

  void _onVideoUpdate() {
    if (!mounted) return;
    setState(() {});
    widget.onPlayingChanged?.call(isPlaying);
  }

  void play() {
    if (isYoutube) {
      _youtubeController?.playVideo();
    } else {
      _videoController?.play();
    }
  }

  void pause() {
    if (isYoutube) {
      _youtubeController?.pauseVideo();
    } else {
      _videoController?.pause();
    }
  }

  void togglePlayPause() => isPlaying ? pause() : play();

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoUpdate);
    _videoController?.dispose();
    _youtubeController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isYoutube) {
      // AbsorbPointer (not IgnorePointer) so this area still registers as a
      // hit for the ancestor GestureDetector/PageView, but the touch never
      // reaches the webview itself (which otherwise swallows drags as its
      // own hold-to-speed-up gesture and blocks reel paging/tap-to-pause).
      return AbsorbPointer(
        // child: AspectRatio(
        //   aspectRatio: .6,
        child: YoutubePlayer(
          controller: _youtubeController!,
          aspectRatio: 0.7,
          autoFullScreen: true,
          autoHideDuration: const Duration(seconds: 1),
          enableFullScreenOnVerticalDrag: false,
          keepAlive: false,
        ),
        // ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryTeal),
      );
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: VideoPlayer(_videoController!),
    );
  }
}
