import 'package:another_exam_app/model/category.dart';
import 'package:another_exam_app/model/exam.dart';
import 'package:another_exam_app/model/question.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lightweight stand-in for Firestore Timestamp so we can run pure Dart tests
/// without Firebase bindings.
class _FakeTimestamp {
  _FakeTimestamp(this._value);
  final DateTime _value;
  DateTime toDate() => _value;
}

void main() {
  group('Category model', () {
    test('fromMap provides safe defaults', () {
      final cat = Category.fromMap('cat1', {});
      expect(cat.id, 'cat1');
      expect(cat.name, '');
      expect(cat.description, '');
      expect(cat.createdAt, isNull);
    });

    test('fromMap converts timestamp to DateTime', () {
      final now = DateTime.utc(2024, 01, 01);
      final cat = Category.fromMap('cat2', {
        'name': 'Math',
        'description': 'Algebra',
        'createdAt': _FakeTimestamp(now),
      });
      expect(cat.name, 'Math');
      expect(cat.description, 'Algebra');
      expect(cat.createdAt, now);
    });

    test('toMap serializes values including createdAt', () {
      final now = DateTime.utc(2024, 02, 01);
      final cat = Category(
        id: 'cat3',
        name: 'Science',
        description: 'Physics',
        createdAt: now,
      );
      final map = cat.toMap();
      expect(map['name'], 'Science');
      expect(map['description'], 'Physics');
      expect(map['createdAt'], now);
    });

    test('copyWith overrides fields and preserves id', () {
      final original = Category(
        id: 'cat4',
        name: 'Old',
        description: 'Desc',
        createdAt: null,
      );
      final updated = original.copyWith(name: 'New');
      expect(updated.id, 'cat4');
      expect(updated.name, 'New');
      expect(updated.description, 'Desc');
    });
  });

  group('Question model', () {
    test('fromMap and toMap round-trip', () {
      final original = Question.fromMap({
        'text': '2+2?',
        'options': ['3', '4'],
        'correctOptionIndex': 1,
      });
      final map = original.toMap();
      expect(map['text'], '2+2?');
      expect(map['options'], ['3', '4']);
      expect(map['correctOptionIndex'], 1);
    });

    test('copyWith replaces only provided fields', () {
      final q = Question(
        text: 'Capital of France?',
        options: ['Paris', 'Rome'],
        correctOptionIndex: 0,
      );
      final updated = q.copyWith(correctOptionIndex: 1);
      expect(updated.text, 'Capital of France?');
      expect(updated.options, ['Paris', 'Rome']);
      expect(updated.correctOptionIndex, 1);
    });
  });

  group('Exam model', () {
    test('fromMap builds nested questions and dates', () {
      final created = DateTime.utc(2024, 03, 10);
      final updated = DateTime.utc(2024, 03, 11);
      final exam = Exam.fromMap('exam1', {
        'title': 'Midterm',
        'category': 'Math',
        'timeLimit': 45,
        'questions': [
          {
            'text': '2+2?',
            'options': ['3', '4'],
            'correctOptionIndex': 1,
          },
        ],
        'createdAt': _FakeTimestamp(created),
        'updatedAt': _FakeTimestamp(updated),
      });

      expect(exam.id, 'exam1');
      expect(exam.title, 'Midterm');
      expect(exam.category, 'Math');
      expect(exam.timeLimit, 45);
      expect(exam.questions, hasLength(1));
      expect(exam.questions.first.text, '2+2?');
      expect(exam.createdAt, created);
      expect(exam.updatedAt, updated);
    });

    test('toMap serializes nested questions', () {
      final exam = Exam(
        id: 'exam2',
        title: 'Final',
        category: 'Science',
        timeLimit: 60,
        questions: [
          Question(
            text: 'H2O is?',
            options: ['Water', 'Oxygen'],
            correctOptionIndex: 0,
          ),
        ],
        createdAt: DateTime.utc(2024, 03, 12),
        updatedAt: DateTime.utc(2024, 03, 13),
      );

      final map = exam.toMap();
      expect(map['title'], 'Final');
      expect(map['category'], 'Science');
      expect(map['timeLimit'], 60);
      expect(map['questions'], isA<List>());
      expect((map['questions'] as List).first['text'], 'H2O is?');
      expect(map['createdAt'], DateTime.utc(2024, 03, 12));
      expect(map['updatedAt'], DateTime.utc(2024, 03, 13));
    });

    test('copyWith updates provided fields and keeps id', () {
      final exam = Exam(
        id: 'exam3',
        title: 'Quiz',
        category: 'History',
        timeLimit: 10,
        questions: const [],
        createdAt: null,
        updatedAt: null,
      );
      final updated = exam.copyWith(title: 'Quiz 2', timeLimit: 15);
      expect(updated.id, 'exam3');
      expect(updated.title, 'Quiz 2');
      expect(updated.category, 'History');
      expect(updated.timeLimit, 15);
    });
  });
}
