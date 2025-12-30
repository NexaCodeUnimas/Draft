import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'customer/home_screen.dart';
import 'customer/product_catalogue_page.dart';
import 'customer/profile_management_screen.dart';
import 'customer/book_appointment_screen.dart';
import 'customer/view_appointment_screen.dart';
import 'customer/appointment_screen.dart';
import 'customer/AI_screeen.dart';
import 'customer/orderhistory.dart';
import 'admin/admin_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        '/profile_management': (context) => const ProfileManagementScreen(),
        '/appointments_menu': (context) => const AppointmentMenuScreen(),
        '/book_appointment': (context) => const CustBookAppointmentScreen(),
        '/view_appointments': (context) => const ViewAppointmentsScreen(),
        '/ai': (context) => const GeminiChatApp(),
        '/orderhistory': (context) => const TrackOrdersScreen(),
        '/admin_home': (context) => const AdminHomeScreen(), // admin route
      },
    );
  }
}
