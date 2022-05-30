import 'package:flutter/material.dart';
import 'package:iso_duration_parser/iso_duration_parser.dart';
import 'package:my_youtube_clone/models/video_model.dart';
import 'package:my_youtube_clone/utilities/format_string_number.dart';
import "package:timeago/timeago.dart" as timeago;
import "package:flutter_riverpod/flutter_riverpod.dart";

class VideoCard extends ConsumerWidget {
  final Video video;
  final bool hasPadding;
  final Function(Video)? onTap;
  const VideoCard(
      {Key? key, required this.video, this.hasPadding = false, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    IsoDuration? duration = IsoDuration.tryParse(video.duration);
    return GestureDetector(
      onTap: () {
        if (onTap != null) onTap!(video);
      },
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: hasPadding ? 12.0 : 0),
                child: Image.network(
                  video.thumbnailUrl,
                  height: 220.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 8.0,
                right: hasPadding ? 20.0 : 8.0,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  color: video.videoType == VideoType.live
                      ? Colors.red
                      : Colors.black,
                  child: Text(
                    duration == null
                        ? video.duration
                        : duration.hours > 0
                            ? duration.format("{hh}:{mm}:{ss}")
                            : duration.format("{mm}:{ss}"),
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(color: Colors.white, fontSize: 12),
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 12, right: 4, top: 14, bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              // Ensures right icon is pushed all way to the edge
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => print("Navigate to profile"),
                  child: CircleAvatar(
                    foregroundImage: NetworkImage(
                      video.channel.profilePictureUrl,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    // MainAxisSize.min Ensures vertical (cause column) size is as small as possible
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontSize: 14.0, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Flexible(
                        child: Text(
                          "${video.channel.title} • ${FormatStringNumber.compact(video.viewCount)} views • ${timeago.format(video.publishedAt)}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(fontSize: 12.0, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                // Using GestureDetector instead of IconButton because IconButton has extra padding which we don't want
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.more_vert, size: 20.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
