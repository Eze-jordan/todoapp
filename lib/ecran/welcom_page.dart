import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todoapp/ecran/sign.dart';

class WelcomPage extends StatefulWidget {
  const WelcomPage({super.key});

  @override
  State<WelcomPage> createState() => _WelcomPageState();
}

class _WelcomPageState extends State<WelcomPage> {
  @override
  void initState() {
    super.initState();
    // Définir un timer pour naviguer vers la prochaine page après 5 secondes
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Sign()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFbcdbef),
      body: Column(
        children: [
          const Spacer(), // Espace vide au-dessus de l'image pour la centrer
          // Image au centre de l'écran
          Center(
            child: Image.asset(
              'assets/img/TODO_IMG.jpg',
              width: 410, // Ajuste la taille si nécessaire
              height: 410,
            ),
          ),
          const Spacer(), // Espace vide sous l'image pour la centrer
          // Texte tout en bas de l'écran
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              'TodoList',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 70,
                fontWeight: FontWeight.w900,
                fontFamily: 'PTSans',
                color: Color(0xFF050505),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
