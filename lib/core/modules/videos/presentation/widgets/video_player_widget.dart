import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';

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
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });

      _controller.addListener(() {
        setState(() {});
      });
    } catch (e) {
      // Handle video initialization errors
      return;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
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
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && _controller.value.isPlaying) {
              setState(() {
                _showControls = false;
              });
            }
          });
        },
        child: Center(
          child: _isInitialized
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    if (_showControls) _buildControls(),
                  ],
                )
              : const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryTeal,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildControls() {
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
                  _controller.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                ),
                onPressed: _togglePlayPause,
              ),
            ),
            const Spacer(),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  VideoProgressIndicator(
                    _controller,
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
                        _formatDuration(_controller.value.position),
                        style: AppStyles.bodySmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _formatDuration(_controller.value.duration),
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
