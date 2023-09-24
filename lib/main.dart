import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(TamagotchiApp());
}

class TamagotchiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamagotchi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TamagotchiScreen(),
    );
  }
}

class TamagotchiScreen extends StatefulWidget {
  @override
  _TamagotchiScreenState createState() => _TamagotchiScreenState();
}

class _TamagotchiScreenState extends State<TamagotchiScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<String> tamagotchiFrames = [
    '''
   /~~\\
  |oo  |
  | >< |
   \\__/
    ''',
    '''
   /~~\\
  |--  |
  | >< |
   \\__/
    ''',
  ];

  List<String> tamagotchiFrameDead = [
    '''
   /~~\\
  |xx  |
  | >< |
   \\__/
    ''',
  ];

  List<String> tamagotchiEatingFrames = [
    '''
   /~~\\
  |oo  |
  | >w<|
   \\__/
    ''',
  ];

  List<String> tamagotchiHappyFrames = [
    '''
   /~~\\
  |^^  |
  | >< |
   \\__/
    ''',
  ];

  int currentFrameIndex = 0;
  int hungerLevel = 9;
  int happinessLevel = 5;

  late Timer _hungerTimer;
  late Timer _happinessTimer;

  bool isDead = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.repeat(reverse: true);
    animateFrames();
    startHungerTimer();
    startHappinessTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _hungerTimer.cancel();
    _happinessTimer.cancel();
    super.dispose();
  }

  void animateFrames() async {
    while (true) {
      if (!isDead) {
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          currentFrameIndex = (currentFrameIndex + 1) % tamagotchiFrames.length;
        });
      } else {
        break; // Salir del bucle si está muerto
      }
    }
  }

  void startHungerTimer() {
    _hungerTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        if (!isDead && hungerLevel > 0) {
          hungerLevel--;
          if (hungerLevel == 0 && happinessLevel == 0) {
            isDead = true;
            _animationController.stop();
          }
        }
      });
    });
  }

  void startHappinessTimer() {
    _happinessTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        if (!isDead && happinessLevel > 0) {
          happinessLevel--;
          if (hungerLevel == 0 && happinessLevel == 0) {
            isDead = true;
            _animationController.stop();
          }
        }
      });
    });
  }

  void hungerfeedTamagotchi() {
    var defaultFrames = tamagotchiFrames[0];
    var defaultFramesTwo = tamagotchiFrames[1];

    setState(() {
      if (!isDead) {
        hungerLevel += 10;
        if (hungerLevel > 100) hungerLevel = 100;
        currentFrameIndex = 0; // Reiniciar al primer frame después de comer
        tamagotchiFrames.clear();
        tamagotchiFrames.addAll(tamagotchiEatingFrames);
        _animationController.stop();
      }
    });

    Timer(const Duration(seconds: 2), () {
      setState(() {
        tamagotchiFrames.clear();
        tamagotchiFrames.addAll([defaultFrames, defaultFramesTwo]);
        _animationController.repeat(reverse: true);
      });
    });
  }

  void happyfeedTamagotchi() {
    var defaultFrames = tamagotchiFrames[0];
    var defaultFramesTwo = tamagotchiFrames[1];

    setState(() {
      if (!isDead) {
        happinessLevel += 10;
        if (happinessLevel > 100) happinessLevel = 100;
        currentFrameIndex = 0; // Reiniciar al primer frame después de comer
        tamagotchiFrames.clear();
        tamagotchiFrames.addAll(tamagotchiHappyFrames);
        _animationController.stop();
      }
    });

    Timer(const Duration(seconds: 2), () {
      setState(() {
        tamagotchiFrames.clear();
        tamagotchiFrames.addAll([defaultFrames, defaultFramesTwo]);
        _animationController.repeat(reverse: true);
      });
    });
  }

  void resetfeedTamagotchi() {
    print(tamagotchiFrames);
    setState(() {
      if (isDead) {
        happinessLevel = 100;
        hungerLevel = 100;
        isDead = false;
        currentFrameIndex = (currentFrameIndex + 1) % tamagotchiFrames.length;
        _animationController.reset();
      }
    });
  }

  Widget buildMessageWidget() {
    if (isDead) {
      return const Column(
        children: [
          SizedBox(height: 16),
          Text(
            '¡Tu Tamagotchi ha muerto!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      );
    } else if (hungerLevel < 10 && happinessLevel < 10) {
      return const Column(
        children: [
          SizedBox(height: 16),
          Text(
            '¡Tu Tamagotchi está hambriento y triste!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      );
    } else if (hungerLevel < 10) {
      return const Column(
        children: [
          SizedBox(height: 16),
          Text(
            '¡Tu Tamagotchi está hambriento!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.red,
            ),
          ),
        ],
      );
    } else if (happinessLevel < 10) {
      return const Column(
        children: [
          SizedBox(height: 16),
          Text(
            '¡Tu Tamagotchi está triste!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamagotchi'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: resetfeedTamagotchi,
            child: const Icon(Icons.replay_outlined),
          ),
          const SizedBox(
            height: 25,
          ),
          FloatingActionButton(
            onPressed: hungerfeedTamagotchi,
            child: const Icon(Icons.restaurant),
          ),
          const SizedBox(
            height: 25,
          ),
          FloatingActionButton(
            onPressed: happyfeedTamagotchi,
            child: const Icon(Icons.emoji_emotions),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF00FF7F), // Color verde lima
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Text(
                    isDead
                        ? tamagotchiFrameDead[0]
                        : tamagotchiFrames[currentFrameIndex],
                    style: const TextStyle(
                      fontFamily: 'Courier New',
                      fontSize: 24,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Hambre: $hungerLevel',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Felicidad: $happinessLevel',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              buildMessageWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
