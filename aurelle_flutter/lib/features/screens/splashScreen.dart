import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
      
           Image.asset('assets/logo/Aurelle_logo.png'),

            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 5,
            )
          ],
        ),
      ),
    );
  }
}