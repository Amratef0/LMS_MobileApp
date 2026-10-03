import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/pager.dart';
import '../auth/cubit/auth_cubit.dart';
import 'cubit/quizzes_list_cubit.dart';
import 'cubit/quizzes_list_state.dart';
import 'create_quiz_screen.dart';
import 'quiz_detail_screen.dart';

class QuizzesListScreen extends StatefulWidget {
  const QuizzesListScreen({super.key});

  @override
  State<QuizzesListScreen> createState() => _QuizzesListScreenState();
}

class _QuizzesListScreenState extends State<QuizzesListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuizzesListCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = context.read<AuthCubit>().state.user?.isStaff ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Quizzes')),
      body: Column(
        children: [
          SearchField(hint: 'Search quizzes...', onChanged: (v) => context.read<QuizzesListCubit>().search(v)),
          Expanded(
            child: BlocBuilder<QuizzesListCubit, QuizzesListState>(
              builder: (context, state) {
                if (state.status == ListStatus.loading && state.items.isEmpty) return const LoadingView();
                if (state.status == ListStatus.error && state.items.isEmpty) {
                  return ErrorView(message: state.errorMessage ?? '', onRetry: () => context.read<QuizzesListCubit>().load());
                }
                if (state.items.isEmpty) {
                  return const EmptyState(message: 'No quizzes found', icon: Icons.quiz_outlined);
                }
                return RefreshIndicator(
                  onRefresh: () => context.read<QuizzesListCubit>().load(page: 1),
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, i) {
                      final q = state.items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child: const Icon(Icons.quiz_outlined, color: AppColors.primary),
                          ),
                          title: Text(q.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${Labels.quizType(q.type)} • ${q.session?.name ?? ''}\nDue: ${AppDateUtils.dateTime(q.dueDate)}',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => QuizDetailScreen(quizId: q.id)),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          BlocBuilder<QuizzesListCubit, QuizzesListState>(
            builder: (context, state) => Pager(
              page: state.page,
              pageSize: state.pageSize,
              total: state.total,
              onPageChanged: (p) => context.read<QuizzesListCubit>().load(page: p),
            ),
          ),
        ],
      ),
      floatingActionButton: isStaff
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
                );
                if (created == true && context.mounted) {
                  context.read<QuizzesListCubit>().load(page: 1);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('New Quiz'),
            )
          : null,
    );
  }
}
