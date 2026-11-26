import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/supabase_service.dart';
import 'modules/navigation/main_navigation_screen.dart';
import 'modules/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci orientasi portrait agar ergonomis untuk siswa SMA
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Inisialisasi penyimpanan lokal
  final storage = await LocalStorageService.getInstance();

  // Inisialisasi Supabase (asinkron tanpa menghalangi peluncuran UI)
  SupabaseService.instance.initialize();

  runApp(ChemPediaApp(storage: storage));
}

class ChemPediaApp extends StatelessWidget {
  final LocalStorageService storage;

  const ChemPediaApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final hasProfile = storage.hasProfile();

    return MaterialApp(
      title: 'ChemPedia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: hasProfile
          ? MainNavigationScreen(storage: storage)
          : OnboardingScreen(storage: storage),
    );
  }
}
