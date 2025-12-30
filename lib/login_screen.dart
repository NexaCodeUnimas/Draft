import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer/profile_input_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: const Color(0xFFFF9800),
      ),
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
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              "Please enter your email to reset password")),
                    );
                    return;
                  }
                  try {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              "Password reset link sent! Check your email.")),
                    );
                  } on FirebaseAuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text(e.message ?? "Failed to send reset email")),
                    );
                  }
                },
                child: const Text("Forgot Password?",
                    style: TextStyle(color: Colors.orange)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800)),
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                // Hardcoded admin credentials
                if (email == 'admin' && password == 'admin') {
                  Navigator.pushReplacementNamed(context, '/admin_home');
                  return;
                }

                // Normal Firebase login
                try {
                  UserCredential cred = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: email, password: password);

                  final user = cred.user;
                  if (user == null) return;

                  final profileRef = FirebaseFirestore.instance
                      .collection('profiles')
                      .doc(user.uid);
                  final profileSnap = await profileRef.get();

                  if (!profileSnap.exists) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ProfileInputScreen(userId: user.uid)),
                    );
                  } else {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                } on FirebaseAuthException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message ?? "Login failed")),
                  );
                }
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
