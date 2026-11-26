class MaterialModel {
  final String id;
  final int grade;
  final String chapterTitle;
  final String topicName;
  final String summary;
  final String contentBody;
  final List<String> chemicalReactions;
  final String realWorldApplication;
  final String illustrationUrl;
  final int orderIndex;

  const MaterialModel({
    required this.id,
    required this.grade,
    required this.chapterTitle,
    required this.topicName,
    required this.summary,
    required this.contentBody,
    required this.chemicalReactions,
    required this.realWorldApplication,
    this.illustrationUrl = '',
    this.orderIndex = 1,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    List<String> reactions = [];
    if (json['chemical_reactions'] != null) {
      if (json['chemical_reactions'] is List) {
        reactions = List<String>.from(json['chemical_reactions']);
      } else if (json['chemical_reactions'] is String) {
        reactions = [json['chemical_reactions']];
      }
    }

    return MaterialModel(
      id: json['id']?.toString() ?? '',
      grade: json['grade'] is int
          ? json['grade']
          : int.tryParse(json['grade']?.toString() ?? '10') ?? 10,
      chapterTitle: json['chapter_title'] ?? '',
      topicName: json['topic_name'] ?? '',
      summary: json['summary'] ?? '',
      contentBody: json['content_body'] ?? '',
      chemicalReactions: reactions,
      realWorldApplication: json['real_world_application'] ?? '',
      illustrationUrl: json['illustration_url'] ?? '',
      orderIndex: json['order_index'] is int
          ? json['order_index']
          : int.tryParse(json['order_index']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'grade': grade,
        'chapter_title': chapterTitle,
        'topic_name': topicName,
        'summary': summary,
        'content_body': contentBody,
        'chemical_reactions': chemicalReactions,
        'real_world_application': realWorldApplication,
        'illustration_url': illustrationUrl,
        'order_index': orderIndex,
      };
}
