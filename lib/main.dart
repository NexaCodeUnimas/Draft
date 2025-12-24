import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'product_catalogue_page.dart';
import 'AI_screeen.dart';

void main() {
  runApp(const FloorbitApp());
}

class FloorbitApp extends StatelessWidget {
  const FloorbitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Floorbit',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/products': (context) => const ProductCataloguePage(),
        '/ai': (context) => const GeminiChatApp()
      },
    );
  }
}
