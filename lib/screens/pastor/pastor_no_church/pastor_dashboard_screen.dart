import 'package:flutter/material.dart';
import 'package:wordoflifemobile/services/auth_service.dart';
import 'package:wordoflifemobile/screens/auth/login_screen.dart';

class PastorDashboard extends StatefulWidget {
  const PastorDashboard({super.key});

  @override
  State<PastorDashboard> createState() => _PastorDashboardState();
}

class _PastorDashboardState extends State<PastorDashboard> {
  Future<void> _handleLogout() async {
    try {
      await AuthService().signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pastor Dashboard')),
      body: Center(
        child: Column(
          children: [
            Text('Welcome, Pastor!'),
            ElevatedButton(onPressed: _handleLogout, child: Text('Logout')),
          ],
        ),
      ),
    );
  }
}
