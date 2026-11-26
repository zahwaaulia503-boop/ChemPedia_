import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/cartoon_avatar_widget.dart';
import '../../core/widgets/chemistry_decorations.dart';
import '../../core/widgets/coin_badge.dart';
import '../../data/models/extra_models.dart';
import '../../data/models/material_model.dart';
import '../../data/repositories/app_repository.dart';
import '../../data/services/local_storage_service.dart';
import '../glossary/glossary_screen.dart';
import '../favorites/favorites_screen.dart';
import '../mystery/mystery_screen.dart';
import '../search/universal_search_screen.dart';
import '../materials/material_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppRepository repository;
  final LocalStorageService storage;

  const HomeScreen({
    super.key,
    required this.repository,
    required this.storage,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfileModel? _profile;
  List<DailyFactModel> _dailyFacts = [];
  List<MaterialModel> _recommendedMaterials = [];
  int _coins = 0;
  bool _canClaim = false;
  bool _isFactExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prof = widget.storage.getProfile();
    final facts = await widget.repository.getDailyFacts();
    final mats = await widget.repository.getMaterials(grade: prof?.grade ?? 10);
    final coins = widget.storage.getCoins();
    final canClaim = widget.storage.canClaimDailyCoin();

    if (mounted) {
      setState(() {
        _profile = prof;
        _dailyFacts = facts;
        _recommendedMaterials = mats;
        _coins = coins;
        _canClaim = canClaim;
      });
    }
  }

  void _claimDailyReward() async {
    if (!_canClaim) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamu sudah mengklaim koin harian hari ini. Kembali lagi besok ya!')),
      );
      return;
    }

    const reward = 15;
    await widget.storage.claimDailyCoin(reward);

    setState(() {
      _coins = widget.storage.getCoins();
      _canClaim = false;
    });

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.coinGold),
            SizedBox(width: 8),
            Text('Koin Harian Diklaim!'),
          ],
        ),
        content: const Text(
          'Selamat! Kamu mendapatkan +15 ChemCoins untuk belajar hari ini.\n\nGunakan koin ini untuk membuka Misteri Kimia Dunia!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keren!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prof = _profile ?? const UserProfileModel(name: 'Siswa', grade: 10, avatarId: 'dr_erlenmeyer');
    final todayFact = _dailyFacts.isNotEmpty ? _dailyFacts.first : null;

    return Scaffold(
      body: ChemistryBackground(
        doodleColor: AppColors.primaryPurple,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // 1. TOP HEADER: PROFIL SISWA & KOIN
                Row(
                  children: [
                    CartoonAvatarWidget(
                      avatarId: prof.avatarId,
                      customImagePath: prof.customPhotoPath,
                      size: 54,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${prof.name}! 👋',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Siswa Kelas ${prof.grade} • ${prof.grade == 10 ? 'Fase E' : 'Fase F'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CoinBadge(
                      coins: _coins,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MysteryScreen(
                              repository: widget.repository,
                              storage: widget.storage,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. SEARCH BAR PINTAS
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UniversalSearchScreen(
                          repository: widget.repository,
                          storage: widget.storage,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search_rounded, color: AppColors.primaryPurple),
                        SizedBox(width: 12),
                        Text(
                          'Cari materi, unsur, atau istilah kimia...',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. BANNER HADIAH KOIN HARIAN (JIKA BELUM CLAIM)
                if (_canClaim) ...[
                  InkWell(
                    onTap: _claimDailyReward,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: AppColors.coinGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.coinGold.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Klaim Bonus Koin Harian!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Dapatkan +15 ChemCoins gratis hari ini',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 4. FAKTA KIMIA HARIAN (TAHUKAH KAMU?)
                if (todayFact != null) ...[
                  Card(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isFactExpanded = !_isFactExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: AppColors.homeHeaderGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: AppColors.accentPink,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'FAKTA KIMIA HARI INI',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accentPink,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    todayFact.tag,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryPurple,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              todayFact.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              todayFact.factDescription,
                              maxLines: _isFactExpanded ? null : 2,
                              overflow: _isFactExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _isFactExpanded ? 'Tutup ▲' : 'Baca Selengkapnya ▼',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 5. QUICK ACCESS MENU
                const Text(
                  'Fitur Pilihan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildQuickAction(
                      icon: Icons.spellcheck_rounded,
                      title: 'Glosarium A-Z',
                      color: AppColors.primaryPurple,
                      bgColor: AppColors.purpleSoftBg,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GlossaryScreen(repository: widget.repository),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAction(
                      icon: Icons.bookmark_rounded,
                      title: 'Favorit Saya',
                      color: AppColors.accentPink,
                      bgColor: AppColors.pinkSoftBg,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FavoritesScreen(
                              repository: widget.repository,
                              storage: widget.storage,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAction(
                      icon: Icons.vpn_key_rounded,
                      title: 'Misteri Kimia',
                      color: AppColors.coinGold,
                      bgColor: AppColors.coinSoftBg,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MysteryScreen(
                              repository: widget.repository,
                              storage: widget.storage,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 6. MATERI REKOMENDASI KELAS SISWA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Materi Kelas ${prof.grade} Untukmu',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._recommendedMaterials.map((mat) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.purpleSoftBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.science_rounded,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        title: Text(
                          mat.chapterTitle,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          mat.topicName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MaterialDetailScreen(
                                material: mat,
                                repository: widget.repository,
                                storage: widget.storage,
                              ),
                            ),
                          );
                        },
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider, width: 1.2),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
