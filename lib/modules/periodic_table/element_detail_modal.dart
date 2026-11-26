import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formula_parser.dart';
import '../../data/models/element_model.dart';

class ElementDetailModal extends StatelessWidget {
  final ElementModel element;

  const ElementDetailModal({super.key, required this.element});

  static void show(BuildContext context, ElementModel element) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ElementDetailModal(element: element),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hexColor = _parseColor(element.colorHex);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header Kotak Unsur
          Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: hexColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: hexColor, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${element.atomicNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: hexColor,
                      ),
                    ),
                    Text(
                      element.symbol,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: hexColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      element.nameId,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Nama Latin: ${element.nameLatin}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: hexColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        element.category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: hexColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Parameter Kimia Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                _buildInfoRow('Massa Atom Relatif (Ar)', '${element.relativeAtomicMass} g/mol'),
                const Divider(height: 16),
                _buildInfoRow('Golongan & Periode', 'Golongan ${element.groupNumber}, Periode ${element.periodNumber}'),
                const Divider(height: 16),
                _buildInfoRow('Blok Orbital', 'Blok ${element.block}'),
                const Divider(height: 16),
                _buildInfoRow('Wujud pada 25°C', element.stateAtRoomTemp),
                const Divider(height: 16),
                _buildInfoRow(
                  'Konfigurasi Elektron',
                  element.electronConfiguration,
                  isFormula: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Fakta & Kegunaan
          const Text(
            'Penerapan & Fakta Unik Kimia:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.blueSoftBg.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
            ),
            child: Text(
              element.funFactsAndUses,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isFormula = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        if (isFormula)
          FormulaText(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
      ],
    );
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.primaryPurple;
    }
  }
}
