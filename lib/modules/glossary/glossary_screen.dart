import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/chemistry_decorations.dart';
import '../../data/models/glossary_model.dart';
import '../../data/repositories/app_repository.dart';

class GlossaryScreen extends StatefulWidget {
  final AppRepository repository;

  const GlossaryScreen({super.key, required this.repository});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  List<GlossaryModel> _allTerms = [];
  List<GlossaryModel> _filteredTerms = [];
  String _selectedLetter = 'Semua';
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGlossary();
  }

  void _loadGlossary() async {
    final list = await widget.repository.getGlossary();
    if (mounted) {
      setState(() {
        _allTerms = list;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTerms = _allTerms.where((item) {
        final matchesLetter = _selectedLetter == 'Semua' ||
            item.letter.toUpperCase() == _selectedLetter.toUpperCase();
        final matchesQuery = _searchQuery.isEmpty ||
            item.term.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.definition.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesLetter && matchesQuery;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final letters = ['Semua', ..._allTerms.map((e) => e.letter.toUpperCase()).toSet().toList()..sort()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamus Istilah Kimia A-Z'),
      ),
      body: ChemistryBackground(
        doodleColor: AppColors.primaryPurple,
        child: Column(
          children: [
            // Kolom Cari Istilah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                onChanged: (val) {
                  _searchQuery = val.trim();
                  _applyFilters();
                },
                decoration: InputDecoration(
                  hintText: 'Cari istilah (misal: Entalpi, Titrasi, Mol)...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryPurple),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _applyFilters();
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Chips Abjad A-Z
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: letters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final letter = letters[index];
                  final isSelected = _selectedLetter == letter;
                  return ChoiceChip(
                    label: Text(letter),
                    selected: isSelected,
                    selectedColor: AppColors.primaryPurple,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryPurple : AppColors.divider,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedLetter = letter;
                          _applyFilters();
                        });
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Daftar Istilah
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredTerms.isEmpty
                      ? const Center(
                          child: Text(
                            'Istilah kimia tidak ditemukan.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          itemCount: _filteredTerms.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _filteredTerms[index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: const BoxDecoration(
                                            color: AppColors.purpleSoftBg,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              item.letter.toUpperCase(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.primaryPurple,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item.term,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        if (item.relatedChapter.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.blueSoftBg,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item.relatedChapter,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.primaryBlue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      item.definition,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
