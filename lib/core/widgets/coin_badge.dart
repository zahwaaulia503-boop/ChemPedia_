import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Widget indikator koin harian (ChemCoins)
class CoinBadge extends StatelessWidget {
  final int coins;
  final VoidCallback? onTap;

  const CoinBadge({
    super.key,
    required this.coins,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.coinSoftBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.coinGold.withOpacity(0.4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.coinGold.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.monetization_on_rounded,
              color: AppColors.coinGold,
              size: 18,
            ),
            const SizedBox(width: 5),
            Text(
              '$coins',
              style: const TextStyle(
                color: Color(0xFFB78103),
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
