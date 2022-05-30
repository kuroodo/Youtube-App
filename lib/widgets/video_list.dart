import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_youtube_clone/models/playlist_model.dart';
import 'package:my_youtube_clone/models/video_model.dart';
import 'package:my_youtube_clone/widgets/video_card.dart';

class VideoList extends ConsumerWidget {
  final Playlist playlist;
  final bool isLoading;
  final Function(Video)? onTap;
  const VideoList(
      {Key? key, required this.playlist, required this.isLoading, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Add videos first
          if (index != playlist.videos.length) {
            return VideoCard(video: playlist.videos[index], onTap: onTap);
          }

          // Add progress indicator or empty box at end after all videos added
          if (isLoading) {
            return const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return const SizedBox();
          }
        },
        childCount: playlist.videos.length + 1,
      ),
    );
  }
}
