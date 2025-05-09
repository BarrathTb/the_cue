import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_cue/screens/home_page_screen.dart';
import 'package:the_cue/services/user_service.dart'; // Import UserService
import 'package:the_cue/widgits/scale_transition_page.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final UserService _userService = UserService(); // Create UserService instance

  Future<void> _registerWithEmailAndPassword() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Create user document in Firestore
      await _userService.createUser(
        uid: userCredential.user!.uid,
        email: _emailController.text.trim(),
        displayName:
            _emailController.text.trim(), // Using email as display name for now
      );

      // Navigate to home page on successful registration
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        ScaleTransitionPage(widget: const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle registration errors (e.g., email already in use, weak password)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration Failed: ${e.message}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      // Handle other potential errors
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Source Sans Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign up to start requesting songs!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Source Sans Pro',
                ),
              ),
              const SizedBox(height: 32),
              _buildInput('Email', controller: _emailController),
              const SizedBox(height: 16),
              _buildInput('Password',
                  controller: _passwordController, isPassword: true),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _registerWithEmailAndPassword,
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
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Source Sans Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Navigate back to login
                },
                child: const Text(
                  "Already have an Account? Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Source Sans Pro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String placeholder,
      {TextEditingController? controller, bool isPassword = false}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF323232),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(
          color: Color(0xFFC0C0C0),
          fontSize: 14,
          fontFamily: 'Source Sans Pro',
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          border: InputBorder.none,
          hintText: placeholder,
          hintStyle: const TextStyle(
            color: Color(0xFFC0C0C0),
            fontSize: 14,
            fontFamily: 'Source Sans Pro',
          ),
        ),
      ),
    );
  }
}
