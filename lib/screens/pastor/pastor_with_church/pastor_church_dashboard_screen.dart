import 'package:flutter/material.dart';
import 'package:wordoflifemobile/services/auth_service.dart';
import 'package:wordoflifemobile/screens/auth/login_screen.dart';

class PastorChurchDashboard extends StatefulWidget {
  const PastorChurchDashboard({super.key});

  @override
  State<PastorChurchDashboard> createState() => _PastorChurchDashboardState();
}

class _PastorChurchDashboardState extends State<PastorChurchDashboard> {

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
      appBar: AppBar(
        title: const Text('Pastor Church Dashboard'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Welcome, Pastor!'),
            ElevatedButton(
              onPressed: _handleLogout,
              child: Text('Logout'),
            )
          ],
        ),
      ),
    );
  }
}
