import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/cartoon_avatar_widget.dart';
import '../../core/widgets/chemistry_decorations.dart';
import '../../data/models/extra_models.dart';
import '../../data/services/local_storage_service.dart';
import '../navigation/main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final LocalStorageService storage;

  const OnboardingScreen({super.key, required this.storage});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  int _selectedGrade = 10;
  String _selectedAvatarId = CartoonAvatars.options.first.id;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveAndProceed() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = UserProfileModel(
      name: _nameController.text.trim(),
      grade: _selectedGrade,
      avatarId: _selectedAvatarId,
    );

    await widget.storage.saveProfile(profile);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainNavigationScreen(storage: widget.storage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ChemistryBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Logo & Ilustrasi
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.purpleSoftBg,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPurple.withOpacity(0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.science_rounded,
                          size: 48,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Selamat Datang di\nChemPedia!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ensiklopedia & Media Pembelajaran Kimia SMA\nKurikulum Merdeka Interaktif',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Card Profil Siswa
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pilih Karakter Kimia Kamu',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Pilihan Avatar
                            SizedBox(
                              height: 80,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: CartoonAvatars.options.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 14),
                                itemBuilder: (context, index) {
                                  final avatar = CartoonAvatars.options[index];
                                  final isSelected = avatar.id == _selectedAvatarId;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedAvatarId = avatar.id;
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CartoonAvatarWidget(
                                              avatarId: avatar.id,
                                              size: 52,
                                              showBorder: isSelected,
                                            ),
                                            if (isSelected)
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: const EdgeInsets.all(2),
                                                  decoration: const BoxDecoration(
                                                    color: AppColors.primaryPurple,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          avatar.name,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                            color: isSelected ? AppColors.primaryPurple : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Input Nama
                            const Text(
                              'Nama Panggilan Kamu',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                hintText: 'Misal: Rina, Budi, Kevin...',
                                prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primaryPurple),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Silakan masukkan nama panggilan kamu';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Pilih Jenjang Kelas
                            const Text(
                              'Pilih Jenjang Kelas SMA Kamu',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [10, 11, 12].map((grade) {
                                final isSelected = _selectedGrade == grade;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedGrade = grade;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.primaryPurple : AppColors.background,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isSelected ? AppColors.primaryPurple : AppColors.divider,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Kelas $grade',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              grade == 10 ? 'Fase E' : 'Fase F',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isSelected ? Colors.white70 : AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tombol Simpan & Masuk
                    ElevatedButton(
                      onPressed: _saveAndProceed,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Mulai Jelajahi Kimia!'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
