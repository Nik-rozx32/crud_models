import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/user_model.dart';

class Crud extends StatefulWidget {
  const Crud({Key? key}) : super(key: key);

  @override
  State<Crud> createState() => _CrudState();
}

class _CrudState extends State<Crud> {
  String url = 'https://6823470765ba0580339612e1.mockapi.io/crud/post';
  String responseMessage = '';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  List<User> users = [];
  bool isLoading = false;

  Future<void> getUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      final List<dynamic> jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          users = jsonData.map((userJson) => User.fromJson(userJson)).toList();
          responseMessage = 'Data Loaded';
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print(e);
      setState(() {
        responseMessage = 'Failed to load data';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addUser(User user) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({'name': user.name, 'email': user.email}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        responseMessage = 'User "${user.name}" added successfully.';
        nameController.clear();
        emailController.clear();
      });
      await getUsers();
    } else {
      throw Exception('Failed to add user');
    }
  }

  Future<void> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$url/${user.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': user.name, 'email': user.email}),
    );

    if (response.statusCode == 200) {
      setState(() {
        responseMessage = 'User "${user.name}" updated successfully.';
        nameController.clear();
        emailController.clear();
      });
      await getUsers();
    } else {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(User user) async {
    final response = await http.delete(Uri.parse('$url/${user.id}'));

    if (response.statusCode == 200) {
      setState(() {
        responseMessage = 'User deleted';
      });
      await getUsers();
    } else {
      throw Exception('Failed to delete user');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (isLoading) const CircularProgressIndicator(),
              if (responseMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    responseMessage,
                    style: const TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              Container(
                height: screenHeight * 0.4,
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(user.id)),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white),
                onPressed: getUsers,
                child: const Text('GET Data'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      final user = User(
                        id: '',
                        name: nameController.text,
                        email: emailController.text,
                      );
                      addUser(user);
                    },
                    child: const Text('CREATE User'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white),
                    onPressed: users.isNotEmpty
                        ? () {
                            final user = User(
                              id: users[0].id,
                              name: nameController.text,
                              email: emailController.text,
                            );
                            updateUser(user);
                          }
                        : null,
                    child: const Text('UPDATE User'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white),
                onPressed: users.isNotEmpty ? () => deleteUser(users[0]) : null,
                child: const Text('DELETE User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
