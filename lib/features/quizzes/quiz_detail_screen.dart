import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../auth/cubit/auth_cubit.dart';
import '../../models/quiz_model.dart';
import 'cubit/quiz_detail_cubit.dart';
import 'cubit/quiz_detail_state.dart';
import 'quizzes_repository.dart';
import 'edit_quiz_screen.dart';

class QuizDetailScreen extends StatelessWidget {
  const QuizDetailScreen({super.key, required this.quizId});
  final int quizId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => QuizDetailCubit(ctx.read<QuizzesRepository>(), quizId),
      child: _QuizDetailView(quizId: quizId),
    );
  }
}

class _QuizDetailView extends StatefulWidget {
  const _QuizDetailView({required this.quizId});
  final int quizId;

  @override
  State<_QuizDetailView> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<_QuizDetailView> {
  @override
  void initState() {
    super.initState();
    context.read<QuizDetailCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = context.read<AuthCubit>().state.user?.isStudent ?? false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        actions: [
          if (!isStudent)
            BlocBuilder<QuizDetailCubit, QuizDetailState>(
              builder: (context, state) {
                if (state.quiz == null) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit quiz',
                  onPressed: () async {
                    final updated = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(builder: (_) => EditQuizScreen(quiz: state.quiz!)),
                    );
                    if (updated == true && context.mounted) {
                      context.read<QuizDetailCubit>().load();
                    }
                  },
                );
              },
            ),
        ],
      ),
      body: BlocBuilder<QuizDetailCubit, QuizDetailState>(
        builder: (context, state) {
          if (state.status == DetailStatus.loading || state.status == DetailStatus.initial) {
            return const LoadingView();
          }
          if (state.status == DetailStatus.error && state.quiz == null) {
            return ErrorView(message: state.errorMessage ?? '', onRetry: () => context.read<QuizDetailCubit>().load());
          }
          final quiz = state.quiz!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(quiz.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                '${Labels.quizType(quiz.type)} • ${quiz.totalPoints} pts'
                '${quiz.session != null ? ' • ${quiz.session!.name}' : ''}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text('Due: ${AppDateUtils.dateTime(quiz.dueDate)}',
                  style: TextStyle(
                      color: quiz.isPastDue ? AppColors.danger : AppColors.textMuted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              if (isStudent)
                _StudentQuizBody(quiz: quiz, state: state)
              else
                _StaffSubmissionsList(quiz: quiz),
            ],
          );
        },
      ),
    );
  }
}

class _StudentQuizBody extends StatelessWidget {
  const _StudentQuizBody({required this.quiz, required this.state});
  final QuizDetail quiz;
  final QuizDetailState state;

  bool get _alreadySubmitted => quiz.submissions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuizDetailCubit>();

    if (state.submitStatus == SubmitStatus.done || _alreadySubmitted) {
      final score = state.score ?? (quiz.submissions.isNotEmpty ? quiz.submissions.first.score : 0);
      final total = state.totalPoints ?? quiz.totalPoints;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 48),
              const SizedBox(height: 12),
              const Text('Quiz submitted', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 6),
              Text('Your score: $score / $total',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
        ),
      );
    }

    if (quiz.isPastDue) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.timer_off_outlined, color: AppColors.danger, size: 40),
              SizedBox(height: 10),
              Text('The deadline for this quiz has passed', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    final allAnswered = quiz.questions.every((q) => state.answers.containsKey(q.id));

    return Column(
      children: [
        ...quiz.questions.map((q) => _QuestionCard(
              question: q,
              quizType: quiz.type,
              selected: state.answers[q.id],
              onSelect: (v) => cubit.answer(q.id, v),
            )),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: !allAnswered || state.submitStatus == SubmitStatus.submitting
                ? null
                : () async {
                    final confirm = await showConfirmDialog(context,
                        title: 'Submit Quiz',
                        message: 'Are you sure? You won\'t be able to change your answers after submitting.');
                    if (confirm) cubit.submit();
                  },
            child: state.submitStatus == SubmitStatus.submitting
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                : Text(allAnswered ? 'Submit Quiz' : 'Answer all questions first'),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.quizType,
    required this.selected,
    required this.onSelect,
  });

  final QuizQuestion question;
  final String quizType;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final options = quizType == 'true_false'
        ? const [('true', 'True'), ('false', 'False')]
        : [
            if (question.optionA != null) ('A', question.optionA!),
            if (question.optionB != null) ('B', question.optionB!),
            if (question.optionC != null) ('C', question.optionC!),
            if (question.optionD != null) ('D', question.optionD!),
          ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${question.order}. ${question.questionText}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
            Text('${question.points} pts', style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
            const SizedBox(height: 8),
            ...options.map((opt) => RadioListTile<String>(
                  value: opt.$1,
                  groupValue: selected,
                  onChanged: (v) => onSelect(v!),
                  title: Text(opt.$2),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                )),
          ],
        ),
      ),
    );
  }
}

class _StaffSubmissionsList extends StatelessWidget {
  const _StaffSubmissionsList({required this.quiz});
  final QuizDetail quiz;

  @override
  Widget build(BuildContext context) {
    if (quiz.submissions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: Text('No students have submitted this quiz yet', style: TextStyle(color: AppColors.textMuted))),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Submissions (${quiz.submissions.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ...quiz.submissions.map((s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(s.studentName ?? '-'),
                subtitle: Text(s.studentCode ?? ''),
                trailing: Text('${s.score}/${s.totalPoints}',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            )),
      ],
    );
  }
}
