import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/pager.dart';
import '../../core/widgets/app_snackbar.dart';
import 'cubit/instructors_list_cubit.dart';
import 'cubit/instructors_list_state.dart';
import 'instructors_repository.dart';

class InstructorsListScreen extends StatefulWidget {
  const InstructorsListScreen({super.key});

  @override
  State<InstructorsListScreen> createState() => _InstructorsListScreenState();
}

class _InstructorsListScreenState extends State<InstructorsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InstructorsListCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instructors')),
      body: Column(
        children: [
          SearchField(hint: 'Search instructors...', onChanged: (v) => context.read<InstructorsListCubit>().search(v)),
          Expanded(
            child: BlocBuilder<InstructorsListCubit, InstructorsListState>(
              builder: (context, state) {
                if (state.status == ListStatus.loading && state.items.isEmpty) return const LoadingView();
                if (state.status == ListStatus.error && state.items.isEmpty) {
                  return ErrorView(message: state.errorMessage ?? '', onRetry: () => context.read<InstructorsListCubit>().load());
                }
                if (state.items.isEmpty) {
                  return const EmptyState(message: 'No instructors found', icon: Icons.person_outline);
                }
                return RefreshIndicator(
                  onRefresh: () => context.read<InstructorsListCubit>().load(page: 1),
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, i) {
                      final ins = state.items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: ins.isActive ? AppColors.successLight : AppColors.dangerLight,
                            child: Icon(Icons.school_outlined, color: ins.isActive ? AppColors.success : AppColors.danger),
                          ),
                          title: Text(ins.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${ins.email ?? ''}\n${ins.sessionsCount} sessions'),
                          isThreeLine: true,
                          trailing: Switch(
                            value: ins.isActive,
                            onChanged: (_) async {
                              try {
                                await context.read<InstructorsRepository>().toggleStatus(ins.id);
                                if (context.mounted) context.read<InstructorsListCubit>().load(page: state.page);
                              } catch (_) {
                                if (context.mounted) AppSnackbar.error(context, 'Could not update status');
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          BlocBuilder<InstructorsListCubit, InstructorsListState>(
            builder: (context, state) => Pager(
              page: state.page,
              pageSize: state.pageSize,
              total: state.total,
              onPageChanged: (p) => context.read<InstructorsListCubit>().load(page: p),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('New Instructor'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final repo = context.read<InstructorsRepository>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Instructor'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email (optional)')),
                const SizedBox(height: 10),
                TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone (optional)')),
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
                await repo.create(name: nameCtrl.text.trim(), email: emailCtrl.text.trim(), phone: phoneCtrl.text.trim());
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  context.read<InstructorsListCubit>().load();
                  AppSnackbar.success(context, 'Added successfully');
                }
              } catch (_) {
                if (context.mounted) AppSnackbar.error(context, 'Could not add instructor');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
