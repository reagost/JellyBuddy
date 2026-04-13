import 'package:equatable/equatable.dart';
import 'course.dart';

class Question extends Equatable {
  final String id;
  final LevelType type;
  final String content;
  final String? audioUrl;
  final List<String>? codeSnippet;
  final List<Option>? options;
  final List<String> acceptedAnswers;
  final Difficulty difficulty;
  final String explanation;
  final List<String> relatedConcepts;
  final int estimatedSeconds;

  const Question({
    required this.id,
    required this.type,
    required this.content,
    this.audioUrl,
    this.codeSnippet,
    this.options,
    required this.acceptedAnswers,
    required this.difficulty,
    required this.explanation,
    required this.relatedConcepts,
    required this.estimatedSeconds,
  });

  @override
  List<Object?> get props => [id, type, content, audioUrl, codeSnippet, options, acceptedAnswers, difficulty, explanation, relatedConcepts, estimatedSeconds];
}

class Option extends Equatable {
  final String letter;
  final String content;
  final bool isCorrect;

  const Option({
    required this.letter,
    required this.content,
    required this.isCorrect,
  });

  @override
  List<Object?> get props => [letter, content, isCorrect];
}
