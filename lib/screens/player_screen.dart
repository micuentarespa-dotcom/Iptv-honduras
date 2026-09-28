import 'package:flutter/material';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class PlayerScreen extends StatefulWidget {
  final UserModel user;
  final String streamTitle;
  final String streamId;
  final String type; // 'live', 'movie', 'series'

  const PlayerScreen({
    super.key,
    required this.user,
    required this.streamTitle,
    required this.streamId,
    required this.type,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    // Construir la URL proxy del backend
    final streamUrl = '${ApiService.baseUrl}/${widget.type}/${widget.user.username}/***/${widget.streamId}.ts';

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(streamUrl));
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: widget.type == 'live',
        aspectRatio: 16 / 9,
        allowFullScreen: true,
        fullScreenByDefault: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error al reproducir el canal: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No se pudo conectar al proxy de reproducción: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.streamTitle),
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(color: Colors.blueAccent),
                  SizedBox(height: 15),
                  Text('Conectando al proxy HD IPTV Honduras...', style: TextStyle(color: Colors.white70)),
                ],
              )
            : _errorMessage != null
                ? Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
                        const SizedBox(height: 10),
                        Text(_errorMessage!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Volver al Menú'),
                        ),
                      ],
                    ),
                  )
                : Chewie(controller: _chewieController!),
      ),
    );
  }
}
