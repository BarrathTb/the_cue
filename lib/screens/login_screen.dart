import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';
import 'package:the_cue/screens/home_page_screen.dart';
import 'package:the_cue/screens/registration_screen.dart'; // Import Registration Screen
import 'package:the_cue/widgits/scale_transition_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate to home page on successful login
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        ScaleTransitionPage(widget: const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle login errors (e.g., invalid email, wrong password)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Failed: ${e.message}'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 40),
                width: 128,
                height: 128,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/the_cue_login_turntable.jpeg'), // Update the path accordingly
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'The Cue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Source Sans Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Discover and select songs with ease!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Source Sans Pro',
                ),
              ),
              const SizedBox(height: 16),
              _buildInput('Email',
                  controller: _emailController), // Pass controller
              const SizedBox(height: 16),
              _buildInput('Password',
                  controller: _passwordController,
                  isPassword: true), // Pass controller
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () async {
                    // Implement password reset functionality
                    final email = _emailController.text.trim();
                    if (email.isEmpty) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please enter your email to reset password.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: email);
                      if (!mounted) return; // Check mounted AFTER await
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Password reset email sent. Check your inbox.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      if (!mounted) return; // Check mounted AFTER await
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Failed to send password reset email: ${e.message}'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return; // Check mounted AFTER await
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('An unexpected error occurred: $e'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Forgot your password?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'Source Sans Pro',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    _signInWithEmailAndPassword, // Call the sign-in function
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
                    'Log In',
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
              const Text(
                'or',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Source Sans Pro',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                      'Facebook', Colors.white, const Color(0xFF004D76)),
                  const SizedBox(width: 10),
                  _buildSocialButton(
                      'Google', Colors.white, const Color(0xFFFF4C14)),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Navigate to Registration Screen with Scale animation
                  Navigator.push(
                    context,
                    ScaleTransitionPage(widget: const RegistrationScreen()),
                  );
                },
                child: const Text(
                  "Don't have an Account? Register Now",
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
        controller: controller, // Assign the controller
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

  Widget _buildSocialButton(String text, Color textColor, Color bgColor) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          // Add the functionality for the social buttons
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          backgroundColor: bgColor,
        ),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontFamily: 'Source Sans Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
