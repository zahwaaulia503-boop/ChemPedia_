import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/app_repository.dart';
import '../../data/services/local_storage_service.dart';
import '../home/home_screen.dart';
import '../materials/materials_screen.dart';
import '../periodic_table/periodic_table_screen.dart';
import '../quiz/quiz_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final LocalStorageService storage;

  const MainNavigationScreen({super.key, required this.storage});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final AppRepository _repository;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _repository = AppRepository(widget.storage);

    _screens = [
      HomeScreen(repository: _repository, storage: widget.storage),
      MaterialsScreen(repository: _repository, storage: widget.storage),
      PeriodicTableScreen(repository: _repository),
      QuizListScreen(repository: _repository, storage: widget.storage),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider, width: 1.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Beranda'),
                _buildNavItem(1, Icons.menu_book_rounded, Icons.menu_book_outlined, 'Materi'),
                _buildNavItem(2, Icons.bubble_chart_rounded, Icons.bubble_chart_outlined, 'Unsur'),
                _buildNavItem(3, Icons.psychology_rounded, Icons.psychology_outlined, 'Kuis'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primaryPurple : AppColors.textMuted;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purpleSoftBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
