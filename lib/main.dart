import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const TaskManagerApp());

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(),
    );
  }
}

// --- Login Screen with Modern Look ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.task_alt, size: 80, color: Colors.deepPurple),
                  const SizedBox(height: 20),
                  const Text("Welcome Back",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text("Login to manage your tasks",
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 40),
                  TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        labelText: "Email",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => (value == null || !value.contains('@'))
                          ? "Please enter a valid email" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelText: "Password",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Password cannot be empty" : null,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                        }
                      },
                      child: const Text("Login", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Home Screen with Refined Task Cards ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      setState(() {
        _tasks = List<Map<String, dynamic>>.from(json.decode(tasksString));
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', json.encode(_tasks));
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add({'title': _taskController.text, 'isDone': false});
        _taskController.clear();
      });
      _saveTasks();
    }
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index]['isDone'] = !_tasks[index]['isDone'];
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My Tasks", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _displayDialog(context),
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _tasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 100, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text("No tasks yet. Add one!", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      )
          : ListView.builder(
          padding: const EdgeInsets.all(16),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Checkbox(
              activeColor: Colors.deepPurple,
              value: _tasks[index]['isDone'],
              onChanged: (value) => _toggleTask(index),
            ),
            title: Text(
              _tasks[index]['title'],
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                decoration: _tasks[index]['isDone'] ? TextDecoration.lineThrough : null,
                color: _tasks[index]['isDone'] ? Colors.grey : Colors.black87,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _deleteTask(index),
            ),
          ),
        );
      },
    ),
    );
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add New Task'),
          content: TextField(
            controller: _taskController,
            autofocus: true,
            decoration: const InputDecoration(hintText: "What needs to be done?"),
          ),
          actions: [
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
              child: const Text('Add'),
              onPressed: () {
                _addTask();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}