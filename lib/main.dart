import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bar Wave TTS Visualizer',
      theme: ThemeData.dark(),
      home: TextToSpeechVisualizer(),
    );
  }
}

class TextToSpeechVisualizer extends StatefulWidget {
  @override
  _TextToSpeechVisualizerState createState() => _TextToSpeechVisualizerState();
}

class _TextToSpeechVisualizerState extends State<TextToSpeechVisualizer>
    with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  late AnimationController _animationController;
  bool _isSpeaking = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _speakText() async {
    final text = _textController.text;
    if (text.isNotEmpty) {
      setState(() => _isSpeaking = true);

      _animationController.repeat();
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);

      // Stop animation when TTS completes
      _flutterTts.setCompletionHandler(() {
        setState(() {
          _isSpeaking = false;
          _animationController.stop();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bar Wave TTS Visualizer"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter text to speak',
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: CustomPaint(
                size: const Size(300, 150),
                painter: BarWaveVisualizerPainter(_animationController),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isSpeaking ? null : _speakText,
              icon: Icon(_isSpeaking ? Icons.mic_off : Icons.mic),
              label: Text(_isSpeaking ? "Speaking..." : "Speak"),
            ),
          ],
        ),
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
