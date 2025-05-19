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

  Future<void> addUsers(String name, String email) async {
    final response = await http.post(Uri.parse(url),
        headers: {'Content-type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email}));

    if (response.statusCode == 200) {
      setState(() {
        responseMessage =
            'User "$name" with email "$email" has been created successfully.';
        nameController.clear();
        emailController.clear();
      });
      await getUsers();
    } else {
      throw Exception('Failed to add user');
    }
  }

  Future<void> updateUser(String id, String name, String email) async {
    final response = await http.put(
      Uri.parse('$url/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email}),
    );

    if (response.statusCode == 200) {
      setState(() {
        responseMessage =
            'User "$name" with email "$email" has been updated successfully.';
        nameController.clear();
        emailController.clear();
      });
      await getUsers();
    } else {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$url/$id'));

    if (response.statusCode == 200) {
      setState(() {
        responseMessage = 'User Deleted';
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
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (isLoading) const CircularProgressIndicator(),

              // ✅ Show responseMessage after every operation
              if (responseMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    responseMessage,
                    style: const TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),

              // ✅ Fixed height ListView
              Container(
                height: screenHeight * 0.4, // 40% of screen height
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(user.id)),
                      title: Text(user.name),
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
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Name',
                ),
                controller: nameController,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Email',
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
                    onPressed: () =>
                        addUsers(nameController.text, emailController.text),
                    child: const Text('CREATE User'),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white),
                    onPressed: users.isNotEmpty
                        ? () => updateUser(
                              users[0].id.toString(),
                              nameController.text,
                              emailController.text,
                            )
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
                onPressed: users.isNotEmpty
                    ? () => deleteUser(users[0].id.toString())
                    : null,
                child: const Text('DELETE User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
