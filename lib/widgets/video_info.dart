import 'package:flutter/material.dart';
import 'package:my_youtube_clone/models/channel_model.dart';
import 'package:my_youtube_clone/models/video_model.dart';
import 'package:my_youtube_clone/utilities/format_string_number.dart';
import "package:timeago/timeago.dart" as timeago;

class VideoInfo extends StatelessWidget {
  final Video video;
  const VideoInfo({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video.title,
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(fontSize: 16.0, height: 1.5),
          ),
          const SizedBox(height: 6.0),
          Text(
            "${FormatStringNumber.withCommas(video.viewCount)} views • ${timeago.format(video.publishedAt)}",
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(fontSize: 13.0, color: Colors.grey),
          ),
          const Divider(),
          _ActionsRow(video: video),
          const Divider(),
          _AutherInfo(user: video.channel),
          const Divider(),
        ],
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final Video video;
  const _ActionsRow({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildAction(context, Icons.thumb_up_outlined,
            FormatStringNumber.compact(video.likeCount)),
        _buildAction(context, Icons.thumb_down_outlined,
            FormatStringNumber.compact(video.dislikeCount)),
        _buildAction(context, Icons.reply_outlined, "Share"),
      ],
    );
  }

  Widget _buildAction(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: Theme.of(context).textTheme.caption!.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }
}

class _AutherInfo extends StatelessWidget {
  final Channel user;
  const _AutherInfo({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print("Navigate to profile"),
      child: Row(
        children: [
          CircleAvatar(foregroundImage: NetworkImage(user.profilePictureUrl)),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              // MainAxisSize.min Ensures vertical (cause column) size is as small as possible
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    user.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 16.0),
                  ),
                ),
                Flexible(
                  child: Text(
                      "${FormatStringNumber.compact(user.subscriberCount)} subscribers",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(fontSize: 15.0)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => print("Subscribe"),
            child: Text(
              "SUBSCRIBE",
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Colors.red,
                    fontSize: 16,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
