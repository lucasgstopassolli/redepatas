import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/help_request_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/help_request_model.dart';
import '../widgets/request_card.dart';
import 'request_detail_screen.dart';

class MyActionsScreen extends StatelessWidget {
  const MyActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.72),
            indicatorColor: Colors.white,
            indicatorWeight: 3,
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
              emptyTitle: 'Você ainda não assumiu nenhum pedido.',
              emptySubtitle:
                  'No Mural (aba Início), toque em um pedido aberto e clique em "Quero Ajudar este Animal" para acompanhá-lo por aqui.',
            ),
            _RequestsSubTabList(
              requests: createdList,
              emptyIcon: Icons.post_add_rounded,
              emptyTitle: 'Você ainda não cadastrou pedidos.',
              emptySubtitle:
                  'Use a aba "Novo" na barra inferior sempre que encontrar um animal precisando de água, alimento ou abrigo.',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

    if (requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                emptyIcon,
                size: 56,
                color: secondaryTextColor.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 14),
              Text(
                emptyTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: secondaryTextColor, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
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
