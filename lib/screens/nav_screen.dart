import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_youtube_clone/models/playlist_model.dart';
import 'package:my_youtube_clone/models/video_model.dart';
import 'package:my_youtube_clone/providers/playlist_provider.dart';
import 'package:my_youtube_clone/screens/home_screen.dart';
import 'package:my_youtube_clone/screens/video_screen.dart';

final currentPlaylistProvider =
    StateNotifierProvider<PlaylistProvider, AsyncValue<Playlist>>(
        (ref) => PlaylistProvider(PlayListType.trending));
final relatedPlaylistProvider =
    StateNotifierProvider<PlaylistProvider, AsyncValue<Playlist>>(
        (ref) => PlaylistProvider(PlayListType.related));
final selectedVideoProvider = StateProvider<Video?>((ref) => null);

class NavScreen extends ConsumerWidget {
  const NavScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      body: Stack(
        children: const [
          HomeScreen(),
          VideoScreen(),
        ],
      ),
    );
  }
}
