import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formula_parser.dart';
import '../../core/widgets/chemistry_decorations.dart';
import '../../data/models/material_model.dart';
import '../../data/repositories/app_repository.dart';
import '../../data/services/local_storage_service.dart';
import '../quiz/quiz_play_screen.dart';

class MaterialDetailScreen extends StatefulWidget {
  final MaterialModel material;
  final AppRepository repository;
  final LocalStorageService storage;

  const MaterialDetailScreen({
    super.key,
    required this.material,
    required this.repository,
    required this.storage,
  });

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = widget.storage.isFavorite(widget.material.id);
  }

  void _toggleFavorite() async {
    await widget.storage.toggleFavorite(widget.material.id);
    setState(() {
      _isFav = widget.storage.isFavorite(widget.material.id);
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFav ? 'Materi ditambahkan ke Favorit!' : 'Materi dihapus dari Favorit',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: _isFav ? AppColors.primaryPurple : AppColors.textSecondary,
      ),
    );
  }

  void _startQuiz() async {
    final quiz = await widget.repository.getQuizByMaterialId(widget.material.id);
    if (!mounted) return;

    if (quiz == null || quiz.questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kuis untuk bab ini sedang dipersiapkan!'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizPlayScreen(
          quiz: quiz,
          storage: widget.storage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mat = widget.material;

    return Scaffold(
      appBar: AppBar(
        title: Text(mat.chapterTitle),
        actions: [
          IconButton(
            icon: Icon(
              _isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isFav ? AppColors.accentPink : AppColors.textPrimary,
              size: 26,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: ChemistryBackground(
        doodleColor: AppColors.primaryPurple,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Tag & Topik
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.purpleSoftBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Kelas ${mat.grade} • ${mat.grade == 10 ? 'Fase E' : 'Fase F'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                mat.topicName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Ringkasan Konsep
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.materialsGradient,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.purpleLight.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.primaryPurple,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        mat.summary,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Uraian Materi Lengkap
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.menu_book_rounded, color: AppColors.primaryPurple, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Penjelasan Konsep Kimia',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        mat.contentBody,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Rumus & Persamaan Reaksi
              if (mat.chemicalReactions.isNotEmpty) ...[
                Card(
                  color: const Color(0xFFF3E5F5),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.functions_rounded, color: AppColors.primaryPurple, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Rumus & Persamaan Reaksi Kimia',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...mat.chemicalReactions.map((reaction) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.purpleLight.withOpacity(0.4)),
                                ),
                                child: FormulaText(
                                  reaction,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Penerapan dalam Kehidupan Sehari-hari
              Card(
                color: AppColors.blueSoftBg.withOpacity(0.7),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.public_rounded, color: AppColors.primaryBlue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Penerapan Nyata di Sekitarmu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        mat.realWorldApplication,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _startQuiz,
            icon: const Icon(Icons.quiz_rounded),
            label: const Text('Uji Pemahaman (Kerjakan Kuis Bab Ini)'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.accentPink,
            ),
          ),
        ),
      ),
    );
  }
}
