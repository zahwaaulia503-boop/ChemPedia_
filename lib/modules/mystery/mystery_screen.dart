import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/chemistry_decorations.dart';
import '../../core/widgets/coin_badge.dart';
import '../../data/models/extra_models.dart';
import '../../data/repositories/app_repository.dart';
import '../../data/services/local_storage_service.dart';

class MysteryScreen extends StatefulWidget {
  final AppRepository repository;
  final LocalStorageService storage;

  const MysteryScreen({
    super.key,
    required this.repository,
    required this.storage,
  });

  @override
  State<MysteryScreen> createState() => _MysteryScreenState();
}

class _MysteryScreenState extends State<MysteryScreen> {
  List<WeeklyMysteryModel> _mysteries = [];
  bool _isLoading = true;
  late int _coins;

  @override
  void initState() {
    super.initState();
    _coins = widget.storage.getCoins();
    _loadMysteries();
  }

  void _loadMysteries() async {
    final list = await widget.repository.getWeeklyMysteries();
    if (mounted) {
      setState(() {
        _mysteries = list;
        _isLoading = false;
      });
    }
  }

  void _unlockMystery(WeeklyMysteryModel mystery) async {
    if (_coins < mystery.coinCost) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.monetization_on_rounded, color: AppColors.coinGold),
              SizedBox(width: 8),
              Text('Koin Belum Cukup'),
            ],
          ),
          content: Text(
            'Kamu membutuhkan ${mystery.coinCost} ChemCoins untuk membuka misteri ini. Koin kamu saat ini: $_coins.\n\nAyo kerjakan kuis latihan atau login setiap hari untuk mengumpulkan koin!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
      return;
    }

    final success = await widget.storage.spendCoins(mystery.coinCost);
    if (success) {
      await widget.storage.unlockMystery(mystery.id);
      setState(() {
        _coins = widget.storage.getCoins();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Berhasil membuka Misteri Kimia Dunia! Selamat membaca!'),
          backgroundColor: AppColors.primaryPurple,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Misteri Kimia Dunia'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: CoinBadge(coins: _coins),
            ),
          ),
        ],
      ),
      body: ChemistryBackground(
        doodleColor: const Color(0xFF5E35B1),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _mysteries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final mystery = _mysteries[index];
                  final isUnlocked = widget.storage.isMysteryUnlocked(mystery.id);

                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Banner Header Misteri
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: isUnlocked
                                ? AppColors.materialsGradient
                                : AppColors.mysteryCardGradient,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isUnlocked ? 'MISTERI TERBUKA' : 'MISTERI MINGGUAN TERKUNCI',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isUnlocked ? AppColors.primaryPurple : AppColors.coinLight,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      mystery.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: isUnlocked ? AppColors.textPrimary : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Body Konten atau Tombol Unlock
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: isUnlocked
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mystery.storyContent,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    const Text(
                                      'Buka rahasia fenomena kimia paling menakjubkan di dunia ini menggunakan ChemCoins yang kamu dapatkan dari latihan kuis.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        height: 1.45,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () => _unlockMystery(mystery),
                                      icon: const Icon(Icons.key_rounded, size: 20),
                                      label: Text('Buka Misteri (${mystery.coinCost} Koin)'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.coinGold,
                                        foregroundColor: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
