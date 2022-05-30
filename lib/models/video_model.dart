import 'package:my_youtube_clone/models/channel_model.dart';

enum VideoType { video, live, upcoming }

class Video {
  final String id;
  final String title;
  final String thumbnailUrl;
  final DateTime publishedAt;
  final String duration;
  final String viewCount;
  final String likeCount;
  final String dislikeCount = "0";
  final Channel channel;
  final VideoType videoType;

  Video({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.publishedAt,
    required this.duration,
    required this.viewCount,
    required this.likeCount,
    required this.channel,
    required this.videoType,
  });

  static Video videoFromMap(Map<String, dynamic> videoData, Channel channel) {
    String vidDuration = videoData["contentDetails"]["duration"];
    String broadcastContent = videoData["snippet"]["liveBroadcastContent"];
    VideoType type = VideoType.video;

    if (broadcastContent == "live") {
      type = VideoType.live;
      vidDuration = "LIVE";
    } else if (broadcastContent == "upcoming") {
      type = VideoType.upcoming;
      vidDuration = "UPCOMING";
    }

    return Video(
      id: videoData["id"],
      title: videoData["snippet"]["title"],
      thumbnailUrl: videoData["snippet"]["thumbnails"]["high"]["url"],
      publishedAt: DateTime.parse(videoData["snippet"]["publishedAt"]),
      duration: vidDuration,
      viewCount: videoData["statistics"]["viewCount"],
      likeCount: videoData["statistics"]["likeCount"] ?? "Likes Disabled",
      channel: channel,
      videoType: type,
    );
  }
}
