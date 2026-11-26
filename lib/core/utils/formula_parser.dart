import 'package:flutter/material.dart';

/// Utilitas untuk memformat teks dan rumus kimia menjadi subscript/superscript
class FormulaParser {
  static const Map<String, String> _subscripts = {
    '0': '\u2080',
    '1': '\u2081',
    '2': '\u2082',
    '3': '\u2083',
    '4': '\u2084',
    '5': '\u2085',
    '6': '\u2086',
    '7': '\u2087',
    '8': '\u2088',
    '9': '\u2089',
    '+': '\u208A',
    '-': '\u208B',
  };

  static const Map<String, String> _superscripts = {
    '0': '\u2070',
    '1': '\u00B9',
    '2': '\u00B2',
    '3': '\u00B3',
    '4': '\u2074',
    '5': '\u2075',
    '6': '\u2076',
    '7': '\u2077',
    '8': '\u2078',
    '9': '\u2079',
    '+': '\u207A',
    '-': '\u207B',
  };

  /// Mengonversi sintaks rumus kimia biasa ke Unicode yang presisi
  /// Contoh: "H2SO4" -> "H₂SO₄", "Ca2+" -> "Ca²⁺", "-> " -> "→"
  static String formatFormula(String raw) {
    if (raw.isEmpty) return raw;

    String result = raw;

    // Ganti panah reaksi
    result = result.replaceAll('->', '→');
    result = result.replaceAll('<=>', '⇌');
    result = result.replaceAll('delta H', 'ΔH');
    result = result.replaceAll('delta T', 'ΔT');

    // Pola muatan ion umum (superscript): 2+, 3+, 2-, 3-, +, - setelah huruf kapital/angka
    final ionRegex = RegExp(r'(\^|\b)([0-9]*[\+\-])');
    result = result.replaceAllMapped(ionRegex, (match) {
      final ionStr = match.group(2) ?? '';
      return ionStr.split('').map((c) => _superscripts[c] ?? c).join();
    });

    // Pola indeks atom (subscript): angka yang berada tepat setelah huruf (misal H2, SO4, NO3)
    final formulaRegex = RegExp(r'([A-Za-z\)])([0-9]+)');
    result = result.replaceAllMapped(formulaRegex, (match) {
      final letter = match.group(1);
      final digits = match.group(2) ?? '';
      final subDigits = digits.split('').map((d) => _subscripts[d] ?? d).join();
      return '$letter$subDigits';
    });

    return result;
  }
}

/// Widget khusus penampil formula atau reaksi kimia
class FormulaText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const FormulaText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = FormulaParser.formatFormula(text);
    return Text(
      formatted,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
