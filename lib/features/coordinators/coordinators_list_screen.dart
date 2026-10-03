import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/pager.dart';
import '../../core/widgets/app_snackbar.dart';
import 'cubit/coordinators_list_cubit.dart';
import 'coordinators_repository.dart';

class CoordinatorsListScreen extends StatefulWidget {
  const CoordinatorsListScreen({super.key});

  @override
  State<CoordinatorsListScreen> createState() => _CoordinatorsListScreenState();
}

class _CoordinatorsListScreenState extends State<CoordinatorsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CoordinatorsListCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coordinators')),
      body: Column(
        children: [
          SearchField(hint: 'Search coordinators...', onChanged: (v) => context.read<CoordinatorsListCubit>().search(v)),
          Expanded(
            child: BlocBuilder<CoordinatorsListCubit, CoordinatorsListState>(
              builder: (context, state) {
                if (state.status == ListStatus.loading && state.items.isEmpty) return const LoadingView();
                if (state.status == ListStatus.error && state.items.isEmpty) {
                  return ErrorView(message: state.errorMessage ?? '', onRetry: () => context.read<CoordinatorsListCubit>().load());
                }
                if (state.items.isEmpty) {
                  return const EmptyState(message: 'No coordinators found', icon: Icons.badge_outlined);
                }
                return RefreshIndicator(
                  onRefresh: () => context.read<CoordinatorsListCubit>().load(page: 1),
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, i) {
                      final c = state.items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: c.isActive ? AppColors.successLight : AppColors.dangerLight,
                            child: Icon(Icons.badge_outlined, color: c.isActive ? AppColors.success : AppColors.danger),
                          ),
                          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${c.email}\n${c.groupsCount} group(s) assigned'),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          BlocBuilder<CoordinatorsListCubit, CoordinatorsListState>(
            builder: (context, state) => Pager(
              page: state.page,
              pageSize: state.pageSize,
              total: state.total,
              onPageChanged: (p) => context.read<CoordinatorsListCubit>().load(page: p),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('New Coordinator'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final repo = context.read<CoordinatorsRepository>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Coordinator'),
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
                await repo.create(
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  password: passwordCtrl.text,
                  phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  context.read<CoordinatorsListCubit>().load();
                  AppSnackbar.success(context, 'Coordinator added successfully');
                }
              } catch (_) {
                if (context.mounted) AppSnackbar.error(context, 'Could not add coordinator');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
