import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'customer/profile_input_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential cred = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim());
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ProfileInputScreen(userId: cred.user!.uid)));
                } on FirebaseAuthException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message ?? "Registration failed")),
                  );
                }
              },
              child: const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
