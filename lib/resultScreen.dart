import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokapon/startScreen.dart';
import 'package:confetti/confetti.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.winner});
  final String winner;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final FocusNode _focusNode = FocusNode();
  final controller = ConfettiController(
    duration: const Duration(milliseconds: 500),
  );

  bool _hasNavigated = false;
  bool _isReady = false; // ← 入力受付フラグ

  @override
  void initState() {
    super.initState();

    // 紙吹雪スタート
    controller.play();

    // 5秒待ってから入力を有効化
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _focusNode.requestFocus();
        setState(() {
          _isReady = true; // ← 入力受付OKに
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) {
        // ⚠️ まだ待機中ならキー入力を無視
        if (!_isReady) return;

        if (event is KeyDownEvent && !_hasNavigated) {
          _hasNavigated = true;
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StartScreen()),
            );
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: ConfettiWidget(
                confettiController: controller,
                numberOfParticles: 50,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: true,
                maxBlastForce: 100,
                minBlastForce: 20,
                emissionFrequency: 0.05,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: controller,
                numberOfParticles: 10,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: true,
                maxBlastForce: 70,
                minBlastForce: 20,
                emissionFrequency: 0.05,
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: ConfettiWidget(
                confettiController: controller,
                numberOfParticles: 50,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: true,
                maxBlastForce: 100,
                minBlastForce: 20,
                emissionFrequency: 0.05,
              ),
            ),
            Center(
              child:
                  widget.winner != "引き分け"
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Winner", style: TextStyle(fontSize: 80)),
                          const SizedBox(height: 10),
                          Text(
                            widget.winner,
                            style: TextStyle(
                              fontSize: 80,
                              color:
                                  widget.winner == "プレイヤーA"
                                      ? Colors.red
                                      : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 50),
                          Text(
                            _isReady ? "Start" : "Please Wait...",
                            style: const TextStyle(fontSize: 30),
                          ),
                        ],
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("引き分け", style: TextStyle(fontSize: 80)),
                          const SizedBox(height: 50),
                          Text(
                            _isReady ? "Start" : "Please Wait...",
                            style: const TextStyle(fontSize: 30),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
