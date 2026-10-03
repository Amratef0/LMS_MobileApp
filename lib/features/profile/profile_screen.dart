import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/app_snackbar.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/auth_repository.dart';
import '../tickets/tickets_list_screen.dart';
import '../tickets/tickets_repository.dart';
import '../tickets/cubit/tickets_list_cubit.dart';
import 'cubit/change_password_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    (user?.name.isNotEmpty ?? false) ? user!.name.substring(0, 1) : '?',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: const TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(999)),
                  child: Text(Labels.role(user?.role ?? ''),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          if (user?.isStudent ?? false) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.support_agent_outlined, color: AppColors.primary),
                title: const Text('Support Tickets'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (ctx) => TicketsListCubit(ctx.read<TicketsRepository>(), isStudent: true),
                    child: const TicketsListScreen(),
                  ),
                )),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_reset_outlined, color: AppColors.primary),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openChangePasswordSheet(context),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text('Log Out', style: TextStyle(color: AppColors.danger)),
              onTap: () async {
                final confirm = await showConfirmDialog(
                  context,
                  title: 'Log Out',
                  message: 'Are you sure you want to log out of your account?',
                  confirmLabel: 'Log Out',
                  danger: true,
                );
                if (confirm && context.mounted) context.read<AuthCubit>().logout();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openChangePasswordSheet(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: BlocProvider(
          create: (ctx) => ChangePasswordCubit(ctx.read<AuthRepository>()),
          child: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
            listener: (ctx, state) {
              if (state.status == ChangePasswordStatus.done) {
                Navigator.of(sheetCtx).pop();
                AppSnackbar.success(context, 'Password changed successfully');
              }
              if (state.status == ChangePasswordStatus.error) {
                AppSnackbar.error(context, state.errorMessage ?? '');
              }
            },
            builder: (ctx, state) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: currentCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Current password'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: newCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'New password'),
                      validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: state.status == ChangePasswordStatus.submitting
                            ? null
                            : () {
                                if (!formKey.currentState!.validate()) return;
                                ctx.read<ChangePasswordCubit>().submit(currentCtrl.text, newCtrl.text);
                              },
                        child: state.status == ChangePasswordStatus.submitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Save'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
