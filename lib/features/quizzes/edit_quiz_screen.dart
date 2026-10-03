import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/quiz_model.dart';
import '../sessions/sessions_repository.dart';
import 'quizzes_repository.dart';
import 'cubit/edit_quiz_cubit.dart';

class EditQuizScreen extends StatelessWidget {
  const EditQuizScreen({super.key, required this.quiz});
  final QuizDetail quiz;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => EditQuizCubit(
        quizzesRepository: ctx.read<QuizzesRepository>(),
        sessionsRepository: ctx.read<SessionsRepository>(),
      )..loadOptions(),
      child: _EditQuizForm(quiz: quiz),
    );
  }
}

class _QuestionDraft {
  _QuestionDraft.empty();
  _QuestionDraft.fromQuestion(QuizQuestion q, String quizType) {
    controller.text = q.questionText;
    optionA.text = q.optionA ?? '';
    optionB.text = q.optionB ?? '';
    optionC.text = q.optionC ?? '';
    optionD.text = q.optionD ?? '';
    pointsCtrl.text = q.points.toString();
    if (quizType == 'true_false') {
      correctTf = q.correctAnswer ?? 'true';
    } else {
      correctMc = q.correctAnswer ?? 'A';
    }
  }

  final controller = TextEditingController();
  final optionA = TextEditingController();
  final optionB = TextEditingController();
  final optionC = TextEditingController();
  final optionD = TextEditingController();
  final pointsCtrl = TextEditingController(text: '1');
  String correctMc = 'A';
  String correctTf = 'true';
}

class _EditQuizForm extends StatefulWidget {
  const _EditQuizForm({required this.quiz});
  final QuizDetail quiz;

  @override
  State<_EditQuizForm> createState() => _EditQuizFormState();
}

