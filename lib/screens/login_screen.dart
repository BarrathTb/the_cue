import 'package:flutter/material.dart';
import 'package:the_cue/screens/home_page_screen.dart';
import 'package:the_cue/widgits/scale_transition_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                    image: AssetImage('assets/images/the_cue_login_turntable.jpeg'), // Update the path accordingly
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
              _buildInput('Email'),
              const SizedBox(height: 16),
              _buildInput('Password', isPassword: true),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.topRight,
                child: Text(
                  'Forgot your password?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Source Sans Pro',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Add the functionality for the 'Login' button
                  Navigator.push(context,ScaleTransitionPage(widget: const HomePage())
                  );
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
                  _buildSocialButton('Facebook', Colors.white, const Color(0xFF004D76)),
                  const SizedBox(width: 10),
                  _buildSocialButton('Google', Colors.white, const Color(0xFFFF4C14)),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Add the functionality for the 'Don't have an Account? Register Now' link
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

  Widget _buildInput(String placeholder, {bool isPassword = false}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF323232),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextFormField(
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


