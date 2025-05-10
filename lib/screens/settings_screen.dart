import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';
import 'package:the_cue/main.dart'; // Import WelcomeScreen or your initial screen

import 'profile_screen.dart'; // Import ProfileScreen

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  int? radioValue = 0;
  bool isSwitchSaved = false; // For "Save Songs" switch
  bool isSwitchLocation = false; // For "Location Access" switch
  bool isSwitchFaceDetected = false; // For "Enable Face Detection" switch

  //Function that handles change in radio button selection
  void handleRadioValueChanged(int? value) {
    setState(() {
      radioValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100000),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/the_cue_profile_icon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ), // Your desired icon color
              const SizedBox(height: 10),
              const Text('Settings',
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white)), // Your desired text color
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: null,
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                        Colors.orange[400]!)), // Your desired button color
                child: const Text('Upgrade to Premium',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
              const SizedBox(height: 30),
            ],
          ),
          ListTile(
            // Add Profile option
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.white),
              hintText: 'Enter your email address...',
              prefixIcon: Icon(Icons.email_outlined, color: Colors.white),
            ),
          ),
          const TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.white),
              hintText: 'Enter your phone number...',
              prefixIcon:
                  Icon(Icons.phone_android_outlined, color: Colors.white),
            ),
          ),
          const TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.white),
              hintText: 'Enter your location...',
              prefixIcon:
                  Icon(Icons.location_city_outlined, color: Colors.white),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Manage Permissions',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.save, color: Colors.white),
            title:
                const Text('Save Songs', style: TextStyle(color: Colors.white)),
            trailing: Switch(
              value: isSwitchSaved,
              activeColor: Colors.orange[400],
              onChanged: (bool value) {
                setState(() {
                  isSwitchSaved = value;
                });
              },
            ),
          ),
          ListTile(
            leading:
                const Icon(Icons.location_on_outlined, color: Colors.white),
            title: const Text('Location Access',
                style: TextStyle(color: Colors.white)),
            trailing: Switch(
              value: isSwitchLocation,
              activeColor: Colors.orange[400],
              onChanged: (bool value) {
                setState(() {
                  isSwitchLocation = value;
                });
              },
            ),
          ),
          ListTile(
            leading:
                const Icon(Icons.face_unlock_outlined, color: Colors.white),
            title: const Text('Enable Face Detection',
                style: TextStyle(color: Colors.white)),
            trailing: Switch(
              value: isSwitchFaceDetected,
              activeColor: Colors.orange[400],
              onChanged: (bool value) {
                setState(() {
                  isSwitchFaceDetected = value;
                });
              },
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                // Navigate to the initial screen after logout
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) =>
                          const WelcomeScreen()), // Or your initial screen
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                textStyle: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              child:
                  const Text('Log Out', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20), // Add some spacing at the bottom
        ],
      ),
    );
  }
}
