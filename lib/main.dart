import 'dart:math';
import 'dart:async' as async;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pokapon/body.dart';
import 'package:pokapon/resultScreen.dart';
import 'package:pokapon/screen.dart';
import 'package:pokapon/startScreen.dart';
import 'package:flame_audio/flame_audio.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: StartScreen()));
}

class MoveGame extends FlameGame with KeyboardEvents {
  final BuildContext? context;
  MoveGame({this.context});
  late RectangleComponent playerA;
  late RectangleComponent playerB;
  late double positionY;
  ValueNotifier<int> countA = ValueNotifier(0);
  ValueNotifier<int> countB = ValueNotifier(0);
  Vector2 directionA = Vector2.zero();
  Vector2 directionB = Vector2.zero();
  late double lifeA;
  late double lifeB;
  ValueNotifier<String> timer = ValueNotifier("2:00");
  async.Timer? _countdownTimer;
  int _remainingSeconds = 120;
  final double speed = 800;
  final double attackCooldown = 0.8;
  double lastAttackTimeA = -999;
  double lastAttackTimeB = -999;

  // キー押下状態保持用
  final Set<LogicalKeyboardKey> _keysPressed = {};

  void damageA() {
    countA.value++;
    FlameAudio.play('panti.mp3');
    if (countA.value >= (size.x / 2 - maxLifeConstant) / power) {
      gameEnd("プレイヤーB");
    }
  }

  void damageB() {
    countB.value++;
    FlameAudio.play('panti.mp3');
    if (countB.value >= (size.x / 2 - maxLifeConstant) / power) {
      gameEnd("プレイヤーA");
    }
  }

  void isDamage(String attacker) {
    final posA = playerA.position;
    final posB = playerB.position;
    final distance = posA.distanceTo(posB);

    if (distance < 450 && distance > 200) {
      if (attacker == "A") {
        damageB();
      } else if (attacker == "B") {
        damageA();
      }
    }
  }

  void gameEnd(String winner) {
    // タイマーを完全に停止
    _countdownTimer?.cancel();
    _countdownTimer = null;

    if (context == null) return;
    Navigator.of(context!).push(
      MaterialPageRoute(builder: (context) => ResultScreen(winner: winner)),
    );
  }

  @override
  Future<void> onLoad() async {
    double WIDTH = 1000;
    positionY = size.y - 450;
    print('画面サイズ: $size');
    playerA = RectangleComponent(
      children: [
        RPSComponent(rotation: true, size: Vector2(WIDTH, WIDTH * 0.5)),
      ],
    );
    playerB = RectangleComponent(
      children: [
        RPSComponent(rotation: false, size: Vector2(WIDTH, WIDTH * 0.5)),
      ],
    );
    add(playerA);
    add(playerB);
    playerA.position = Vector2(size.x * 1 / 4, positionY);
    playerB.position = Vector2(size.x * 3 / 4, positionY);
    overlays.add('damageA');
    overlays.add('damageB');
    overlays.add("timer");

    // タイマーセット
    _remainingSeconds = 120;
    timer.value = _formatTime(_remainingSeconds);
    _countdownTimer?.cancel();
    _countdownTimer = async.Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        this.timer.value = _formatTime(_remainingSeconds);
      } else {
        if (countA.value > countB.value) {
          gameEnd("タイムアップ!\nプレイヤーA");
        } else if (countA.value < countB.value) {
          gameEnd("タイムアップ!\nプレイヤーB");
        } else {
          gameEnd("タイムアップ!\n引き分け");
        }
        timer.cancel();
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    if (!isLoaded) return;

    if (children.contains(playerA)) {
      playerA.position = Vector2(canvasSize.x * 1 / 4, positionY);
    }
    if (children.contains(playerB)) {
      playerB.position = Vector2(canvasSize.x * 3 / 4, positionY);
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      _keysPressed.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _keysPressed.remove(event.logicalKey);
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

    // PlayerA 攻撃
    if (_keysPressed.contains(LogicalKeyboardKey.digit1)) {
      if (currentTime - lastAttackTimeA >= attackCooldown) {
        lastAttackTimeA = currentTime;
        (playerA.children.first as RPSComponent).setStateFromKey(1);
        isDamage("A");
      }
    }

    // PlayerB 攻撃
    if (_keysPressed.contains(LogicalKeyboardKey.digit2)) {
      if (currentTime - lastAttackTimeB >= attackCooldown) {
        lastAttackTimeB = currentTime;
        (playerB.children.first as RPSComponent).setStateFromKey(2);
        isDamage("B");
      }
    }

    // 移動方向更新
    directionA.x = 0;
    if (_keysPressed.contains(LogicalKeyboardKey.arrowLeft)) directionA.x = -1;
    if (_keysPressed.contains(LogicalKeyboardKey.arrowRight)) directionA.x = 1;

    directionB.x = 0;
    if (_keysPressed.contains(LogicalKeyboardKey.keyA)) directionB.x = -1;
    if (_keysPressed.contains(LogicalKeyboardKey.keyD)) directionB.x = 1;

    return KeyEventResult.handled;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // playerA の移動
    playerA.position += directionA * speed * dt;
    playerA.position.x = playerA.position.x.clamp(0, size.x - 200);

    // playerB の移動
    playerB.position += directionB * speed * dt;
    playerB.position.x = playerB.position.x.clamp(0, size.x - 200);
  }
}

class RPSComponent extends PositionComponent {
  late Paint paint;
  late double progress;
  final bool rotation;
  late double origin = 0;
  int state = 0; // 0: default, 1: attack, 2: attack
  RPSComponent({required this.rotation, super.size}) {
    paint = Paint()..color = Colors.blue;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    origin = rotation ? 0 : 360;
    progress = origin;
  }

  // キー入力で状態を変更する関数
  void setStateFromKey(int newState) {
    state = newState;
    progress = origin; // アニメーションを最初から再生
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (state == 0) {
      // 初期角度に固定
      progress = rotation ? 315 : 45;
      return;
    }

    double speed = 350; // deg/s

    if (rotation) {
      // 正回転（playerA）
      progress += speed * dt;
      if (progress >= 60) {
        // 上限
        progress = 60;
        state = 0; // 回転終了
      }
    } else {
      // 逆回転（playerB）
      progress -= speed * dt;
      if (progress <= 300) {
        // 下限
        progress = 300;
        state = 0; // 回転終了
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (size.x <= 0 || size.y <= 0) return;

    final double x = cos(progress * pi / 180);
    final double y = sin(progress * pi / 180);

    // canvas.drawRect(rect, _paint);
    final painter = RPSCustomPainter(x, y, progress, rotation);
    painter.paint(canvas, Size(size.x, size.y));
  }
}
