import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Customer Screens
import 'customer/home_screen.dart';
import 'customer/product_catalogue_page.dart';
import 'customer/product_details_page.dart';
import 'customer/cart_screen.dart';
import 'customer/checkout_screen.dart';
import 'customer/profile_management_screen.dart';
import 'customer/book_appointment_screen.dart';
import 'customer/view_appointment_screen.dart';
import 'customer/appointment_screen.dart';
import 'customer/AI_screeen.dart';
import 'customer/orderhistory.dart';

// Admin Screens
import 'admin/admin_home_screen.dart';
import 'admin/admin_orders_page.dart';

// Auth Screens
import 'welcome_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

// Providers
import 'provider/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FloorbitApp());
}

class FloorbitApp extends StatelessWidget {
  const FloorbitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Floorbit',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          ),
          initialRoute: '/',
          routes: {
            // Auth & Welcome
            '/': (context) => const WelcomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),

            // Customer
            '/home': (context) => const HomeScreen(),
            '/products': (context) => const ProductCataloguePage(),
            '/product_details': (context) => const ProductDetailsPage(
                productId: ''), // Pass productId when navigating
            '/cart': (context) => const CartScreen(),
            '/checkout': (context) => const CheckoutScreen(),
            '/profile_management': (context) => const ProfileManagementScreen(),
            '/appointments_menu': (context) => const AppointmentMenuScreen(),
            '/book_appointment': (context) => const CustBookAppointmentScreen(),
            '/view_appointments': (context) => const ViewAppointmentsScreen(),
            '/ai': (context) => const GeminiChatApp(),
            '/orderhistory': (context) => const TrackOrdersScreen(),

            // Admin
            '/admin_home': (context) => const AdminHomeScreen(),
            '/admin_orders': (context) => const AdminOrdersPage(),
          },
        ));
  }
}
