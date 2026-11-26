class GlossaryModel {
  final String id;
  final String term;
  final String letter;
  final String definition;
  final String relatedChapter;

  const GlossaryModel({
    required this.id,
    required this.term,
    required this.letter,
    required this.definition,
    this.relatedChapter = '',
  });

  factory GlossaryModel.fromJson(Map<String, dynamic> json) {
    return GlossaryModel(
      id: json['id']?.toString() ?? '',
      term: json['term'] ?? '',
      letter: json['letter'] ?? (json['term'] != null && json['term'].isNotEmpty ? json['term'][0].toUpperCase() : 'A'),
      definition: json['definition'] ?? '',
      relatedChapter: json['related_chapter'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'term': term,
        'letter': letter,
        'definition': definition,
        'related_chapter': relatedChapter,
      };
}
