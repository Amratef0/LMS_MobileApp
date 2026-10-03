import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/app_snackbar.dart';
import '../sessions/sessions_repository.dart';
import 'assignments_repository.dart';
import 'cubit/create_assignment_cubit.dart';

class CreateAssignmentScreen extends StatelessWidget {
  const CreateAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => CreateAssignmentCubit(
        assignmentsRepository: ctx.read<AssignmentsRepository>(),
        sessionsRepository: ctx.read<SessionsRepository>(),
      )..loadOptions(),
      child: const _CreateAssignmentForm(),
    );
  }
}

class _CreateAssignmentForm extends StatefulWidget {
  const _CreateAssignmentForm();

  @override
  State<_CreateAssignmentForm> createState() => _CreateAssignmentFormState();
}

class _CreateAssignmentFormState extends State<_CreateAssignmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isGraded = true;
  int? _sessionId;
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 23, minute: 59));
    setState(() => _dueDate = DateTime(date.year, date.month, date.day, time?.hour ?? 23, time?.minute ?? 59));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CreateAssignmentCubit>().submit(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          isGraded: _isGraded,
          dueDate: _dueDate,
          sessionId: _sessionId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Assignment')),
      body: BlocConsumer<CreateAssignmentCubit, CreateAssignmentState>(
        listener: (context, state) {
          if (state.status == CreateAssignmentStatus.done) {
            AppSnackbar.success(context, 'Assignment created successfully');
            Navigator.of(context).pop(true);
          }
          if (state.status == CreateAssignmentStatus.error) {
            AppSnackbar.error(context, state.errorMessage ?? 'Something went wrong');
          }
        },
        builder: (context, state) {
          if (state.status == CreateAssignmentStatus.loadingOptions) return const LoadingView();
          final busy = state.status == CreateAssignmentStatus.submitting;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Assignment title'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description (optional)', alignLabelWithHint: true),
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
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Graded assignment'),
                  value: _isGraded,
                  onChanged: (v) => setState(() => _isGraded = v),
                ),
                OutlinedButton.icon(
                  onPressed: _pickDueDate,
                  icon: const Icon(Icons.event_outlined, size: 16),
                  label: Text(_dueDate == null ? 'Set due date (optional)' : _dueDate.toString()),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: busy ? null : _submit,
                    child: busy
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                        : const Text('Create assignment'),
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
