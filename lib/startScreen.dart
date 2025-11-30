import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokapon/screen.dart';
// import 'next_screen.dart'; // Import your next screen here

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final FocusNode _focusNode = FocusNode();
  bool _hasNavigated = false;
  bool _isReady = false; // ← キー入力を受け付けるかどうか

  @override
  void initState() {
    super.initState();

    // 数秒待ってからフォーカスを当て、入力を有効化
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _focusNode.requestFocus();
        setState(() {
          _isReady = true; // ← 入力受付OKにする
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        // 🔒 まだ準備ができていないなら無視
        if (!_isReady) return;

        if (event is KeyDownEvent && !_hasNavigated) {
          _hasNavigated = true;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GameScreen()),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    "assets/images/gazou.jpg",
                    fit: BoxFit.cover, // 画面全体に拡大・トリミングして表示
                  ),
                ),
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     const Text("戦え！みんなのロボット", style: TextStyle(fontSize: 80)),
                //     const SizedBox(height: 50),
                //     Text(
                //       _isReady ? "Press Any Key" : "Now Loading...",
                //       style: const TextStyle(fontSize: 30),
                //     ),
                //   ],
                // ),
                Align(
                  alignment: Alignment(0, 0.8),
                  child: Text(
                    _isReady ? "Start" : "Now Loading...",
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