class _EditQuizFormState extends State<_EditQuizForm> {
  final _formKey = GlobalKey<FormState>();
  late final _titleCtrl = TextEditingController(text: widget.quiz.title);
  late String _type = widget.quiz.type;
  late bool _isGraded = widget.quiz.isGraded;
  late int? _sessionId = widget.quiz.session?.id;
  late DateTime? _dueDate = widget.quiz.dueDate;
  late List<_QuestionDraft> _questions = widget.quiz.questions.isEmpty
      ? [_QuestionDraft.empty()]
      : widget.quiz.questions.map((q) => _QuestionDraft.fromQuestion(q, widget.quiz.type)).toList();

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _dueDate != null ? TimeOfDay.fromDateTime(_dueDate!) : const TimeOfDay(hour: 23, minute: 59),
    );
    setState(() => _dueDate = DateTime(date.year, date.month, date.day, time?.hour ?? 23, time?.minute ?? 59));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final questions = <Map<String, dynamic>>[];
    for (final q in _questions) {
      if (q.controller.text.trim().isEmpty) {
        AppSnackbar.error(context, 'Every question needs text');
        return;
      }
      if (_type == 'multiple_choice') {
        if ([q.optionA, q.optionB, q.optionC, q.optionD].any((c) => c.text.trim().isEmpty)) {
          AppSnackbar.error(context, 'Fill all 4 options for every multiple-choice question');
          return;
        }
        questions.add({
          'questionText': q.controller.text.trim(),
          'optionA': q.optionA.text.trim(),
          'optionB': q.optionB.text.trim(),
          'optionC': q.optionC.text.trim(),
          'optionD': q.optionD.text.trim(),
          'correctAnswer': q.correctMc,
          'points': int.tryParse(q.pointsCtrl.text) ?? 1,
        });
      } else {
        questions.add({
          'questionText': q.controller.text.trim(),
          'correctAnswer': q.correctTf,
          'points': int.tryParse(q.pointsCtrl.text) ?? 1,
        });
      }
    }
    context.read<EditQuizCubit>().submit(
          quizId: widget.quiz.id,
          title: _titleCtrl.text.trim(),
          type: _type,
          isGraded: _isGraded,
          dueDate: _dueDate,
          sessionId: _sessionId,
          questions: questions,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Quiz')),
      body: BlocConsumer<EditQuizCubit, EditQuizState>(
        listener: (context, state) {
          if (state.status == EditQuizStatus.done) {
            AppSnackbar.success(context, 'Quiz updated successfully');
            Navigator.of(context).pop(true);
          }
          if (state.status == EditQuizStatus.error) {
            AppSnackbar.error(context, state.errorMessage ?? 'Something went wrong');
          }
        },
        builder: (context, state) {
          if (state.status == EditQuizStatus.loadingOptions) return const LoadingView();
          final busy = state.status == EditQuizStatus.submitting;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Quiz title'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int?>(
                  value: _sessionId,
                  decoration: const InputDecoration(labelText: 'Linked session (optional)'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('— No session —')),
                    ...state.sessions.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                  ],
                  onChanged: (v) => setState(() => _sessionId = v),
                ),
                const SizedBox(height: 14),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'multiple_choice', label: Text('Multiple Choice')),
                    ButtonSegment(value: 'true_false', label: Text('True / False')),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() => _type = s.first),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Graded quiz'),
                  value: _isGraded,
                  onChanged: (v) => setState(() => _isGraded = v),
                ),
                OutlinedButton.icon(
                  onPressed: _pickDueDate,
                  icon: const Icon(Icons.event_outlined, size: 16),
                  label: Text(_dueDate == null ? 'Set due date (optional)' : _dueDate.toString()),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Questions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => setState(() => _questions.add(_QuestionDraft.empty())),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add question'),
                    ),
                  ],
                ),
                ...List.generate(_questions.length, (i) => _EditQuestionCard(
                      index: i,
                      draft: _questions[i],
                      type: _type,
                      onRemove: _questions.length > 1 ? () => setState(() => _questions.removeAt(i)) : null,
                    )),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: busy ? null : _submit,
                    child: busy
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                        : const Text('Save changes'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EditQuestionCard extends StatefulWidget {
  const _EditQuestionCard({required this.index, required this.draft, required this.type, this.onRemove});
  final int index;
  final _QuestionDraft draft;
  final String type;
  final VoidCallback? onRemove;

  @override
  State<_EditQuestionCard> createState() => _EditQuestionCardState();
}

class _EditQuestionCardState extends State<_EditQuestionCard> {
  @override
  Widget build(BuildContext context) {
    final d = widget.draft;
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Question ${widget.index + 1}', style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (widget.onRemove != null)
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                  ),
              ],
            ),
            TextField(
              controller: d.controller,
              decoration: const InputDecoration(labelText: 'Question text'),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            if (widget.type == 'multiple_choice') ...[
              TextField(controller: d.optionA, decoration: const InputDecoration(labelText: 'Option A')),
              const SizedBox(height: 8),
              TextField(controller: d.optionB, decoration: const InputDecoration(labelText: 'Option B')),
              const SizedBox(height: 8),
              TextField(controller: d.optionC, decoration: const InputDecoration(labelText: 'Option C')),
              const SizedBox(height: 8),
              TextField(controller: d.optionD, decoration: const InputDecoration(labelText: 'Option D')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: d.correctMc,
                decoration: const InputDecoration(labelText: 'Correct answer'),
                items: const [
                  DropdownMenuItem(value: 'A', child: Text('A')),
                  DropdownMenuItem(value: 'B', child: Text('B')),
                  DropdownMenuItem(value: 'C', child: Text('C')),
                  DropdownMenuItem(value: 'D', child: Text('D')),
                ],
                onChanged: (v) => setState(() => d.correctMc = v ?? 'A'),
              ),
            ] else
              DropdownButtonFormField<String>(
                value: d.correctTf,
                decoration: const InputDecoration(labelText: 'Correct answer'),
                items: const [
                  DropdownMenuItem(value: 'true', child: Text('True')),
                  DropdownMenuItem(value: 'false', child: Text('False')),
                ],
                onChanged: (v) => setState(() => d.correctTf = v ?? 'true'),
              ),
            const SizedBox(height: 10),
            TextField(
              controller: d.pointsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Points'),
            ),
          ],
        ),
      ),
    );
  }
}
