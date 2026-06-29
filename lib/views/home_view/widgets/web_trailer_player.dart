// Web-only trailer player using youtube_player_iframe.
// Mobil tarafta youtube_player_flutter kullanıldığı için bu widget yalnızca
// kIsWeb true iken (movie_detail_view içinde) çağrılır.

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class WebTrailerPlayer extends StatefulWidget {
  final String videoId;
  const WebTrailerPlayer({super.key, required this.videoId});

  @override
  State<WebTrailerPlayer> createState() => _WebTrailerPlayerState();
}

class _WebTrailerPlayerState extends State<WebTrailerPlayer> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(controller: _controller),
      ),
    );
  }
}
