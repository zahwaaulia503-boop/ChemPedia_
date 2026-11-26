import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/chemistry_decorations.dart';
import '../../data/models/element_model.dart';
import '../../data/repositories/app_repository.dart';
import 'element_detail_modal.dart';

class PeriodicTableScreen extends StatefulWidget {
  final AppRepository repository;

  const PeriodicTableScreen({super.key, required this.repository});

  @override
  State<PeriodicTableScreen> createState() => _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends State<PeriodicTableScreen> {
  List<ElementModel> _elements = [];
  List<ElementModel> _filteredElements = [];
  bool _isLoading = true;
  bool _isFullTableView = false; // Mode toggle
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  final List<String> _categories = [
    'Semua',
    'Nonlogam',
    'Gas Mulia',
    'Logam Alkali',
    'Logam Alkali Tanah',
    'Logam Transisi',
    'Halogen',
  ];

  @override
  void initState() {
    super.initState();
    _loadElements();
  }

  void _loadElements() async {
    final list = await widget.repository.getElements();
    if (mounted) {
      setState(() {
        _elements = list;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredElements = _elements.where((e) {
        final matchesCat = _selectedCategory == 'Semua' ||
            e.category.toLowerCase() == _selectedCategory.toLowerCase();
        final matchesQuery = _searchQuery.isEmpty ||
            e.symbol.toLowerCase() == _searchQuery.toLowerCase() ||
            e.nameId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.nameLatin.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.atomicNumber.toString() == _searchQuery;
        return matchesCat && matchesQuery;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ensiklopedia Unsur'),
        actions: [
          IconButton(
            tooltip: _isFullTableView ? 'Tampilan Kartu' : 'Tampilan Tabel Lengkap',
            icon: Icon(
              _isFullTableView ? Icons.grid_view_rounded : Icons.table_chart_rounded,
              color: AppColors.primaryBlue,
            ),
            onPressed: () {
              setState(() {
                _isFullTableView = !_isFullTableView;
              });
            },
          ),
        ],
      ),
      body: ChemistryBackground(
        doodleColor: AppColors.primaryBlue,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isFullTableView
                ? _buildFullTableView()
                : _buildCardListView(),
      ),
    );
  }

  // --- MODE 1: DAFTAR KARTU INTERAKTIF & FILTER ---
  Widget _buildCardListView() {
    return Column(
      children: [
        // Search Input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: TextField(
            onChanged: (val) {
              _searchQuery = val.trim();
              _applyFilters();
            },
            decoration: InputDecoration(
              hintText: 'Cari lambang atau nama (misal: H, Oksigen, 11)...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlue),
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

        // Chips Kategori
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                selectedColor: AppColors.primaryBlue,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryBlue : AppColors.divider,
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategory = cat;
                      _applyFilters();
                    });
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Grid Kartu Unsur
        Expanded(
          child: _filteredElements.isEmpty
              ? const Center(
                  child: Text(
                    'Unsur kimia tidak ditemukan.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.15,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _filteredElements.length,
                  itemBuilder: (context, index) {
                    final elem = _filteredElements[index];
                    final color = _parseColor(elem.colorHex);

                    return Card(
                      child: InkWell(
                        onTap: () => ElementDetailModal.show(context, elem),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${elem.atomicNumber}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: color,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      elem.category,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Center(
                                child: Text(
                                  elem.symbol,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: color,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    elem.nameId,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Ar: ${elem.relativeAtomicMass}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- MODE 2: TABEL PERIODIK PENUH DENGAN SCROLL & ZOOM ---
  Widget _buildFullTableView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Tabel Periodik 18 Golongan (Geser kanan/kiri untuk melihat)',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            // Header Nomor Golongan 1 - 18
            Row(
              children: List.generate(18, (index) {
                return Container(
                  width: 58,
                  height: 24,
                  margin: const EdgeInsets.all(2),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }),
            ),
            // Baris Periode 1 sampai 7
            ...List.generate(7, (pIndex) {
              final period = pIndex + 1;
              return Row(
                children: List.generate(18, (gIndex) {
                  final group = gIndex + 1;
                  ElementModel? elem;
                  try {
                    elem = _elements.firstWhere(
                      (e) => e.periodNumber == period && e.groupNumber == group,
                    );
                  } catch (_) {
                    elem = null;
                  }

                  if (elem == null) {
                    return Container(
                      width: 58,
                      height: 58,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }

                  final color = _parseColor(elem.colorHex);
                  return GestureDetector(
                    onTap: () => ElementDetailModal.show(context, elem!),
                    child: Container(
                      width: 58,
                      height: 58,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color, width: 1.2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${elem.atomicNumber}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                          Text(
                            elem.symbol,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: color,
                            ),
                          ),
                          Text(
                            elem.nameId,
                            style: const TextStyle(
                              fontSize: 8,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.primaryBlue;
    }
  }
}
