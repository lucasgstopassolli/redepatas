import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:redepatas/core/constants/rio_do_sul_bairros.dart';
import 'package:redepatas/core/services/ibge_city_service.dart';
import 'package:redepatas/core/theme/app_theme.dart';
import 'package:redepatas/main.dart';
import 'package:redepatas/models/help_request_model.dart';
import 'package:redepatas/repositories/i_help_request_repository.dart';
import 'package:redepatas/repositories/sqlite_help_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

    // Abre a Tela de Detalhes do Pedido ("Cão caramelo") e testa o fluxo "Quero Ajudar"
    await tester.tap(find.text('Cão caramelo'));
    await tester.pumpAndSettle();
    expect(find.text('Detalhes do Pedido'), findsOneWidget);
    expect(find.text('Quero Ajudar este Animal'), findsOneWidget);

    await tester.tap(find.text('Quero Ajudar este Animal'));
    await tester.pumpAndSettle();
    expect(find.text('Confirmar apoio ao animal'), findsOneWidget);

    final confirmBtn = find.text('Confirmar Compromisso');
    await tester.ensureVisible(confirmBtn);
    await tester.pumpAndSettle();
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    expect(find.text('Marcar ajuda como Concluída'), findsOneWidget);

    // Volta para a tela principal
    await tester.pageBack();
    await tester.pumpAndSettle();

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

  test('Valida SqliteHelpRepository (seed inicial, create, assign e status)',
      () async {
    final sqliteRepo = SqliteHelpRepository(
      customDatabasePath: inMemoryDatabasePath,
    );

    // 1. Verifica os 3 seeds iniciais de Rio do Sul
    final initial = await sqliteRepo.getAllRequests();
    expect(initial.length, 3);
    expect(
      initial.map((r) => r.title),
      containsAll(['Cão caramelo', 'Gata cinza', 'Filhote malhado']),
    );

    // 2. Cria um novo pedido
    final novoPedido = HelpRequestModel(
      id: 'test_req_100',
      title: 'Cão idoso no abrigo de ônibus',
      species: AnimalSpecies.dog,
      needs: const [NeedType.water, NeedType.food, NeedType.shelter],
      urgency: UrgencyLevel.high,
      city: 'Rio do Sul',
      neighborhood: 'Budag',
      referencePoint: 'Em frente ao mercado',
      description: 'Precisa de água e cobertor.',
      status: RequestStatus.open,
      authorId: 'user_1',
      authorName: 'Lucas',
      createdAt: DateTime.now().add(const Duration(minutes: 5)),
    );
    await sqliteRepo.createRequest(novoPedido);

    final afterCreate = await sqliteRepo.getAllRequests();
    expect(afterCreate.length, 4);
    expect(afterCreate.first.id, 'test_req_100');
    expect(
      afterCreate.first.needs,
      equals([NeedType.water, NeedType.food, NeedType.shelter]),
    );

    // 3. Voluntário assume o pedido
    await sqliteRepo.assignVolunteer(
      requestId: 'test_req_100',
      volunteerId: 'vol_1',
      volunteerName: 'Ariel Jahn',
      commitment: 'Vou levar Alimento hoje',
    );
    final afterAssign = await sqliteRepo.getAllRequests();
    final updated = afterAssign.firstWhere((r) => r.id == 'test_req_100');
    expect(updated.status, RequestStatus.inProgress);
    expect(updated.helperName, 'Ariel Jahn');
    expect(updated.helperCommitment, 'Vou levar Alimento hoje');

    // 4. Conclui o pedido
    await sqliteRepo.updateStatus('test_req_100', RequestStatus.completed);
    final afterComplete = await sqliteRepo.getAllRequests();
    final completed = afterComplete.firstWhere((r) => r.id == 'test_req_100');
    expect(completed.status, RequestStatus.completed);

    await sqliteRepo.close();
  });

  test('Valida bairros de Rio do Sul e IbgeCityService (online e fallback)',
      () async {
    expect(bairrosRioDoSul, containsAll(['Centro', 'Canoas', 'Santana', 'Budag']));

    final mockOnlineClient = MockClient((request) async {
      final body = json.encode([
        {'nome': 'Agronômica'},
        {'nome': 'Ibirama'},
        {'nome': 'Lontras'},
        {'nome': 'Rio do Sul'},
      ]);
      return http.Response(body, 200);
    });
    final onlineService = IbgeCityService(client: mockOnlineClient);
    final cities = await onlineService.fetchSantaCatarinaCities();
    expect(cities, equals(['Agronômica', 'Ibirama', 'Lontras', 'Rio do Sul']));

    final mockOfflineClient = MockClient((request) async {
      throw Exception('Sem conexão');
    });
    final offlineService = IbgeCityService(client: mockOfflineClient);
    final fallbackCities = await offlineService.fetchSantaCatarinaCities();
    expect(fallbackCities, containsAll(['Rio do Sul', 'Lontras', 'Ibirama', 'Taió']));
  });
}
