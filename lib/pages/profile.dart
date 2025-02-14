import 'package:demo/providers/valentine_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:demo/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:demo/providers/theme_provider.dart';
import 'package:demo/pages/edit_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/providers/auth_provider.dart' as auth; // Change this line

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mock user data
  Map<String, String> userData = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone': '+1 234 567 890',
    'age': '30',
    'weight': '70 kg',
    'height': '175 cm',
  };

  // Mock settings - removed final keyword to make them mutable
  bool _notificationsEnabled = true;
  // bool _darkMode = false;
  bool _locationEnabled = true;

  Future<void> _updateUserProfile(Map<String, String> updatedData) async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'profile': updatedData,
      });
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.person, size: 50, color: AppColors.background),
          ),
          const SizedBox(height: 16),
          Text(
            userData['name']!,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            userData['email']!,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('Phone', userData['phone']!),
            _buildInfoRow('Age', userData['age']!),
            _buildInfoRow('Weight', userData['weight']!),
            _buildInfoRow('Height', userData['height']!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Notifications'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() => _notificationsEnabled = value);
              },
            ),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: themeProvider.isDarkMode,
                  onChanged: (bool value) {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
            SwitchListTile(
              title: const Text('Location Services'),
              value: _locationEnabled,
              onChanged: (bool value) {
                setState(() => _locationEnabled = value);
              },
            ),
            Consumer<ValentineProvider>(
              builder: (context, valentineProvider, child) {
                return SwitchListTile(
                  title: const Text('Valentine Mode'),
                  subtitle: const Text('Special theme for Valentine\'s Day'),
                  value: valentineProvider.isValentineMode,
                  activeColor: Colors.pink[300],
                  onChanged: (bool value) {
                    valentineProvider.toggleValentineMode();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context
                          .read<auth.AuthProvider>()
                          .logout(); // Change this line
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.background,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Logout'),
      ),
    );
  }

  void _handleProfileUpdate(Map<String, String> updatedData) async {
    await _updateUserProfile(updatedData);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(userData: userData),
                ),
              );

              if (result != null && result is Map<String, String>) {
                setState(() {
                  userData = result;
                });
                _handleProfileUpdate(result);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildInfoSection(),
            _buildSettingsSection(),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }
}
