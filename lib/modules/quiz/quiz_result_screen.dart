import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formula_parser.dart';
import '../../core/widgets/chemistry_decorations.dart';
import '../../data/models/quiz_model.dart';
import '../../data/services/local_storage_service.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizModel quiz;
  final Map<int, String> userAnswers; // index -> 'A'/'B'/'C'/'D'
  final LocalStorageService storage;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.userAnswers,
    required this.storage,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late int _score;
  late int _correctCount;
  late int _total;
  late int _earnedCoins;

  @override
  void initState() {
    super.initState();
    _calculateAndSaveResult();
  }

  void _calculateAndSaveResult() {
    _total = widget.quiz.questions.length;
    _correctCount = 0;

    for (int i = 0; i < _total; i++) {
      final question = widget.quiz.questions[i];
      final userAns = widget.userAnswers[i];
      if (userAns != null && userAns.toUpperCase() == question.correctOption.toUpperCase()) {
        _correctCount++;
      }
    }

    _score = _total > 0 ? ((_correctCount / _total) * 100).round() : 0;

    // Hitung reward koin berdasarkan performa
    if (_score >= 80) {
      _earnedCoins = 25;
    } else if (_score >= 60) {
      _earnedCoins = 15;
    } else {
      _earnedCoins = 5;
    }

    // Simpan ke local storage
    widget.storage.addCoins(_earnedCoins);
    widget.storage.saveQuizResult(
      quizTitle: widget.quiz.title,
      score: _score,
      correctCount: _correctCount,
      totalQuestions: _total,
    );
  }

  String _getReflectionMessage() {
    if (_score >= 90) {
      return 'Luar biasa sekali! Kamu memiliki pemahaman konsep kimia yang sangat matang dan teliti.';
    } else if (_score >= 70) {
      return 'Bagus sekali! Kamu sudah memahami sebagian besar konsep. Periksa kembali pembahasan di bawah untuk menyempurnakan jawabanmu.';
    } else if (_score >= 50) {
      return 'Cukup baik! Masih ada beberapa konsep yang perlu diperdalam. Luangkan waktu untuk membaca kembali ringkasan materi ya.';
    } else {
      return 'Tetap semangat! Jangan berkecil hati. Kimia membutuhkan pembiasaan konsep. Ayo buka kembali materi dan coba kuis ini lagi!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil & Evaluasi Belajar'),
        automaticallyImplyLeading: false,
      ),
      body: ChemistryBackground(
        doodleColor: AppColors.accentPink,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            // Card Skor Utama
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    // Lingkaran Skor
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.quizGradient,
                        border: Border.all(
                          color: _score >= 70 ? AppColors.successGreen : AppColors.accentPink,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_score >= 70 ? AppColors.successGreen : AppColors.accentPink).withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_score',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: _score >= 70 ? AppColors.successGreen : AppColors.accentPink,
                              ),
                            ),
                            const Text(
                              'DARI 100',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$_correctCount Benar dari $_total Soal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Badge Reward Koin
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.coinSoftBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.coinGold.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on_rounded, color: AppColors.coinGold, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '+$_earnedCoins ChemCoins Ditambahkan!',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB78103),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pesan Refleksi
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _getReflectionMessage(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pembahasan Setiap Soal
            const Text(
              'Ulasan & Pembahasan Jawaban:',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.quiz.questions.asMap().entries.map((entry) {
              final idx = entry.key;
              final question = entry.value;
              final userAns = widget.userAnswers[idx] ?? '-';
              final isCorrect = userAns.toUpperCase() == question.correctOption.toUpperCase();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCorrect ? AppColors.greenSoftBg : AppColors.redSoftBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'No. ${idx + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isCorrect ? AppColors.successGreen : AppColors.errorRed,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: isCorrect ? AppColors.successGreen : AppColors.errorRed,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FormulaText(
                        question.questionText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Jawaban Kamu: $userAns (${question.getOptionText(userAns)})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCorrect ? AppColors.successGreen : AppColors.errorRed,
                        ),
                      ),
                      if (!isCorrect)
                        Text(
                          'Kunci Jawaban: ${question.correctOption} (${question.getOptionText(question.correctOption)})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.successGreen,
                          ),
                        ),
                      const Divider(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primaryPurple),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FormulaText(
                                'Pembahasan: ${question.explanation}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Tombol Selesai
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Selesai & Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
