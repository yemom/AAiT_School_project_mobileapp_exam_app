import 'package:another_exam_app/model/question.dart';

class Exam {
  final String id;
  final String title;
  final String category;
  final int timeLimit;
  final List<Question> questions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Exam({
    required this.id,
    required this.title,
    required this.category,
    required this.timeLimit,
    required this.questions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Exam.fromMap(String id, Map<String, dynamic> map) {
    return Exam(
      id: id,
      title: map['title'] ?? "",
      category: map['category'] ?? "",
      timeLimit: map['timeLimit'] ?? 0,
      questions:
          ((map['questions'] ?? []) as List)
              .map((e) => Question.fromMap(e))
              .toList(),
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'timeLimit': timeLimit,
      'questions': questions.map((e) => e.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Exam copyWith({
    String? title,
    String? category,
    int? timeLimit,
    List<Question>? questions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Exam(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      timeLimit: timeLimit ?? this.timeLimit,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
