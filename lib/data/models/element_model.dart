class ElementModel {
  final int atomicNumber;
  final String symbol;
  final String nameId;
  final String nameLatin;
  final double relativeAtomicMass;
  final int groupNumber;
  final int periodNumber;
  final String block;
  final String category;
  final String electronConfiguration;
  final String stateAtRoomTemp;
  final String funFactsAndUses;
  final String colorHex;

  const ElementModel({
    required this.atomicNumber,
    required this.symbol,
    required this.nameId,
    required this.nameLatin,
    required this.relativeAtomicMass,
    required this.groupNumber,
    required this.periodNumber,
    required this.block,
    required this.category,
    required this.electronConfiguration,
    required this.stateAtRoomTemp,
    required this.funFactsAndUses,
    this.colorHex = '#7E57C2',
  });

  factory ElementModel.fromJson(Map<String, dynamic> json) {
    return ElementModel(
      atomicNumber: json['atomic_number'] is int
          ? json['atomic_number']
          : int.tryParse(json['atomic_number']?.toString() ?? '1') ?? 1,
      symbol: json['symbol'] ?? '',
      nameId: json['name_id'] ?? '',
      nameLatin: json['name_latin'] ?? '',
      relativeAtomicMass: json['relative_atomic_mass'] is num
          ? (json['relative_atomic_mass'] as num).toDouble()
          : double.tryParse(json['relative_atomic_mass']?.toString() ?? '1.0') ?? 1.0,
      groupNumber: json['group_number'] is int
          ? json['group_number']
          : int.tryParse(json['group_number']?.toString() ?? '1') ?? 1,
      periodNumber: json['period_number'] is int
          ? json['period_number']
          : int.tryParse(json['period_number']?.toString() ?? '1') ?? 1,
      block: json['block'] ?? 's',
      category: json['category'] ?? 'Nonlogam',
      electronConfiguration: json['electron_configuration'] ?? '',
      stateAtRoomTemp: json['state_at_room_temp'] ?? 'Padat',
      funFactsAndUses: json['fun_facts_and_uses'] ?? '',
      colorHex: json['color_hex'] ?? '#7E57C2',
    );
  }

  Map<String, dynamic> toJson() => {
        'atomic_number': atomicNumber,
        'symbol': symbol,
        'name_id': nameId,
        'name_latin': nameLatin,
        'relative_atomic_mass': relativeAtomicMass,
        'group_number': groupNumber,
        'period_number': periodNumber,
        'block': block,
        'category': category,
        'electron_configuration': electronConfiguration,
        'state_at_room_temp': stateAtRoomTemp,
        'fun_facts_and_uses': funFactsAndUses,
        'color_hex': colorHex,
      };
}
