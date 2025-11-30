import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pokapon/main.dart';

double UIheight = 70;
final double power = 50;
final double maxLifeConstant = 150;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MoveGame game;

  @override
  void initState() {
    super.initState();
    game = MoveGame(context: context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double maxLife = size.width / 2 - maxLifeConstant;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'damageA':
                  (context, gameInstance) => Positioned(
                    left: 10,
                    top: 5,
                    child: ValueListenableBuilder<int>(
                      valueListenable: this.game.countA,
                      builder:
                          (context, value, _) =>
                              DamageCounterA(count: value, maxLife: maxLife),
                    ),
                  ),
              'damageB':
                  (context, gameInstance) => Positioned(
                    right: 10,
                    top: 5,
                    child: ValueListenableBuilder<int>(
                      valueListenable: this.game.countB,
                      builder:
                          (context, value, _) =>
                              DamageCounterB(count: value, maxLife: maxLife),
                    ),
                  ),
              "timer":
                  (context, gameInstance) => Align(
                    alignment: Alignment.topCenter,
                    child: ValueListenableBuilder<String>(
                      valueListenable: this.game.timer,
                      builder: (context, value, _) => TimerText(timer: value),
                    ),
                  ),
            },
            backgroundBuilder: (context) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/back.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DamageCounterA extends StatelessWidget {
  const DamageCounterA({super.key, required this.count, required this.maxLife});
  final double maxLife;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxLife,
      height: 50,
      child: Stack(
        children: [
          Container(width: maxLife, height: 50, color: Colors.red),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: count <= maxLife / power ? maxLife - power * count : 0,
              height: 50,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void paint(Canvas canvas, Size size) {}
}

class DamageCounterB extends StatelessWidget {
  const DamageCounterB({super.key, required this.count, required this.maxLife});
  final double maxLife;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxLife,
      height: 50,
      child: Stack(
        children: [
          Container(width: maxLife, height: 50, color: Colors.red),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: count <= maxLife / power ? maxLife - power * count : 0,
              height: 50,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({super.key, required this.timer});
  final String timer;

  @override
  Widget build(BuildContext context) {
    return Text(timer, style: TextStyle(color: Colors.black, fontSize: 50));
  }
}
