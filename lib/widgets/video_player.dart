import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:my_youtube_clone/models/playlist_model.dart';
import 'package:my_youtube_clone/providers/video_controller_manager.dart';
import 'package:my_youtube_clone/models/video_model.dart';
import 'package:my_youtube_clone/screens/nav_screen.dart';
import 'package:my_youtube_clone/services/api_services.dart';
import 'package:my_youtube_clone/widgets/video_list.dart';
import 'package:my_youtube_clone/screens/video_screen.dart';
import "package:youtube_player_flutter/youtube_player_flutter.dart";
import 'package:my_youtube_clone/widgets/video_info.dart';

final vidControllerManagerNotifier =
    ChangeNotifierProvider<VideoControllerManager>(
        (ref) => VideoControllerManager());

final progressBarColorsProvider = Provider<ProgressBarColors?>(
  (ref) => ProgressBarColors(
    backgroundColor: Colors.red[900],
    bufferedColor: Colors.redAccent,
    playedColor: Colors.red,
    handleColor: Colors.red,
  ),
);

class VideoPlayer extends ConsumerStatefulWidget {
  final Video video;
  const VideoPlayer({Key? key, required this.video}) : super(key: key);

  @override
  ConsumerState<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends ConsumerState<VideoPlayer> {
  bool _isPlayerReady = false;
  bool _muted = false;

  @override
  void dispose() {
    ref.invalidate(vidControllerManagerNotifier);
    ref.invalidate(relatedPlaylistProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProgressBarColors? progressBarColors =
        ref.read(progressBarColorsProvider);
    VideoControllerManager videoManager =
        ref.watch(vidControllerManagerNotifier);
    if (!videoManager.hasController()) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: () => ref
          .read(miniPlayerControllerProvider.state)
          .state
          .animateToHeight(state: PanelState.MAX),
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: videoManager.videoController!,
          progressColors: progressBarColors,
          onReady: () {
            setState(() {
              _isPlayerReady = true;
            });
          },
          topActions: [
            const SizedBox(width: 8.0),
            IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 30.0,
              ),
              onPressed: () => ref
                  .read(miniPlayerControllerProvider.state)
                  .state
                  .animateToHeight(state: PanelState.MIN),
            ),
          ],
          bottomActions: [
            IconButton(
              icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
              onPressed: _isPlayerReady
                  ? () {
                      _muted
                          ? videoManager.videoController!.unMute()
                          : videoManager.videoController!.mute();
                      setState(() {
                        _muted = !_muted;
                      });
                    }
                  : null,
            ),
            Expanded(
              child: ProgressBar(
                controller: videoManager.videoController,
                colors: progressBarColors,
              ),
            ),
            FullScreenButton(
              controller: videoManager.videoController,
              color: Colors.white,
            ),
          ],
        ),
        builder: (context, player) => Column(
          children: [
            SafeArea(child: player),
            Expanded(child: VideoContent(video: widget.video))
          ],
        ),
      ),
    );
  }
}

class VideoContent extends ConsumerStatefulWidget {
  final Video video;

  const VideoContent({Key? key, required this.video}) : super(key: key);

  @override
  ConsumerState<VideoContent> createState() => _VideoContentState();
}

class _VideoContentState extends ConsumerState<VideoContent> {
  late final ScrollController _scrollController;
  bool _isLoadingMoreVideos = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  void _loadMoreVideos() async {
    setState(() {
      _isLoadingMoreVideos = true;
    });

    String videoId = ref.read(selectedVideoProvider)!.id;

    await ref
        .read(relatedPlaylistProvider.notifier)
        .loadMoreVideos(fetchType: FetchType.related, query: videoId);

    setState(() {
      _isLoadingMoreVideos = false;
    });
  }

  bool _onScrollNotification(
      {required ScrollNotification scrollDetails, required Playlist playlist}) {
    // If no more videos to load
    if (playlist.videos.length == playlist.totalYoutubeVideos) {
      return false;
    }
    // If reached the bottom of the page
    if (scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent) {
      _loadMoreVideos();
    }
    return false;
  }

  void _onVideoSelected(Video video) {
    _scrollController.jumpTo(0);

    ref.read(selectedVideoProvider.state).state = video;

    ref.read(vidControllerManagerNotifier).loadVideo(video.id);

    ref.read(relatedPlaylistProvider.notifier).fetchRelatedVideos(
          videoId: video.id,
          nextPageToken: "",
        );
  }

  @override
  Widget build(BuildContext context) {
    final relatedPlaylist = ref.watch(relatedPlaylistProvider);

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollDetails) {
        // Don't do anything if currently loading or playlist is empty
        if (_isLoadingMoreVideos ||
            relatedPlaylist.isLoading ||
            !relatedPlaylist.hasValue) return true;

        _onScrollNotification(
          scrollDetails: scrollDetails,
          playlist: relatedPlaylist.value!,
        );
        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: VideoInfo(video: widget.video)),
          relatedPlaylist.unwrapPrevious().when(
              error: (error, stackTrace) => SliverPadding(
                    padding: const EdgeInsets.only(top: 20),
                    sliver: SliverToBoxAdapter(child: Text(error as String)),
                  ),
              loading: () =>
                  _isLoadingMoreVideos && relatedPlaylist.value != null
                      ? buildVideoList(playlist: relatedPlaylist.value!)
                      : const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        ),
              data: (playlist) => playlist.videos.isEmpty
                  ? const SliverPadding(
                      padding: EdgeInsets.only(top: 20),
                      sliver: SliverToBoxAdapter(
                        child: Center(child: Text("No Videos Found")),
                      ),
                    )
                  : buildVideoList(playlist: playlist)),
        ],
      ),
    );
  }

  Widget buildVideoList({required Playlist playlist}) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 60.0),
      sliver: VideoList(
        playlist: playlist,
        isLoading: _isLoadingMoreVideos,
        onTap: _onVideoSelected,
      ),
    );
  }
}
