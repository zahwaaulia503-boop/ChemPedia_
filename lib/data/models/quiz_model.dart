class QuizQuestionModel {
  final String id;
  final String quizId;
  final String questionText;
  final String questionImageUrl;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;
  final String explanation;
  final int orderIndex;

  const QuizQuestionModel({
    required this.id,
    required this.quizId,
    required this.questionText,
    this.questionImageUrl = '',
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    required this.explanation,
    this.orderIndex = 1,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id']?.toString() ?? '',
      quizId: json['quiz_id']?.toString() ?? '',
      questionText: json['question_text'] ?? '',
      questionImageUrl: json['question_image_url'] ?? '',
      optionA: json['option_a'] ?? '',
      optionB: json['option_b'] ?? '',
      optionC: json['option_c'] ?? '',
      optionD: json['option_d'] ?? '',
      correctOption: json['correct_option']?.toString().toUpperCase() ?? 'A',
      explanation: json['explanation'] ?? '',
      orderIndex: json['order_index'] is int
          ? json['order_index']
          : int.tryParse(json['order_index']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quiz_id': quizId,
        'question_text': questionText,
        'question_image_url': questionImageUrl,
        'option_a': optionA,
        'option_b': optionB,
        'option_c': optionC,
        'option_d': optionD,
        'correct_option': correctOption,
        'explanation': explanation,
        'order_index': orderIndex,
      };

  String getOptionText(String optionKey) {
    switch (optionKey.toUpperCase()) {
      case 'A':
        return optionA;
      case 'B':
        return optionB;
      case 'C':
        return optionC;
      case 'D':
        return optionD;
      default:
        return '';
    }
  }
}

class QuizModel {
  final String id;
  final String materialId;
  final String title;
  final List<QuizQuestionModel> questions;

  const QuizModel({
    required this.id,
    required this.materialId,
    required this.title,
    this.questions = const [],
  });

  factory QuizModel.fromJson(Map<String, dynamic> json, {List<QuizQuestionModel>? questions}) {
    return QuizModel(
      id: json['id']?.toString() ?? '',
      materialId: json['material_id']?.toString() ?? '',
      title: json['title'] ?? '',
      questions: questions ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'material_id': materialId,
        'title': title,
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}
