import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/app_snackbar.dart';
import '../instructors/instructors_repository.dart';
import '../groups/groups_repository.dart';
import 'sessions_repository.dart';
import 'cubit/create_session_cubit.dart';

/// Wraps [_CreateSessionForm] with its own cubit so it can be pushed from
/// anywhere without the caller wiring a BlocProvider.
class CreateSessionScreen extends StatelessWidget {
  const CreateSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => CreateSessionCubit(
        sessionsRepository: ctx.read<SessionsRepository>(),
        instructorsRepository: ctx.read<InstructorsRepository>(),
        groupsRepository: ctx.read<GroupsRepository>(),
      )..loadOptions(),
      child: const _CreateSessionForm(),
    );
  }
}

class _CreateSessionForm extends StatefulWidget {
  const _CreateSessionForm();

  @override
  State<_CreateSessionForm> createState() => _CreateSessionFormState();
}

class _CreateSessionFormState extends State<_CreateSessionForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _recordLinkCtrl = TextEditingController();

  int? _trainerId;
  int? _groupId;
  String _type = 'live';
  String _topic = 'technical';
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _recordLinkCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_trainerId == null || _groupId == null) {
      AppSnackbar.error(context, 'Please choose an instructor and a group');
      return;
    }
    final sessionDate = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    context.read<CreateSessionCubit>().submit(
          name: _nameCtrl.text.trim(),
          trainerId: _trainerId!,
          groupId: _groupId!,
          sessionDate: sessionDate,
          type: _type,
          topic: _topic,
          location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
          recordLink: _recordLinkCtrl.text.trim().isEmpty ? null : _recordLinkCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Session')),
      body: BlocConsumer<CreateSessionCubit, CreateSessionState>(
        listener: (context, state) {
          if (state.status == CreateSessionStatus.done) {
            AppSnackbar.success(context, 'Session created successfully');
            Navigator.of(context).pop(true);
          }
          if (state.status == CreateSessionStatus.error) {
            AppSnackbar.error(context, state.errorMessage ?? 'Something went wrong');
          }
        },
        builder: (context, state) {
          if (state.status == CreateSessionStatus.loadingOptions) {
            return const LoadingView();
          }
          final busy = state.status == CreateSessionStatus.submitting;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Session name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  value: _trainerId,
                  decoration: const InputDecoration(labelText: 'Instructor'),
                  items: state.instructors
                      .map((i) => DropdownMenuItem(value: i.id, child: Text(i.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _trainerId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  value: _groupId,
                  decoration: const InputDecoration(labelText: 'Group'),
                  items: state.groups
                      .map((g) => DropdownMenuItem(value: g.id, child: Text('${g.name} (${g.code})')))
                      .toList(),
                  onChanged: (v) => setState(() => _groupId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today_outlined, size: 16),
                        label: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.access_time, size: 16),
                        label: Text(_time.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('Session type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'live', label: Text('Live'), icon: Icon(Icons.videocam_outlined, size: 16)),
                    ButtonSegment(value: 'physical', label: Text('On-site'), icon: Icon(Icons.location_on_outlined, size: 16)),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() => _type = s.first),
                ),
                const SizedBox(height: 18),
                const Text('Topic', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'technical', label: Text('Technical')),
                    ButtonSegment(value: 'soft_skills', label: Text('Soft Skills')),
                  ],
                  selected: {_topic},
                  onSelectionChanged: (s) => setState(() => _topic = s.first),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(labelText: 'Location (optional)', prefixIcon: Icon(Icons.map_outlined)),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _recordLinkCtrl,
                  decoration: const InputDecoration(labelText: 'Recording / meeting link (optional)', prefixIcon: Icon(Icons.link)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: busy ? null : _submit,
                    child: busy
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                        : const Text('Create session'),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    state.instructors.isEmpty
                        ? 'No instructors yet — add one from Instructors first.'
                        : state.groups.isEmpty
                            ? 'No groups yet — add one from Groups first.'
                            : '',
                    style: const TextStyle(color: AppColors.danger, fontSize: 12),
                    textAlign: TextAlign.center,
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
