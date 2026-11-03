import 'package:flutter_test/flutter_test.dart';
import 'package:redepatas/core/theme/app_theme.dart';
import 'package:redepatas/main.dart';
import 'package:redepatas/models/help_request_model.dart';
import 'package:redepatas/repositories/i_help_request_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InMemoryHelpRepository implements IHelpRequestRepository {
  final List<HelpRequestModel> _items = [
    HelpRequestModel(
      id: 'seed_1',
      title: 'Cão caramelo',
      species: AnimalSpecies.dog,
      needs: const [NeedType.food, NeedType.water],
      urgency: UrgencyLevel.normal,
      city: 'Rio do Sul',
      neighborhood: 'Centro',
      referencePoint: 'Próximo à Praça Ermembergo Pellizzetti',
      description:
          'Cão dócil avistado próximo ao centro precisando de ração e água fresca.',
      status: RequestStatus.open,
      authorId: 'user_seed_1',
      authorName: 'Mariana Souza',
      createdAt: DateTime(2026, 11, 3, 10, 0),
    ),
    HelpRequestModel(
      id: 'seed_2',
      title: 'Gata cinza',
      species: AnimalSpecies.cat,
      needs: const [NeedType.shelter],
      urgency: UrgencyLevel.high,
      city: 'Rio do Sul',
      neighborhood: 'Canoas',
      referencePoint: 'Perto da ponte',
      description: 'Gatinha procurando abrigo da chuva.',
      status: RequestStatus.inProgress,
      authorId: 'user_seed_2',
      authorName: 'Carlos Eduardo',
      helperId: 'user_demo',
      helperName: 'Ariel Jahn',
      createdAt: DateTime(2026, 11, 3, 9, 0),
    ),
  ];

  @override
  Future<List<HelpRequestModel>> getAllRequests() async => List.from(_items);

  @override
  Future<void> createRequest(HelpRequestModel request) async {
    _items.insert(0, request);
  }

  @override
  Future<void> updateRequest(HelpRequestModel request) async {
    final index = _items.indexWhere((e) => e.id == request.id);
    if (index != -1) _items[index] = request;
  }

  @override
  Future<void> assignVolunteer({
    required String requestId,
    required String volunteerId,
    required String volunteerName,
    String? commitment,
  }) async {
    final index = _items.indexWhere((e) => e.id == requestId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        status: RequestStatus.inProgress,
        helperId: volunteerId,
        helperName: volunteerName,
        helperCommitment: commitment,
      );
    }
  }

  @override
  Future<void> updateStatus(
    String requestId,
    RequestStatus newStatus,
  ) async {
    final index = _items.indexWhere((e) => e.id == requestId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(status: newStatus);
    }
  }
}

void main() {
  testWidgets('Fluxo principal RedePatas: Boas-vindas, Mural e Abas', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repo = InMemoryHelpRepository();

    await tester.pumpWidget(RedePatasApp(repository: repo));
    await tester.pumpAndSettle();

    // Verifica Tela de Boas-Vindas
    expect(find.text('Toda ajuda conta.'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);

    // Entra no modo demonstração
    final demoButton = find.text('Entrar como Visitante / Demonstração');
    await tester.ensureVisible(demoButton);
    await tester.pumpAndSettle();
    await tester.tap(demoButton);
    await tester.pumpAndSettle();

    // Verifica Mural Comunitário (Aba Início)
    expect(find.text('Como você quer ajudar?'), findsOneWidget);
    expect(find.text('Cão caramelo'), findsOneWidget);
    expect(find.text('Gata cinza'), findsOneWidget);

    // Navega para Aba Pedidos (Minhas Ações)
    await tester.tap(find.text('Pedidos'));
    await tester.pumpAndSettle();
    expect(find.text('Minhas Ações'), findsOneWidget);

    // Navega para Aba Novo (Solicitar Ajuda)
    await tester.tap(find.text('Novo'));
    await tester.pumpAndSettle();
    expect(find.text('Novo pedido de apoio'), findsOneWidget);

    // Navega para Aba Minha área (Guia & Minha Área)
    await tester.tap(find.text('Minha área'));
    await tester.pumpAndSettle();
    expect(find.text('Guia & Minha Área'), findsOneWidget);
    expect(find.text('Tema do Aplicativo'), findsOneWidget);

    // Testa alternância do SegmentedButton<ThemeMode> (Claro / Escuro / Sistema)
    await tester.tap(find.text('🌙 Escuro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('☀️ Claro'));
    await tester.pumpAndSettle();
  });

  test('Valida paleta terrosa do Design System (AppTheme Claro e Escuro)', () {
    final light = AppTheme.lightTheme;
    final dark = AppTheme.darkTheme;

    expect(light.colorScheme.primary.toARGB32(), 0xFFC85A32);
    expect(light.colorScheme.secondary.toARGB32(), 0xFFD48C46);
    expect(light.colorScheme.tertiary.toARGB32(), 0xFF5F7A61);
    expect(light.scaffoldBackgroundColor.toARGB32(), 0xFFFAF6F0);

    expect(dark.colorScheme.primary.toARGB32(), 0xFFE07A5F);
    expect(dark.scaffoldBackgroundColor.toARGB32(), 0xFF1A1412);
    expect(dark.colorScheme.surface.toARGB32(), 0xFF261E1B);
  });
}
