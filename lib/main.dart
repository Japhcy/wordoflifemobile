import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wordoflifemobile/services/auth_gate.dart';
import 'package:wordoflifemobile/core/theme/app_colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final openAIKey = dotenv.env['OPENAI_API_KEY'];
  if (openAIKey == null || openAIKey.isEmpty) {
    debugPrint('❌ OPENAI_API_KEY not found in .env!');
  } else {
    debugPrint('✅ OPENAI_API_KEY loaded: ${openAIKey.substring(0, 10)}...');
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppThemeDark.darkTheme,
      themeMode: ThemeMode.system,
      home: AuthGate(),
    );
  }
}
