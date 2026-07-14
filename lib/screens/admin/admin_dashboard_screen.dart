import 'package:flutter/material.dart';
import 'package:wordoflifemobile/screens/auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  void _handleLogout() {
    try {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: Column(
          children: [
            Text('Welcome to the Admin Dashboard'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleLogout,
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
