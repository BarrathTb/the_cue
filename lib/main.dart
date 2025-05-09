import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // Import Firebase Auth with alias
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:the_cue/services/spotify_service.dart';
import 'package:the_cue/widgits/scale_transition_page.dart';

import 'screens/home_page_screen.dart'; // Import HomePage
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart'; // Import Registration Screen

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  await dotenv.load();
  await SpotifyService.connectToSpotify();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Cue',
      theme: ThemeData(
        primaryColor: Colors.grey[900],
      ),
      // Check authentication state and navigate accordingly
      home: StreamBuilder<firebase_auth.User?>(
        stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while checking auth state
            return const Scaffold(
              backgroundColor: Color(0xFF161616),
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            // User is logged in, navigate to HomePage
            return const HomePage();
          } else {
            // User is not logged in, show WelcomeScreen
            return const WelcomeScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(), // Corrected route to HomePage
        '/register': (context) =>
            const RegistrationScreen(), // Add registration route
      },
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: Scaffold(
        backgroundColor: const Color(0xFF161616),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 33),
                width: 310,
                height: 310,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image:
                        AssetImage('assets/images/the_cue_welcome_party.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'The Cue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontFamily: 'Source Sans Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Search and select songs to get this party going',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Source Sans Pro',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Add the functionality for the 'Preview' button
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: const Color(0xFFFF9100),
                ),
                child: Container(
                  width: 327,
                  height: 48,
                  alignment: Alignment.center,
                  child: const Text(
                    'Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Source Sans Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Login Screen with Zoom animation
                  Navigator.push(
                    context,
                    ScaleTransitionPage(widget: const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: Container(
                  width: 327,
                  height: 48,
                  alignment: Alignment.center,
                  child: const Text(
                    'Login Now',
                    style: TextStyle(
                      color: Color(0xFF161616),
                      fontSize: 14,
                      fontFamily: 'Source Sans Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
