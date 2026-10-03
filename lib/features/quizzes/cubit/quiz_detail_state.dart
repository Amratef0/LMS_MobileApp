import 'package:equatable/equatable.dart';
import '../../../models/quiz_model.dart';

enum DetailStatus { initial, loading, ready, error }
enum SubmitStatus { idle, submitting, done, error }

class QuizDetailState extends Equatable {
  const QuizDetailState({
    this.status = DetailStatus.initial,
    this.quiz,
    this.answers = const {},
    this.submitStatus = SubmitStatus.idle,
    this.score,
    this.totalPoints,
    this.errorMessage,
  });

  final DetailStatus status;
  final QuizDetail? quiz;
  final Map<int, String> answers;
  final SubmitStatus submitStatus;
  final int? score;
  final int? totalPoints;
  final String? errorMessage;

  QuizDetailState copyWith({
    DetailStatus? status,
    QuizDetail? quiz,
    Map<int, String>? answers,
    SubmitStatus? submitStatus,
    int? score,
    int? totalPoints,
    String? errorMessage,
  }) =>
      QuizDetailState(
        status: status ?? this.status,
        quiz: quiz ?? this.quiz,
        answers: answers ?? this.answers,
        submitStatus: submitStatus ?? this.submitStatus,
        score: score ?? this.score,
        totalPoints: totalPoints ?? this.totalPoints,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, quiz, answers, submitStatus, score, totalPoints, errorMessage];
}
