import 'package:flutter/material.dart';
import 'package:todoapp/ecran/profil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Acceil extends StatefulWidget {
  const Acceil({super.key});

  @override
  _AcceilState createState() => _AcceilState();
}

class _AcceilState extends State<Acceil> {
  final TextEditingController taskController = TextEditingController();
  List<dynamic> tasks = [];
  bool isLoading = false;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> fetchTasks() async {
    setState(() {
      isLoading = true;
    });

    final token = await getToken();
    if (token == null) {
      showErrorSnackBar('Token non trouvé');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('https://todolist-api-production-1e59.up.railway.app/task'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        tasks = json.decode(response.body);
      });
    } else {
      showErrorSnackBar('Récupération des tâches échouée : ${response.body}');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> addTask() async {
    final token = await getToken();
    if (token == null) {
      showErrorSnackBar('Token non trouvé');
      return;
    }

    final String taskName = taskController.text.trim();
    if (taskName.isEmpty) {
      showErrorSnackBar('Veuillez entrer un nom de tâche');
      return;
    }

    final response = await http.post(
      Uri.parse('https://todolist-api-production-1e59.up.railway.app/task'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'contenu': taskName}),
    );

    if (response.statusCode == 201) {
      taskController.clear();
      await fetchTasks();
    } else {
      showErrorSnackBar('Ajout de tâche échoué : ${response.body}');
    }
  }

  Future<void> updateTask(String id, String updatedName) async {
    final token = await getToken();
    if (token == null) {
      showErrorSnackBar('Token non trouvé');
      return;
    }

    final response = await http.put(
      Uri.parse('https://todolist-api-production-1e59.up.railway.app/task/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'contenu': updatedName}),
    );

    if (response.statusCode == 200) {
      await fetchTasks();
    } else if (response.statusCode == 404) {
      showErrorSnackBar('Tâche non trouvée.');
    } else {
      showErrorSnackBar('Échec de la mise à jour : ${response.body}');
    }
  }

  Future<void> deleteTask(String id) async {
    final token = await getToken();
    if (token == null) {
      showErrorSnackBar('Token non trouvé');
      return;
    }

    final response = await http.delete(
      Uri.parse('https://todolist-api-production-1e59.up.railway.app/task/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      await fetchTasks();
    } else if (response.statusCode == 404) {
      showErrorSnackBar('Tâche non trouvée.');
    } else {
      showErrorSnackBar('Tâche supprimée : ${response.body}');
    }
  }

  void showErrorSnackBar(String contenu) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(contenu)),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFbcdbef),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFbcdbef)),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Profil()),
                  );
                },
                child: const Center(
                  child: Text('Profil', style: TextStyle(fontSize: 24)),
                ),
              ),
            ),
            ListTile(title: const Text('Tâche du jour'), onTap: () {}),
            ListTile(title: const Text('Toutes les Tâches'), onTap: () {}),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchTasks,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'TodoList',
                        style: TextStyle(
                          fontSize: 50,
                          fontFamily: 'PTSans',
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Nom de la tâche",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: taskController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: addTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFFFF),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                        child: const Text(
                          "Soumettre",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "Liste des tâches",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: Colors.grey),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return ListTile(
                          title: Text(task['contenu'] ?? 'Tâche sans contenu'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.purple),
                                onPressed: () async {
                                  String? updatedName =
                                      await showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      TextEditingController editController =
                                          TextEditingController(
                                              text: task['contenu']);
                                      return AlertDialog(
                                        title: const Text('Modifier la tâche'),
                                        content: TextField(
                                          controller: editController,
                                          decoration: const InputDecoration(
                                              labelText: 'Nom de la tâche'),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(editController.text),
                                            child: const Text('Valider'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (updatedName != null &&
                                      updatedName.isNotEmpty) {
                                    String taskId = task['id'].toString();
                                    await updateTask(taskId, updatedName);
                                  }
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  String taskId = task['id'].toString();
                                  deleteTask(taskId);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
