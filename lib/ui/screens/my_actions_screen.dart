import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/help_request_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/help_request_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/request_card.dart';
import 'request_detail_screen.dart';

class MyActionsScreen extends StatelessWidget {
  const MyActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

    final auth = context.watch<AuthController>();
    final controller = context.watch<HelpRequestController>();
    final userId = auth.currentUser?.id ?? 'user_demo';

    final helpingList = controller.myHelpingRequests(userId);
    final createdList = controller.myCreatedRequests(userId);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Minhas Ações',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: secondaryTextColor,
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(
                text: 'Estou ajudando (${helpingList.length})',
              ),
              Tab(
                text: 'Criados por mim (${createdList.length})',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _RequestsSubTabList(
              requests: helpingList,
              emptyIcon: Icons.volunteer_activism_outlined,
              emptyTitle: 'Nenhum pedido assumido',
              emptySubtitle:
                  'No Mural de pedidos, abra um pedido aberto e confirme seu apoio para acompanhá-lo aqui.',
            ),
            _RequestsSubTabList(
              requests: createdList,
              emptyIcon: Icons.post_add_outlined,
              emptyTitle: 'Nenhum pedido publicado',
              emptySubtitle:
                  'Use a aba "Novo" sempre que avistar um animal que necessite de alimento, água ou abrigo.',
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestsSubTabList extends StatelessWidget {
  final List<HelpRequestModel> requests;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  const _RequestsSubTabList({
    required this.requests,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        description: emptySubtitle,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        final req = requests[index];
        return RequestCard(
          request: req,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RequestDetailScreen(requestId: req.id),
              ),
            );
          },
        );
      },
    );
  }
}
