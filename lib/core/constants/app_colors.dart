import 'package:flutter/material.dart';

/// Palet warna pastel tematik untuk ChemPedia
class AppColors {
  // Latar Belakang & Netral
  static const Color background = Color(0xFFFAFAFD);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF6E7191);
  static const Color textMuted = Color(0xFFA0A3BD);
  static const Color divider = Color(0xFFEFF0F6);

  // Palet Pastel Ungu (Fitur Beranda & Glosarium)
  static const Color primaryPurple = Color(0xFF7E57C2);
  static const Color purpleLight = Color(0xFFB39DDB);
  static const Color purpleSoftBg = Color(0xFFEDE7F6);

  // Palet Pastel Pink (Aksen & Kuis)
  static const Color accentPink = Color(0xFFEC407A);
  static const Color pinkLight = Color(0xFFF48FB1);
  static const Color pinkSoftBg = Color(0xFFFCE4EC);

  // Palet Pastel Biru / Cyan (Fitur Unsur & Materi)
  static const Color primaryBlue = Color(0xFF0288D1);
  static const Color blueLight = Color(0xFF81D4FA);
  static const Color blueSoftBg = Color(0xFFE1F5FE);

  // Palet Pastel Kuning / Emas (Koin & Misteri)
  static const Color coinGold = Color(0xFFFFB300);
  static const Color coinLight = Color(0xFFFFE082);
  static const Color coinSoftBg = Color(0xFFFFF8E1);

  // Palet Pastel Hijau (Sukses & Benar)
  static const Color successGreen = Color(0xFF43A047);
  static const Color greenSoftBg = Color(0xFFE8F5E9);

  // Palet Pastel Merah (Salah & Batal)
  static const Color errorRed = Color(0xFFE53935);
  static const Color redSoftBg = Color(0xFFFFEBEE);

  // Gradasi Tematik per Fitur
  static const LinearGradient homeHeaderGradient = LinearGradient(
    colors: [Color(0xFFEDE7F6), Color(0xFFFCE4EC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient materialsGradient = LinearGradient(
    colors: [Color(0xFFEDE7F6), Color(0xFFE1F5FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient elementsGradient = LinearGradient(
    colors: [Color(0xFFE0F7FA), Color(0xFFE1F5FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient quizGradient = LinearGradient(
    colors: [Color(0xFFFCE4EC), Color(0xFFEDE7F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coinGradient = LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mysteryCardGradient = LinearGradient(
    colors: [Color(0xFF5E35B1), Color(0xFF3949AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
