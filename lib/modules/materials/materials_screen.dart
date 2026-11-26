import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/chemistry_decorations.dart';
import '../../data/models/material_model.dart';
import '../../data/repositories/app_repository.dart';
import '../../data/services/local_storage_service.dart';
import 'material_detail_screen.dart';

class MaterialsScreen extends StatefulWidget {
  final AppRepository repository;
  final LocalStorageService storage;

  const MaterialsScreen({
    super.key,
    required this.repository,
    required this.storage,
  });

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MaterialModel> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final profile = widget.storage.getProfile();
    final initialTab = (profile != null && profile.grade >= 10 && profile.grade <= 12)
        ? profile.grade - 10
        : 0;

    _tabController = TabController(length: 3, vsync: this, initialIndex: initialTab);
    _loadMaterials();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMaterials() async {
    final list = await widget.repository.getMaterials();
    if (mounted) {
      setState(() {
        _materials = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ensiklopedia Materi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: 'Kelas X\n(Fase E)'),
                Tab(text: 'Kelas XI\n(Fase F)'),
                Tab(text: 'Kelas XII\n(Fase F)'),
              ],
            ),
          ),
        ),
      ),
      body: ChemistryBackground(
        doodleColor: AppColors.primaryPurple,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [10, 11, 12].map((grade) {
                  final gradeMaterials = _materials.where((m) => m.grade == grade).toList();

                  if (gradeMaterials.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada materi untuk Kelas $grade.',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: gradeMaterials.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final mat = gradeMaterials[index];
                      final isFav = widget.storage.isFavorite(mat.id);

                      return Card(
                        child: InkWell(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MaterialDetailScreen(
                                  material: mat,
                                  repository: widget.repository,
                                  storage: widget.storage,
                                ),
                              ),
                            );
                            setState(() {}); // refresh bookmark status
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.purpleSoftBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Bab ${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryPurple,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                      color: isFav ? AppColors.accentPink : AppColors.textMuted,
                                      size: 22,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  mat.chapterTitle,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mat.topicName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryPurple,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  mat.summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Buka Materi Lengkap',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryPurple,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: AppColors.primaryPurple,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
      ),
    );
  }
}
