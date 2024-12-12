import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bar Wave Music Visualizer',
      theme: ThemeData.dark(),
      home: MusicVisualizer(),
    );
  }
}

class MusicVisualizer extends StatefulWidget {
  @override
  _MusicVisualizerState createState() => _MusicVisualizerState();
}

class _MusicVisualizerState extends State<MusicVisualizer>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setAsset('assets/sample_music.mp3'); // Add your music file to assets
    _audioPlayer.play();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _playPauseAudio() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
      _animationController.stop();
    } else {
      await _audioPlayer.play();
      _animationController.repeat();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bar Wave Music Visualizer"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CustomPaint(
              size: const Size(300, 150), // Adjust size for visualization
              painter: BarWaveVisualizerPainter(_animationController),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _playPauseAudio,
            icon: Icon(
              _audioPlayer.playing ? Icons.pause : Icons.play_arrow,
            ),
            label: Text(_audioPlayer.playing ? "Pause" : "Play"),
          ),
        ],
      ),
    );
  }
}

class BarWaveVisualizerPainter extends CustomPainter {
  final Animation<double> animation;

  BarWaveVisualizerPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    final double barWidth = 10;
    final double spacing = 15;
    final int numberOfBars = (size.width / spacing).floor();

    final List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
    ];

    for (int i = 0; i < numberOfBars; i++) {
      final double barHeight = size.height * (0.3 + 0.7 * random.nextDouble() * sin((animation.value + i) * 2 * pi));
      final double x = i * spacing;
      final double y = size.height - barHeight;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(5),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
