import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class VideoDetailModal extends StatefulWidget {
  final AssetEntity video;

  const VideoDetailModal({
    required this.video,
  });

  @override
  State<VideoDetailModal> createState() => _VideoDetailModalState();
}

class _VideoDetailModalState extends State<VideoDetailModal> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _isLoadingVideo = false;

  @override
  void initState() {
    super.initState();
    // Auto-initialize video when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideo();
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    if (_isVideoInitialized || _isLoadingVideo) return;

    setState(() => _isLoadingVideo = true);

    try {
      final file = await widget.video.file;
      if (file == null) {
        setState(() => _isLoadingVideo = false);
        return;
      }

      _videoController = VideoPlayerController.file(file);
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: false,
        showControls: true,
        showOptions: false,
        allowPlaybackSpeedChanging: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: CupertinoColors.activeBlue,
          handleColor: CupertinoColors.activeBlue,
          backgroundColor: CupertinoColors.systemGrey4,
          bufferedColor: CupertinoColors.systemGrey5,
        ),
      );

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isLoadingVideo = false;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() => _isLoadingVideo = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = 16.0; // Sağdan ve soldan padding

    // Video aspect ratio'yu hesapla
    final videoAspectRatio = widget.video.width / widget.video.height;
    final availableWidth = screenWidth - (horizontalPadding * 2);
    final availableHeight = screenHeight * 0.8;

    // Video boyutlarını hesapla
    double videoWidth;
    double videoHeight;

    if (availableWidth / videoAspectRatio <= availableHeight) {
      // Width'e göre boyutlandır
      videoWidth = availableWidth;
      videoHeight = videoWidth / videoAspectRatio;
    } else {
      // Height'e göre boyutlandır
      videoHeight = availableHeight;
      videoWidth = videoHeight * videoAspectRatio;
    }

    return Stack(
      children: [
        // Arka plan overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ),
        // Video popup
        Builder(builder: (context) {
          if (!(_isVideoInitialized && _chewieController != null)) {
            return const Center(child: CupertinoActivityIndicator());
          }
          return Center(
            child: Container(
              width: videoWidth,
              height: videoHeight,
              decoration: BoxDecoration(
                color: CupertinoColors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Video Player
                    _isVideoInitialized && _chewieController != null ? Chewie(controller: _chewieController!) : SizedBox(),
                    // Close button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.xmark,
                            color: CupertinoColors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
