import 'package:flutter/material.dart';
import 'package:wordoflifemobile/services/auth_service.dart';
import 'package:wordoflifemobile/core/widgets/user_bottom_nav_w.dart';
import 'package:wordoflifemobile/screens/auth/login_screen.dart';
import 'package:wordoflifemobile/screens/pastor/pastor_no_church/pastor_dashboard_screen.dart';
import 'package:wordoflifemobile/screens/pastor/pastor_with_church/pastor_church_dashboard_screen.dart';
import 'package:wordoflifemobile/screens/user/home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();

  // state
  bool isLoading = true;
  bool isAuthenticated = false;
  String? dashboardType;
  String? error;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        final userDashboardType = await _authService.getUserDashboardType();

        setState(() {
          isLoading = false;
          isAuthenticated = true;
          dashboardType = userDashboardType;
        });
      } else {
        setState(() {
          isLoading = false;
          isAuthenticated = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Failed to check authentication status: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //show loading
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(body: Center(child: Text("Something went wrong")));
    }

    if (isAuthenticated && dashboardType != null) {
      return _navigateToDashboard(dashboardType!);
    } else {
      return const LoginScreen();
    }
  }

  Widget _navigateToDashboard(String dashboardType) {
    switch (dashboardType) {
      case 'user_dashboard':
        return const UserBottomNavW();
      case 'pastor_dashboard':
        return const PastorDashboard();
      case 'pastor_church_dashboard':
        return const PastorChurchDashboard();
      default:
        return const HomeScreen();
    }
  }
}
