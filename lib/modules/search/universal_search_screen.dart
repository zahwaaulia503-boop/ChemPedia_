import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formula_parser.dart';
import '../../data/models/material_model.dart';
import '../../data/models/element_model.dart';
import '../../data/models/glossary_model.dart';
import '../../data/repositories/app_repository.dart';
import '../../data/services/local_storage_service.dart';
import '../materials/material_detail_screen.dart';
import '../periodic_table/element_detail_modal.dart';

class UniversalSearchScreen extends StatefulWidget {
  final AppRepository repository;
  final LocalStorageService storage;

  const UniversalSearchScreen({
    super.key,
    required this.repository,
    required this.storage,
  });

  @override
  State<UniversalSearchScreen> createState() => _UniversalSearchScreenState();
}

class _UniversalSearchScreenState extends State<UniversalSearchScreen> {
  final _searchController = TextEditingController();
  List<MaterialModel> _allMaterials = [];
  List<ElementModel> _allElements = [];
  List<GlossaryModel> _allGlossary = [];

  List<MaterialModel> _matchedMaterials = [];
  List<ElementModel> _matchedElements = [];
  List<GlossaryModel> _matchedGlossary = [];

  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAllData() async {
    final mats = await widget.repository.getMaterials();
    final elems = await widget.repository.getElements();
    final gloss = await widget.repository.getGlossary();

    if (mounted) {
      setState(() {
        _allMaterials = mats;
        _allElements = elems;
        _allGlossary = gloss;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String text) {
    final q = text.trim().toLowerCase();
    setState(() {
      _query = q;
      if (q.isEmpty) {
        _matchedMaterials = [];
        _matchedElements = [];
        _matchedGlossary = [];
      } else {
        _matchedMaterials = _allMaterials.where((m) =>
            m.chapterTitle.toLowerCase().contains(q) ||
            m.topicName.toLowerCase().contains(q) ||
            m.summary.toLowerCase().contains(q) ||
            m.contentBody.toLowerCase().contains(q)).toList();

        _matchedElements = _allElements.where((e) =>
            e.symbol.toLowerCase() == q ||
            e.nameId.toLowerCase().contains(q) ||
            e.nameLatin.toLowerCase().contains(q) ||
            e.category.toLowerCase().contains(q)).toList();

        _matchedGlossary = _allGlossary.where((g) =>
            g.term.toLowerCase().contains(q) ||
            g.definition.toLowerCase().contains(q)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalResults = _matchedMaterials.length + _matchedElements.length + _matchedGlossary.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencarian Universal'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari materi, unsur, atau istilah kimia...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryPurple),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_query.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_rounded, size: 64, color: AppColors.primaryPurple.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    const Text(
                      'Ketik nama materi, lambang unsur, atau istilah kimia.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else if (totalResults == 0)
            const Expanded(
              child: Center(
                child: Text(
                  'Tidak ditemukan hasil yang cocok.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // 1. HASIL UNSUR KIMIA
                  if (_matchedElements.isNotEmpty) ...[
                    _buildSectionHeader('Unsur Kimia (${_matchedElements.length})', Icons.bubble_chart_rounded, AppColors.primaryBlue),
                    ..._matchedElements.map((elem) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.blueSoftBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  elem.symbol,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              '${elem.nameId} (${elem.nameLatin})',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text('No. Atom: ${elem.atomicNumber} • Golongan: ${elem.groupNumber} • ${elem.category}'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              ElementDetailModal.show(context, elem);
                            },
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],

                  // 2. HASIL MATERI ENSIKLOPEDIA
                  if (_matchedMaterials.isNotEmpty) ...[
                    _buildSectionHeader('Materi Pembelajaran (${_matchedMaterials.length})', Icons.menu_book_rounded, AppColors.primaryPurple),
                    ..._matchedMaterials.map((mat) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.purpleSoftBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'K-${mat.grade}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.primaryPurple,
                                  ),
                                ),
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
                            trailing: const Icon(Icons.chevron_right_rounded),
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
                    const SizedBox(height: 16),
                  ],

                  // 3. HASIL GLOSARIUM
                  if (_matchedGlossary.isNotEmpty) ...[
                    _buildSectionHeader('Istilah Glosarium (${_matchedGlossary.length})', Icons.spellcheck_rounded, AppColors.accentPink),
                    ..._matchedGlossary.map((gloss) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gloss.term,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  gloss.definition,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
