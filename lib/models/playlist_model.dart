import 'package:my_youtube_clone/models/channel_model.dart';
import 'package:my_youtube_clone/models/video_model.dart';

enum PlayListType {
  trending,
  related,
  channel,
}

class Playlist {
  final Channel? channel;
  List<Video> videos;

  /// The amount of videos existing in youtube database
  ///
  /// This is not the length of the [videos] list
  int totalYoutubeVideos;
  String nextPageToken;

  Playlist({
    this.videos = const [],
    this.channel,
    this.nextPageToken = "",
    this.totalYoutubeVideos = 0,
  }) {
    _sortVideos();
  }

  void _sortVideos() {
    videos.sort((vid1, vid2) {
      if (vid1.videoType == VideoType.upcoming &&
          vid2.videoType == VideoType.live) {
        return 1;
      }

      if ((vid2.videoType == VideoType.live ||
              vid2.videoType == VideoType.upcoming) &&
          vid1.videoType == VideoType.video) {
        return 1;
      }

      return 0;
    });
  }

  void setVideos(List<Video> v, {bool sort = false}) {
    videos = v;
    if (sort) _sortVideos();
  }

  void addVideos(List<Video> v, {bool sort = false}) {
    videos.addAll(v);
    if (sort) _sortVideos();
  }

  void addVideo(Video v, {bool sort = false}) {
    videos.add(v);
    if (sort) _sortVideos();
  }
}
