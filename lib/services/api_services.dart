import "dart:convert";
import 'dart:developer';
import "dart:io";
import "package:http/http.dart" as http;
import 'package:my_youtube_clone/models/channel_model.dart';
import 'package:my_youtube_clone/models/playlist_model.dart';
import 'package:my_youtube_clone/utilities/keys.dart';
import 'package:my_youtube_clone/utilities/fetch_result.dart';

import '../models/video_model.dart';

enum FetchType { trending, search, related }

class APIServices {
  APIServices._instantiate();

  static final APIServices instance = APIServices._instantiate();

  final String _baseUrl = "www.googleapis.com";

  Future<FetchResult> fetchQuery(String query,
      {bool isRelatedVideos = false, String nextPageToken = ""}) async {
    List<Channel>? foundChannels;
    List<Video>? foundVideos;

    Map<String, String> parameters;
    if (isRelatedVideos) {
      parameters = {
        "part": "id, snippet",
        "relatedToVideoId": query,
        "pageToken": nextPageToken,
        "type": "video",
        "key": API_KEY,
      };
    } else {
      parameters = {
        "part": "id, snippet",
        "q": query,
        "pageToken": nextPageToken,
        "key": API_KEY,
      };
    }

    Uri uri = Uri.https(
      _baseUrl,
      "/youtube/v3/search",
      parameters,
    );

    // Get the data back as json
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json"
    };

    http.Response response;
    try {
      // Contact the API and await response
      response = await _getAPIResponse(uri, headers);
    } catch (e, stacktrace) {
      log("${e.toString()}\n${stacktrace.toString()}");
      return Future.error(e, stacktrace);
    }

    var jsonData = json.decode(response.body);
    nextPageToken = jsonData["nextPageToken"] ?? nextPageToken;

    List result = jsonData["items"];
    List<dynamic> channels = [];
    List<dynamic> videos = [];
    for (int i = 0; i < result.length; i++) {
      if (result[i]["id"]["kind"] == "youtube#channel") {
        channels.add(result[i]);
      } else if (result[i]["id"]["kind"] == "youtube#video") {
        videos.add(result[i]);
      }
    }

    // Get channels
    if (channels.isNotEmpty) {
      List<String> channelIds = List.generate(
        channels.length,
        (index) => channels[index]["id"]["channelId"],
      );

      List<Channel> channelsFound =
          await _fetchChannels(_idsAsString(channelIds));
      foundChannels = channelsFound;
    }

    // Get videos
    if (videos.isNotEmpty) {
      List<String> videoIds = List.generate(
        videos.length,
        (index) => videos[index]["id"]["videoId"],
      );

      List<Video> videosFound = await _fetchVideos(_idsAsString(videoIds));
      foundVideos = videosFound;
    }

