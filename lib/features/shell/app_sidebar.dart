import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../auth/cubit/auth_cubit.dart';

class NavItem {
  const NavItem({required this.label, required this.icon, required this.activeIcon});
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Left-hand sidebar navigation (a standard Flutter [Drawer]) — replaces the
/// old bottom nav bar. Opens via the hamburger icon Scaffold auto-adds to
/// the AppBar whenever `drawer:` is set, or via an edge swipe.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('LMS Pro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  final selected = i == selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: Material(
                      color: selected ? AppColors.primaryLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        leading: Icon(
                          selected ? item.activeIcon : item.icon,
                          color: selected ? AppColors.primary : AppColors.textMuted,
                          size: 22,
                        ),
                        title: Text(
                          item.label,
                          style: TextStyle(
                            color: selected ? AppColors.primary : AppColors.text,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14.5,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop(); // close the drawer
                          onSelect(i);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.danger, size: 22),
                title: const Text('Log Out', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onTap: () async {
                  Navigator.of(context).pop(); // close the drawer first
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
            if (user != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        user.name.isNotEmpty ? user.name.substring(0, 1) : '?',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(user.role,
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
