import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:my_youtube_clone/providers/video_controller_manager.dart';
import 'package:my_youtube_clone/models/video_model.dart';
import 'package:my_youtube_clone/screens/nav_screen.dart';
import 'package:my_youtube_clone/widgets/video_player.dart';
import 'package:my_youtube_clone/widgets/video_progress_bar.dart';

final miniPlayerControllerProvider =
    StateProvider.autoDispose<MiniplayerController>(
        (ref) => MiniplayerController());

class VideoScreen extends ConsumerWidget {
  const VideoScreen({Key? key}) : super(key: key);

  final double _playerMinHeight = 60.0;

  @override
  Widget build(BuildContext context, ref) {
    final selectedVideo = ref.watch<Video?>(selectedVideoProvider);
    final miniPlayerController =
        ref.watch<MiniplayerController>(miniPlayerControllerProvider);

    return Offstage(
      offstage: selectedVideo == null,
      child: Miniplayer(
        controller: miniPlayerController,
        minHeight: _playerMinHeight,
        maxHeight: MediaQuery.of(context).size.height,
        builder: (height, percentage) {
          if (selectedVideo == null) {
            return const SizedBox.shrink();
          }

          return Stack(
            children: [
              Offstage(
                offstage: height > _playerMinHeight + 50.0,
                child: MiniPlayerBody(
                  playerMinHeight: _playerMinHeight,
                  selectedVideo: selectedVideo,
                ),
              ),
              Offstage(
                offstage: height < _playerMinHeight + 50.0,
                child: VideoPlayer(video: selectedVideo),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MiniPlayerBody extends ConsumerWidget {
  final Video selectedVideo;
  final double playerMinHeight;
  const MiniPlayerBody(
      {Key? key, required this.selectedVideo, required this.playerMinHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    VideoControllerManager videoManager =
        ref.watch(vidControllerManagerNotifier);
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          children: [
            Row(
              children: [
                // - 4.0 because otherwise the thumbnail has an overflow error of 4 pixels
                Image.network(
                  selectedVideo.thumbnailUrl,
                  height: playerMinHeight - 4.0,
                  width: 120.0,
                  fit: BoxFit.cover,
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      // Ensure vertical size is as small as possible to avoid overflow
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            selectedVideo.title,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.caption!.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            selectedVideo.channel.title,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.caption!.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: videoManager.hasController() && videoManager.isPlaying
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.play_arrow),
                  onPressed: () => videoManager.isPlaying
                      ? videoManager.pause()
                      : videoManager.play(),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // Remove the current video and releated videos
                    ref.invalidate(selectedVideoProvider);
                    ref.invalidate(relatedPlaylistProvider);
                  },
                ),
              ],
            ),
            if (videoManager.hasController())
              VideoProgressBar(
                controller: videoManager.videoController,
                isExpanded: true,
                colors: ref.read(progressBarColorsProvider),
              ),
          ],
        ),
      ),
    );
  }
}