    return FetchResult(
      videos: foundVideos ?? [],
      channels: foundChannels ?? [],
      nextPageToken: nextPageToken,
      videoCount: jsonData["pageInfo"]["totalResults"],
    );
  }

  Future<FetchResult> fetchMoreVideos({
    required String nextPageToken,
    required FetchType fetchType,
    String query = "",
  }) async {
    switch (fetchType) {
      case FetchType.search:
        FetchResult result =
            await fetchQuery(query, nextPageToken: nextPageToken);
        return FetchResult(
          videos: result.videos,
          nextPageToken: result.nextPageToken,
          videoCount: result.videoCount,
        );
      case FetchType.trending:
        Playlist result = await fetchTrending(nextPageToken: nextPageToken);
        return FetchResult(
          videos: result.videos,
          nextPageToken: result.nextPageToken,
          videoCount: result.totalYoutubeVideos,
        );
      case FetchType.related:
        FetchResult result = await fetchQuery(query,
            nextPageToken: nextPageToken, isRelatedVideos: true);
        return FetchResult(
          videos: result.videos,
          nextPageToken: result.nextPageToken,
          videoCount: result.videoCount,
        );
    }
  }

  Future<Playlist> fetchTrending({String nextPageToken = ""}) async {
    Map<String, String> parameters = {
      "part": "id, snippet, contentDetails, statistics",
      "chart": "mostPopular",
      "pageToken": nextPageToken,
      "key": API_KEY,
    };

    Uri uri = Uri.https(
      _baseUrl,
      "/youtube/v3/videos",
      parameters,
    );

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json"
    };

    http.Response response;
    try {
      response = await _getAPIResponse(uri, headers);
    } catch (e, stacktrace) {
      log("${e.toString()}\n${stacktrace.toString()}");
      return Future.error(e, stacktrace);
    }
    var jsonData = json.decode(response.body);
    nextPageToken = jsonData["nextPageToken"] ?? nextPageToken;

    List data = jsonData["items"];

    List<String> chanIds = List.generate(
      data.length,
      (index) => data[index]["snippet"]["channelId"],
    );

    List<Channel> channels = await _fetchChannels(_idsAsString(chanIds));

    List<Video> videos = List.generate(
      data.length,
      (index) => Video.videoFromMap(
        data[index],
        channels.firstWhere(
          (ch) => ch.id == data[index]["snippet"]["channelId"],
        ),
      ),
    );

    return Playlist(
      videos: videos,
      totalYoutubeVideos: jsonData["pageInfo"]["totalResults"],
      nextPageToken: nextPageToken,
    );
  }

  Future<List<Video>> _fetchVideos(String videoIds) async {
    Map<String, String> parameters = {
      "part": "id, snippet, contentDetails, statistics",
      "id": videoIds,
      "key": API_KEY,
    };

    Uri uri = Uri.https(
      _baseUrl,
      "/youtube/v3/videos",
      parameters,
    );

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json"
    };

    http.Response response;
    try {
      response = await _getAPIResponse(uri, headers);
    } catch (e, stacktrace) {
      log("${e.toString()}\n${stacktrace.toString()}");
      return Future.error(e, stacktrace);
    }
    List data = json.decode(response.body)["items"];

    if (data.isEmpty) {
      return [];
    }

    List<String> chanIds = List.generate(
      data.length,
      (index) => data[index]["snippet"]["channelId"],
    );
    List<Channel> channels = await _fetchChannels(_idsAsString(chanIds));

    List<Video> videos = List.generate(
      data.length,
      (index) => Video.videoFromMap(
        data[index],
        channels.firstWhere(
          (ch) => ch.id == data[index]["snippet"]["channelId"],
        ),
      ),
    );

    return videos;
  }

  Future<http.Response> _getAPIResponse(
      Uri uri, Map<String, String> headers) async {
    http.Response response;
    try {
      // Contact the API and await response
      response = await http.get(uri, headers: headers);
    } catch (e, stacktrace) {
      log("${e.toString()}\n${stacktrace.toString()}");
      return Future.error(e, stacktrace);
    }

    if (response.statusCode == 200) {
      return response;
    } else {
      throw json.decode(response.body)["error"]["message"];
    }
  }

  Future<List<Channel>> _fetchChannels(String channelIds) async {
    Map<String, String> parameters = {
      "part": "id, snippet, contentDetails, statistics",
      "id": channelIds,
      "key": API_KEY,
    };

    Uri uri = Uri.https(
      _baseUrl,
      "/youtube/v3/channels",
      parameters,
    );

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json"
    };

    http.Response response;
    try {
      response = await _getAPIResponse(uri, headers);
    } catch (e, stacktrace) {
      log("${e.toString()}\n${stacktrace.toString()}");
      return Future.error(e, stacktrace);
    }
    List data = json.decode(response.body)["items"];
    List<Channel> channels = List.generate(
      data.length,
      (index) => Channel.channelFromMap(data[index]),
    );

    return channels;
  }

  String _idsAsString(List<String> ids) {
    String result = "";
    for (int i = 0; i < ids.length; i++) {
      result += ids[i];
      if (i != ids.length - 1) {
        result += ",";
      }
    }
    return result;
  }
}
