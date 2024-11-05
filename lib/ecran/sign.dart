import 'package:flutter/material.dart';
import 'package:todoapp/ecran/acceil.dart';
import 'package:todoapp/ecran/creer_compte.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Sign extends StatefulWidget {
  const Sign({super.key});

  @override
  _SignState createState() => _SignState();
}

class _SignState extends State<Sign> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  Future<void> signIn(BuildContext context) async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    try {
      final response = await http.post(
        Uri.parse(
            'https://todolist-api-production-1e59.up.railway.app/auth/connexion'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      // Affiche le corps de la réponse pour déboguer
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Accédez aux champs à l'intérieur de l'objet user
        final String? accessToken = responseData['accessToken'];
        final String? username = responseData['user']['nom']; // Changement ici
        final String? userEmail =
            responseData['user']['email']; // Changement ici

        if (accessToken != null && username != null && userEmail != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', accessToken);
          await prefs.setString('username', username);
          await prefs.setString('email', userEmail);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connexion réussie !')),
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Acceil()),
          );

          await fetchTasks();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Données de connexion manquantes.')),
          );
          print(
              'Données manquantes dans la réponse : accessToken=$accessToken, username=$username, email=$userEmail');
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erreur de connexion'),
            content: const Text("Email ou mot de passe incorrect."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion : $e')),
      );
    }
  }

  Future<void> fetchTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    try {
      final response = await http.get(
        Uri.parse('https://todolist-api-production-1e59.up.railway.app/task'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('Tâches récupérées : ${response.body}');
      } else {
        print('Erreur lors de la récupération des tâches : ${response.body}');
      }
    } catch (e) {
      print("Erreur de récupération des tâches : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFbcdbef),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Center(
                child: Text(
                  'TodoList',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'PTSans',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              const Text("Email",
                  style: TextStyle(fontSize: 16, color: Colors.black)),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Mot de passe",
                  style: TextStyle(fontSize: 16, color: Colors.black)),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => signIn(context),
                  child: const Text(
                    "Connexion",
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const CreerCompte()),
                    );
                  },
                  child: const Text(
                    "Vous n'avez pas de compte? Créer un",
                    style: TextStyle(color: Color(0xFF000000), fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
