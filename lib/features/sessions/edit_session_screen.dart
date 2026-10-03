import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/session_model.dart';
import '../instructors/instructors_repository.dart';
import 'sessions_repository.dart';
import 'cubit/edit_session_cubit.dart';

class EditSessionScreen extends StatelessWidget {
  const EditSessionScreen({super.key, required this.session});
  final SessionDetail session;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => EditSessionCubit(
        sessionsRepository: ctx.read<SessionsRepository>(),
        instructorsRepository: ctx.read<InstructorsRepository>(),
      )..loadOptions(),
      child: _EditSessionForm(session: session),
    );
  }
}

class _EditSessionForm extends StatefulWidget {
  const _EditSessionForm({required this.session});
  final SessionDetail session;

  @override
  State<_EditSessionForm> createState() => _EditSessionFormState();
}

class _EditSessionFormState extends State<_EditSessionForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.session.name);
  late final _locationCtrl = TextEditingController(text: widget.session.location ?? '');

  late int? _trainerId = widget.session.trainer.id;
  late String _type = widget.session.type;
  late String _topic = widget.session.topic;
  late DateTime _date = widget.session.sessionDate ?? DateTime.now();
  late TimeOfDay _time = widget.session.sessionDate != null
      ? TimeOfDay.fromDateTime(widget.session.sessionDate!)
      : const TimeOfDay(hour: 18, minute: 0);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
    if (_trainerId == null) {
      AppSnackbar.error(context, 'Please choose an instructor');
      return;
    }
    final sessionDate = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    context.read<EditSessionCubit>().submit(
          sessionId: widget.session.id,
          name: _nameCtrl.text.trim(),
          trainerId: _trainerId!,
          sessionDate: sessionDate,
          type: _type,
          topic: _topic,
          location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Session')),
      body: BlocConsumer<EditSessionCubit, EditSessionState>(
        listener: (context, state) {
          if (state.status == EditSessionStatus.done) {
            AppSnackbar.success(context, 'Session updated successfully');
            Navigator.of(context).pop(true);
          }
          if (state.status == EditSessionStatus.error) {
            AppSnackbar.error(context, state.errorMessage ?? 'Something went wrong');
          }
        },
        builder: (context, state) {
          if (state.status == EditSessionStatus.loadingOptions) return const LoadingView();
          final busy = state.status == EditSessionStatus.submitting;
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
