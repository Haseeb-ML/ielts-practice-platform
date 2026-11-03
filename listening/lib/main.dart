import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/global_layout.dart';

import 'providers/test_progress_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TestProgressProvider()),
      ],
      child: const IELTSListeningApp(),
    ),
  );
}

class IELTSListeningApp extends StatelessWidget {
  const IELTSListeningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IELTS Listener',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const GlobalLayout(),
    );
  }
}
