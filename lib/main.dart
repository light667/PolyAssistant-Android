import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:polyassistant/pages/login_page.dart';
import 'package:polyassistant/pages/home_page.dart';
import 'package:polyassistant/pages/chat_page.dart';
import 'package:polyassistant/pages/resources_page.dart';
import 'package:polyassistant/pages/settings_page.dart';
import 'package:polyassistant/pages/welcome_page.dart';
import 'package:polyassistant/pages/redirection_page.dart';
import 'package:polyassistant/pages/profile_page.dart';
import 'package:polyassistant/pages/edit_profile_page.dart';
import 'package:polyassistant/providers/theme_provider.dart';
import 'package:polyassistant/pages/notifications_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PolyAssistant',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 4, 68, 244),
        colorScheme: const ColorScheme.light(
          primary: Color.fromARGB(255, 4, 68, 244),
          secondary: Color(0xFFFBBF24),
          surface: Color(0xFFF3F4F6),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFBBF24), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1E3A8A),
          secondary: Color(0xFFFBBF24),
          surface: Color(0xFF121212),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFBBF24), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[900],
        ),
        useMaterial3: true,
      ),
      themeMode: themeProvider.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const WelcomePage(title: 'Accueil'),
      routes: {
        '/login': (context) => const LoginPage(title: 'Connexion'),
        '/redirection': (context) => const RedirectionPage(),
        '/home': (context) => const HomePage(title: 'Accueil'),
        '/chat': (context) => const ChatPage(title: 'Chat'),
        '/resources': (context) => const ResourcesPage(title: 'Ressources'),
        '/settings': (context) => const SettingsPage(title: 'Paramètres'),
        '/profile': (context) => const ProfilePage(),
        '/edit_profile': (context) => const EditProfilePage(),
        '/notifications': (context) => const NotificationsPage(),
        '/welcome': (context) => const WelcomePage(title: 'Accueil'),
      },
    );
  }
}
