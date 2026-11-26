import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/chemistry_decorations.dart';
import '../../data/models/material_model.dart';
import '../../data/repositories/app_repository.dart';
import '../../data/services/local_storage_service.dart';
import '../materials/material_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final AppRepository repository;
  final LocalStorageService storage;

  const FavoritesScreen({
    super.key,
    required this.repository,
    required this.storage,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<MaterialModel> _favMaterials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    final favIds = widget.storage.getFavorites();
    final allMats = await widget.repository.getMaterials();

    if (mounted) {
      setState(() {
        _favMaterials = allMats.where((m) => favIds.contains(m.id)).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi Favorit Saya'),
      ),
      body: ChemistryBackground(
        doodleColor: AppColors.accentPink,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _favMaterials.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bookmark_border_rounded,
                          size: 64,
                          color: AppColors.accentPink.withOpacity(0.4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada materi yang kamu simpan.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ketuk ikon penanda buku di materi untuk menyimpannya.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: _favMaterials.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final mat = _favMaterials[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.pinkSoftBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.bookmark_rounded,
                              color: AppColors.accentPink,
                            ),
                          ),
                          title: Text(
                            mat.chapterTitle,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            'Kelas ${mat.grade} • ${mat.topicName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
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
                            _loadFavorites();
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
