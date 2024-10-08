// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

void main() {
  runApp(SpookyHalloweenApp());
}

class SpookyHalloweenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spooky Halloween App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        textTheme: GoogleFonts.creepsterTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Welcome to Spooky Halloween'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Animated Welcome Text
            AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  'Are you brave enough?',
                  textStyle: TextStyle(
                    fontSize: 32,
                    color: Colors.orange,
                  ),
                  speed: Duration(milliseconds: 100),
                ),
              ],
              isRepeatingAnimation: false,
            ),
            SizedBox(height: 50),
            // Start Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange, // Updated from 'primary'
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Start Game',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
