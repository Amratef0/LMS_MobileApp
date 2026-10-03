import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/assignment_model.dart';
import '../auth/cubit/auth_cubit.dart';
import 'cubit/assignment_detail_cubit.dart';
import 'cubit/assignment_detail_state.dart';
import 'assignments_repository.dart';
import 'edit_assignment_screen.dart';

class AssignmentDetailScreen extends StatelessWidget {
  const AssignmentDetailScreen({super.key, required this.assignmentId});
  final int assignmentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => AssignmentDetailCubit(ctx.read<AssignmentsRepository>(), assignmentId),
      child: _AssignmentDetailView(assignmentId: assignmentId),
    );
  }
}

class _AssignmentDetailView extends StatefulWidget {
  const _AssignmentDetailView({required this.assignmentId});
  final int assignmentId;

  @override
  State<_AssignmentDetailView> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<_AssignmentDetailView> {
  final _linkCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AssignmentDetailCubit>().load();
  }

  @override
  void dispose() {
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndSubmitFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result == null || result.files.single.path == null) return;
    if (!mounted) return;
    context.read<AssignmentDetailCubit>().submitFile(result.files.single.path!, result.files.single.name);
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = context.read<AuthCubit>().state.user?.isStudent ?? false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment'),
        actions: [
          if (!isStudent)
            BlocBuilder<AssignmentDetailCubit, AssignmentDetailState>(
              builder: (context, state) {
                if (state.data == null) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit assignment',
                  onPressed: () async {
                    final updated = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(builder: (_) => EditAssignmentScreen(assignment: state.data!)),
                    );
                    if (updated == true && context.mounted) {
                      context.read<AssignmentDetailCubit>().load();
                    }
                  },
                );
              },
            ),
        ],
      ),
      body: BlocConsumer<AssignmentDetailCubit, AssignmentDetailState>(
        listenWhen: (p, c) => c.errorMessage != null && c.errorMessage != p.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) AppSnackbar.error(context, state.errorMessage!);
          if (state.submitStatus == SubmitStatus.done) AppSnackbar.success(context, 'Assignment submitted successfully');
        },
        builder: (context, state) {
          if (state.status == DetailStatus.loading || state.status == DetailStatus.initial) {
            return const LoadingView();
          }
          if (state.status == DetailStatus.error && state.data == null) {
            return ErrorView(message: state.errorMessage ?? '', onRetry: () => context.read<AssignmentDetailCubit>().load());
          }
          final data = state.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(data.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              if (data.session != null)
                Text(data.session!.name, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const SizedBox(height: 4),
              Text('Due: ${AppDateUtils.dateTime(data.dueDate)}',
                  style: TextStyle(
                      color: data.isPastDue ? AppColors.danger : AppColors.textMuted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
              if (data.description != null && data.description!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(data.description!),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (isStudent) _studentSection(context, data, state) else _staffSection(context, data),
            ],
          );
        },
      ),
    );
  }

  Widget _studentSection(BuildContext context, dynamic data, AssignmentDetailState state) {
    if (data.mySubmission != null) {
      final sub = data.mySubmission;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 40),
              const SizedBox(height: 10),
              const Text('Assignment submitted', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(AppDateUtils.dateTime(sub.submittedAt), style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
              if (sub.grade != null) ...[
                const SizedBox(height: 10),
                Text('Grade: ${sub.grade}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                if (sub.gradeFeedback != null && sub.gradeFeedback!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(sub.gradeFeedback!, textAlign: TextAlign.center),
                  ),
              ],
            ],
          ),
        ),
      );
    }

    if (data.isPastDue) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.timer_off_outlined, color: AppColors.danger, size: 36),
              SizedBox(height: 8),
              Text('The deadline for this assignment has passed'),
            ],
          ),
        ),
      );
    }

    final busy = state.submitStatus == SubmitStatus.uploading || state.submitStatus == SubmitStatus.submitting;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Submit assignment', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: busy ? null : _pickAndSubmitFile,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(busy ? 'Uploading...' : 'Upload a PDF file'),
            ),
            const SizedBox(height: 10),
            const Row(children: [
              Expanded(child: Divider()),
              Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('or', style: TextStyle(color: AppColors.textMuted))),
              Expanded(child: Divider()),
            ]),
            const SizedBox(height: 10),
            TextField(
              controller: _linkCtrl,
              decoration: const InputDecoration(labelText: 'Link (Google Drive, GitHub...)', prefixIcon: Icon(Icons.link)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: busy || _linkCtrl.text.trim().isEmpty
                  ? null
                  : () => context.read<AssignmentDetailCubit>().submitLink(_linkCtrl.text.trim()),
              child: const Text('Submit link'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _staffSection(BuildContext context, dynamic data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Submissions (${data.submissions.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (data.submissions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No submissions yet', style: TextStyle(color: AppColors.textMuted))),
          ),
        ...data.submissions.map<Widget>((s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(s.studentName ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        if (s.grade != null)
                          Text('${s.grade}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            final url = s.submissionType == 'link' ? s.link : s.fileUrl;
                            if (url != null) launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                          },
                          icon: Icon(s.submissionType == 'link' ? Icons.link : Icons.picture_as_pdf_outlined, size: 16),
                          label: Text(s.submissionType == 'link' ? 'Open link' : 'Open file'),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _openGradeDialog(context, data.id, s),
                          icon: const Icon(Icons.grade_outlined, size: 16),
                          label: Text(s.grade == null ? 'Grade' : 'Edit grade'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
        if (data.missedStudents.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Not submitted yet (${data.missedStudents.length})',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.danger)),
          const SizedBox(height: 8),
          ...data.missedStudents.map<Widget>((m) => ListTile(
                dense: true,
                leading: const Icon(Icons.person_off_outlined, color: AppColors.danger, size: 20),
                title: Text(m.name),
                subtitle: m.studentCode != null ? Text(m.studentCode!) : null,
              )),
        ],
      ],
    );
  }

  void _openGradeDialog(BuildContext context, int assignmentId, AssignmentSubmissionRow submission) {
    final cubit = context.read<AssignmentDetailCubit>();
    final gradeCtrl = TextEditingController(text: submission.grade?.toString() ?? '');
    final feedbackCtrl = TextEditingController(text: submission.gradeFeedback ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Grade ${submission.studentName ?? ''}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gradeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Grade'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: feedbackCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Feedback (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final grade = int.tryParse(gradeCtrl.text.trim());
              if (grade == null) return;
              Navigator.of(ctx).pop();
              final ok = await cubit.grade(submission.id, grade, feedbackCtrl.text.trim());
              if (ok && context.mounted) AppSnackbar.success(context, 'Grade saved');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
