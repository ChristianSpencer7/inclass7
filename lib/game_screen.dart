// lib/game_screen.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flame/flame.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class SpookyObject {
  final String name;
  final String imagePath;
  final bool isCorrect;
  double x;
  double y;
  double speed;

  SpookyObject({
    required this.name,
    required this.imagePath,
    required this.isCorrect,
    required this.x,
    required this.y,
    required this.speed,
  });
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late List<SpookyObject> objects;
  late Timer timer;
  final Random random = Random();
  bool gameOver = false;
  String message = '';
  int score = 0;

  // Audio Players
  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final AudioPlayer _soundEffectPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    loadAssets();
    // Initialize objects after first frame to ensure MediaQuery is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeObjects();
      startMovement();
      playBackgroundMusic();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _backgroundPlayer.dispose();
    _soundEffectPlayer.dispose();
    super.dispose();
  }

  void loadAssets() async {
    // Preload images if necessary
    await Flame.images.loadAll([
      'pumpkin.png',
      'ghost.png',
      'bat.png',
      'skeleton.png',
      'background.png',
    ]);
  }

  void initializeObjects() {
    setState(() {
      objects = [
        // Correct Item
        SpookyObject(
          name: 'Pumpkin',
          imagePath: 'lib/assets/images/pumpkin.png',
          isCorrect: true,
          x: random.nextDouble() * (MediaQuery.of(context).size.width - 100),
          y: random.nextDouble() * (MediaQuery.of(context).size.height - 200),
          speed: 1.5 + random.nextDouble() * 2.5, // Slightly faster
        ),
        // Trap Items
        SpookyObject(
          name: 'Ghost',
          imagePath: 'lib/assets/images/ghost.png',
          isCorrect: false,
          x: random.nextDouble() * (MediaQuery.of(context).size.width - 100),
          y: random.nextDouble() * (MediaQuery.of(context).size.height - 200),
          speed: 1.0 + random.nextDouble() * 2.0,
        ),
        SpookyObject(
          name: 'Bat',
          imagePath: 'lib/assets/images/bat.png',
          isCorrect: false,
          x: random.nextDouble() * (MediaQuery.of(context).size.width - 100),
          y: random.nextDouble() * (MediaQuery.of(context).size.height - 200),
          speed: 1.0 + random.nextDouble() * 2.0,
        ),
        SpookyObject(
          name: 'Skeleton',
          imagePath: 'lib/assets/images/skeleton.png',
          isCorrect: false,
          x: random.nextDouble() * (MediaQuery.of(context).size.width - 100),
          y: random.nextDouble() * (MediaQuery.of(context).size.height - 200),
          speed: 1.0 + random.nextDouble() * 2.0,
        ),
        SpookyObject(
          name: 'Witch',
          imagePath: 'lib/assets/images/witch.png',
          isCorrect: false,
          x: random.nextDouble() * (MediaQuery.of(context).size.width - 100),
          y: random.nextDouble() * (MediaQuery.of(context).size.height - 200),
          speed: 1.0 + random.nextDouble() * 2.0,
        ),
      ];
    });
  }

  void startMovement() {
    timer = Timer.periodic(Duration(milliseconds: 30), (Timer t) {
      setState(() {
        objects.forEach((obj) {
          obj.y += obj.speed;
          if (obj.y > MediaQuery.of(context).size.height) {
            obj.y = -100;
            obj.x =
                random.nextDouble() * (MediaQuery.of(context).size.width - 100);
          }
        });
      });
    });
  }

  Future<void> playBackgroundMusic() async {
    try {
      await _backgroundPlayer.setAsset('lib/assets/sounds/spooky_sound.mp3');
      await _backgroundPlayer.setLoopMode(LoopMode.one); // Ensure looping
      await _backgroundPlayer.play();
    } catch (e) {
      print("Error loading background music: $e");
    }
  }

  Future<void> playSoundEffect(String sound) async {
    try {
      await _soundEffectPlayer.setAsset('lib/assets/sounds/$sound.mp3');
      await _soundEffectPlayer.play();
    } catch (e) {
      print("Error playing sound effect: $e");
    }
  }

  void handleTap(SpookyObject obj) {
    if (gameOver) return;

    if (obj.isCorrect) {
      playSoundEffect('festive_sound'); // Festive sound for correct selection
      setState(() {
        score += 1;
        message = 'You Found It!';
        showSuccessAnimation();
        resetGame();
      });
    } else {
      // Randomly decide between jump1 or jump2 sound
      String sound = random.nextBool() ? 'jump1' : 'jump2';
      playSoundEffect(sound);
      setState(() {
        message = 'Oops! That\'s a trap!';
        showWrongAnimation();
      });
    }
  }

  void showSuccessAnimation() {
    // Implement success animation, e.g., confetti
    // For simplicity, we'll show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('You Found It!'),
        content: Text('Congratulations! You found the Pumpkin.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  void showWrongAnimation() {
    // Implement wrong selection animation
    // For simplicity, we'll show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Wrong choice! Try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void resetGame() {
    // Reset positions or add more objects if desired
    initializeObjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Find the Pumpkin'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Moving Objects
          ...objects.map((obj) {
            return Positioned(
              left: obj.x,
              top: obj.y,
              child: GestureDetector(
                onTap: () => handleTap(obj),
                child: Image.asset(
                  obj.imagePath,
                  width: 80,
                  height: 80,
                ),
              ),
            );
          }).toList(),
          // Optional: Display score or messages
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              'Score: $score',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.deepOrange,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
          ),
          // Optional: Display messages at the bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.deepOrange,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.deepOrange,
        padding: EdgeInsets.all(16),
        child: Text(
          'Keep Hunting!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
