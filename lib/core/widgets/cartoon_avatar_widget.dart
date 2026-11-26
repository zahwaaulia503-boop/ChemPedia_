import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Data opsi avatar kartun kimia lucu
class AvatarOption {
  final String id;
  final String name;
  final IconData icon;
  final Color primaryColor;
  final Color bgColor;

  const AvatarOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.primaryColor,
    required this.bgColor,
  });
}

class CartoonAvatars {
  static const List<AvatarOption> options = [
    AvatarOption(
      id: 'dr_erlenmeyer',
      name: 'Dr. Erlenmeyer',
      icon: Icons.science_rounded,
      primaryColor: AppColors.primaryPurple,
      bgColor: AppColors.purpleSoftBg,
    ),
    AvatarOption(
      id: 'atom_ceria',
      name: 'Atom Ceria',
      icon: Icons.bubble_chart_rounded,
      primaryColor: AppColors.primaryBlue,
      bgColor: AppColors.blueSoftBg,
    ),
    AvatarOption(
      id: 'prof_muda',
      name: 'Prof. Kimia',
      icon: Icons.school_rounded,
      primaryColor: AppColors.accentPink,
      bgColor: AppColors.pinkSoftBg,
    ),
    AvatarOption(
      id: 'gelas_beaker',
      name: 'Beaker Imut',
      icon: Icons.water_drop_rounded,
      primaryColor: Color(0xFF26A69A),
      bgColor: Color(0xFFE0F2F1),
    ),
    AvatarOption(
      id: 'tabung_kembar',
      name: 'Tabung Lab',
      icon: Icons.biotech_rounded,
      primaryColor: Color(0xFFFF7043),
      bgColor: Color(0xFFFBE9E7),
    ),
    AvatarOption(
      id: 'reaksi_ajaib',
      name: 'Bintang Kimia',
      icon: Icons.auto_awesome_rounded,
      primaryColor: AppColors.coinGold,
      bgColor: AppColors.coinSoftBg,
    ),
  ];

  static AvatarOption getById(String id) {
    return options.firstWhere(
      (opt) => opt.id == id,
      orElse: () => options.first,
    );
  }
}

/// Widget penampil avatar kartun kimia
class CartoonAvatarWidget extends StatelessWidget {
  final String avatarId;
  final String? customImagePath;
  final double size;
  final bool showBorder;

  const CartoonAvatarWidget({
    super.key,
    required this.avatarId,
    this.customImagePath,
    this.size = 64,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    // Jika siswa mengunggah foto custom
    if (customImagePath != null && customImagePath!.isNotEmpty) {
      final file = File(customImagePath!);
      if (file.existsSync()) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: showBorder
                ? Border.all(color: AppColors.primaryPurple, width: 2)
                : null,
            image: DecorationImage(
              image: FileImage(file),
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }

    // Avatar kartun kimia
    final avatar = CartoonAvatars.getById(avatarId);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: avatar.bgColor,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: avatar.primaryColor.withOpacity(0.4), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: avatar.primaryColor.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          avatar.icon,
          size: size * 0.52,
          color: avatar.primaryColor,
        ),
      ),
    );
  }
}
