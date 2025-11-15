import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> doSignup() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    
    // Create ParseUser with username (using email) and password
    final user = ParseUser(email, password, null);
    // Set the email field using set() method
    user.set('email', email);
    
    var response = await user.signUp();
    if (!mounted) return;

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Account created successfully")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error!.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
              TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
              SizedBox(height: 20),
              ElevatedButton(onPressed: doSignup, child: Text("Register")),
            ],
          ),
        ),
      ),
    );
  }
}
