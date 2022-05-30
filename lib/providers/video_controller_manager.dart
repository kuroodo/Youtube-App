import 'package:flutter/cupertino.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoControllerManager extends ChangeNotifier {
  YoutubePlayerController? _videoController;
  bool _isPlaying = false;

  YoutubePlayerController? get videoController {
    return _videoController;
  }

  bool get isPlaying {
    return _isPlaying;
  }

  void play() {
    if (hasController()) {
      _videoController!.play();
    }
  }

  void pause() {
    if (hasController()) {
      _videoController!.pause();
    }
  }

  void loadVideo(String videoId) {
    if (hasController()) {
      videoController!.load(videoId);
    } else {
      _setController(YoutubePlayerController(initialVideoId: videoId));
    }

    notifyListeners();
  }

  void disposeController() {
    if (hasController()) {
      _videoController!.dispose();
      _videoController = null;
    }
  }

  bool hasController() {
    return _videoController != null;
  }

  void _setController(YoutubePlayerController controller) {
    controller.addListener(() {
      if (controller.value.isPlaying != _isPlaying) {
        _isPlaying = controller.value.isPlaying;
        notifyListeners();
      }
    });

    _videoController = controller;
    notifyListeners();
  }
}
