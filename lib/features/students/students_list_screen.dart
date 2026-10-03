import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/pager.dart';
import '../../core/widgets/app_snackbar.dart';
import 'cubit/students_list_cubit.dart';
import 'cubit/students_list_state.dart';
import 'students_repository.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentsListCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: Column(
        children: [
          SearchField(hint: 'Search by name, email or code...', onChanged: (v) => context.read<StudentsListCubit>().search(v)),
          Expanded(
            child: BlocBuilder<StudentsListCubit, StudentsListState>(
              builder: (context, state) {
                if (state.status == ListStatus.loading && state.items.isEmpty) return const LoadingView();
                if (state.status == ListStatus.error && state.items.isEmpty) {
                  return ErrorView(message: state.errorMessage ?? '', onRetry: () => context.read<StudentsListCubit>().load());
                }
                if (state.items.isEmpty) {
                  return const EmptyState(message: 'No students found', icon: Icons.person_outline);
                }
                return RefreshIndicator(
                  onRefresh: () => context.read<StudentsListCubit>().load(page: 1),
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, i) {
                      final s = state.items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: s.isActive ? AppColors.successLight : AppColors.dangerLight,
                            child: Icon(Icons.person_outline, color: s.isActive ? AppColors.success : AppColors.danger),
                          ),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${s.email}\n${s.groupName ?? 'No group'} • ${Labels.gender(s.gender)}',
                          ),
                          isThreeLine: true,
                          trailing: s.studentCode != null
                              ? Text(s.studentCode!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))
                              : null,
                          onTap: () => _showStudentSheet(context, s),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          BlocBuilder<StudentsListCubit, StudentsListState>(
            builder: (context, state) => Pager(
              page: state.page,
              pageSize: state.pageSize,
              total: state.total,
              onPageChanged: (p) => context.read<StudentsListCubit>().load(page: p),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('New Student'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showStudentSheet(BuildContext context, dynamic s) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Email: ${s.email}'),
            if (s.phone != null) Text('Phone: ${s.phone}'),
            if (s.city != null) Text('City: ${s.city}'),
            Text('Group: ${s.groupName ?? '-'}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final repo = context.read<StudentsRepository>();
                  try {
                    await repo.toggleActive(s.id, !s.isActive);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    if (context.mounted) {
                      context.read<StudentsListCubit>().load();
                      AppSnackbar.success(context, s.isActive ? 'Account deactivated' : 'Account activated');
                    }
                  } catch (_) {
                    if (context.mounted) AppSnackbar.error(context, 'Something went wrong, please try again');
                  }
                },
                icon: Icon(s.isActive ? Icons.block : Icons.check_circle_outline),
                label: Text(s.isActive ? 'Deactivate account' : 'Activate account'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final repo = context.read<StudentsRepository>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Student'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email address'),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Initial password'),
                  validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                await repo.create(name: nameCtrl.text.trim(), email: emailCtrl.text.trim(), password: passwordCtrl.text);
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  context.read<StudentsListCubit>().load();
                  AppSnackbar.success(context, 'Student added successfully');
                }
              } catch (_) {
                if (context.mounted) AppSnackbar.error(context, 'Could not add student');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
