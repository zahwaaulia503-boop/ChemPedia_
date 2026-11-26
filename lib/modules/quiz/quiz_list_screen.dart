import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/chemistry_decorations.dart';
import '../../core/widgets/coin_badge.dart';
import '../../data/models/quiz_model.dart';
import '../../data/repositories/app_repository.dart';
import '../../data/services/local_storage_service.dart';
import 'quiz_play_screen.dart';

class QuizListScreen extends StatefulWidget {
  final AppRepository repository;
  final LocalStorageService storage;

  const QuizListScreen({
    super.key,
    required this.repository,
    required this.storage,
  });

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<QuizModel> _quizzes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuizzes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadQuizzes() async {
    final list = await widget.repository.getQuizzes();
    if (mounted) {
      setState(() {
        _quizzes = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final coins = widget.storage.getCoins();
    final history = widget.storage.getQuizHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuis Kimia Interaktif'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: CoinBadge(coins: coins),
            ),
          ),
        ],
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
                color: AppColors.accentPink,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: 'Daftar Kuis'),
                Tab(text: 'Riwayat Nilai'),
              ],
            ),
          ),
        ),
      ),
      body: ChemistryBackground(
        doodleColor: AppColors.accentPink,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: DAFTAR KUIS
                  ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _quizzes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final quiz = _quizzes[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.pinkSoftBg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.psychology_rounded,
                                      color: AppColors.accentPink,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          quiz.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${quiz.questions.length} Butir Soal Pilihan Ganda',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.monetization_on_rounded, color: AppColors.coinGold, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'Reward hingga +25 Koin',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFB78103),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => QuizPlayScreen(
                                            quiz: quiz,
                                            storage: widget.storage,
                                          ),
                                        ),
                                      );
                                      setState(() {}); // refresh coins
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentPink,
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    ),
                                    child: const Text('Mulai Kuis'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // TAB 2: RIWAYAT NILAI
                  history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history_edu_rounded,
                                size: 64,
                                color: AppColors.accentPink.withOpacity(0.4),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Belum ada riwayat kuis.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Ayo kerjakan salah satu kuis di tab sebelah!',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: history.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = history[index];
                            final score = item['score'] ?? 0;
                            final isPass = score >= 70;

                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isPass ? AppColors.greenSoftBg : AppColors.pinkSoftBg,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isPass ? AppColors.successGreen : AppColors.accentPink,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$score',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: isPass ? AppColors.successGreen : AppColors.accentPink,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item['quiz_title'] ?? 'Kuis Kimia',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                subtitle: Text(
                                  'Benar: ${item['correct_count']} / ${item['total_questions']} soal',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isPass ? AppColors.greenSoftBg : AppColors.pinkSoftBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isPass ? 'LULUS' : 'REMIDI',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isPass ? AppColors.successGreen : AppColors.accentPink,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
      ),
    );
  }
}
