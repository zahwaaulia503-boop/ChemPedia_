import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formula_parser.dart';
import '../../core/widgets/chemistry_decorations.dart';
import '../../data/models/quiz_model.dart';
import '../../data/services/local_storage_service.dart';
import 'quiz_result_screen.dart';

class QuizPlayScreen extends StatefulWidget {
  final QuizModel quiz;
  final LocalStorageService storage;

  const QuizPlayScreen({
    super.key,
    required this.quiz,
    required this.storage,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _currentIndex = 0;
  final Map<int, String> _userAnswers = {};

  void _selectOption(String optionKey) {
    setState(() {
      _userAnswers[_currentIndex] = optionKey;
    });
  }

  void _nextOrFinish() {
    if (_currentIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      // Periksa apakah ada soal yang belum dijawab
      final unansweredCount = widget.quiz.questions.length - _userAnswers.length;
      if (unansweredCount > 0) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Kumpulkan Kuis?'),
            content: Text(
              'Ada $unansweredCount butir soal yang belum kamu jawab. Apakah kamu yakin ingin menyelesaikan kuis sekarang?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Periksa Lagi'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _submitQuiz();
                },
                child: const Text('Ya, Kumpulkan'),
              ),
            ],
          ),
        );
      } else {
        _submitQuiz();
      }
    }
  }

  void _submitQuiz() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          quiz: widget.quiz,
          userAnswers: _userAnswers,
          storage: widget.storage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.quiz.questions;
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quiz.title)),
        body: const Center(child: Text('Soal tidak ditemukan.')),
      );
    }

    final currentQuestion = questions[_currentIndex];
    final selectedOption = _userAnswers[_currentIndex];
    final progress = (_currentIndex + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/${questions.length}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: ChemistryBackground(
        doodleColor: AppColors.accentPink,
        child: Column(
          children: [
            // Linear Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentPink),
              minHeight: 6,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Kartu Pertanyaan
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.pinkSoftBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Soal Nomor ${_currentIndex + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accentPink,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            FormulaText(
                              currentQuestion.questionText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Opsi Jawaban (A, B, C, D)
                    ...['A', 'B', 'C', 'D'].map((key) {
                      final optionText = currentQuestion.getOptionText(key);
                      final isSelected = selectedOption == key;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _selectOption(key),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.pinkSoftBg : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.accentPink : AppColors.divider,
                                width: isSelected ? 2 : 1.2,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: AppColors.accentPink.withOpacity(0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.accentPink : AppColors.background,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppColors.accentPink : AppColors.divider,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      key,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? Colors.white : AppColors.textPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: FormulaText(
                                    optionText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Tombol Navigasi Bawah
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (_currentIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _currentIndex--;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Sebelumnya'),
                        ),
                      ),
                    if (_currentIndex > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: selectedOption != null ? _nextOrFinish : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentPink,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          _currentIndex < questions.length - 1 ? 'Soal Berikutnya' : 'Kumpulkan Jawaban',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
