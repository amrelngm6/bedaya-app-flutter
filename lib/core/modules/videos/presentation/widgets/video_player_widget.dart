import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';
import '../../models/video_model.dart';
import 'smart_video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  final GlobalKey<SmartVideoPlayerState> _playerKey =
      GlobalKey<SmartVideoPlayerState>();
  bool _showControls = true;

  bool get _isYoutube => VideoUrlUtils.isYoutubeUrl(widget.videoUrl);

  void _togglePlayPause() {
    setState(() => _playerKey.currentState?.togglePlayPause());
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: AppStyles.h3.copyWith(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // YouTube videos rely on their own native controls; direct uploads use
      // the custom overlay controls below.
      body: _isYoutube
          ? Center(
              child: SmartVideoPlayer(
                key: _playerKey,
                videoUrl: widget.videoUrl,
              ),
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
                Future.delayed(const Duration(seconds: 3), () {
                  final player = _playerKey.currentState;
                  if (mounted && (player?.isPlaying ?? false)) {
                    setState(() {
                      _showControls = false;
                    });
                  }
                });
              },
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SmartVideoPlayer(
                      key: _playerKey,
                      videoUrl: widget.videoUrl,
                    ),
                    if (_showControls) _buildControls(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildControls() {
    final player = _playerKey.currentState;
    final controller = player?.rawVideoController;
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Play/Pause button
            Center(
              child: IconButton(
                iconSize: 64,
                icon: Icon(
                  (player?.isPlaying ?? false)
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                ),
                onPressed: _togglePlayPause,
              ),
            ),
            const Spacer(),
            // Progress bar
            if (controller != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.primaryTeal,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(player!.position),
                          style: AppStyles.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _formatDuration(player.duration),
                          style: AppStyles.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
