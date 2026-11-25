import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:redepatas/controllers/auth_controller.dart';
import 'package:redepatas/controllers/ong_controller.dart';
import 'package:redepatas/core/constants/rio_do_sul_bairros.dart';
import 'package:redepatas/core/database/app_database.dart';
import 'package:redepatas/core/services/ibge_city_service.dart';
import 'package:redepatas/core/services/location_service.dart';
import 'package:redepatas/core/services/report_export_service.dart';
import 'package:redepatas/core/theme/app_theme.dart';
import 'package:redepatas/main.dart';
import 'package:redepatas/models/campaign_model.dart';
import 'package:redepatas/models/case_update_model.dart';
import 'package:redepatas/models/event_model.dart';
import 'package:redepatas/models/help_request_model.dart';
import 'package:redepatas/models/organization_model.dart';
import 'package:redepatas/models/shelter_animal_model.dart';
import 'package:redepatas/models/user_model.dart';
import 'package:redepatas/repositories/i_help_request_repository.dart';
import 'package:redepatas/repositories/i_ong_repository.dart';
import 'package:redepatas/repositories/sqlite_help_repository.dart';
import 'package:redepatas/ui/screens/campaigns_screen.dart';
import 'package:redepatas/ui/screens/events_ongs_screen.dart';
import 'package:redepatas/ui/screens/home_requests_screen.dart';
import 'package:redepatas/ui/screens/role_selection_screen.dart';
import 'package:provider/provider.dart';
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
      latitude: -27.2156,
      longitude: -49.6431,
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
      _items[index] = _items[index].copyWith(
        status: newStatus,
        completedAt: newStatus == RequestStatus.completed ? DateTime.now() : null,
      );
    }
  }
}

class InMemoryOngRepository implements IOngRepository {
  final List<OrganizationModel> _orgs = AppDatabase.initialSeedOrganizations();
  final List<VolunteerProfileModel> _vols = AppDatabase.initialSeedVolunteers();
  final List<CaseUpdateModel> _updates = AppDatabase.initialSeedCaseUpdates();
  final List<ShelterAnimalModel> _animals =
      AppDatabase.initialSeedShelterAnimals();
  final List<AdoptionInterestModel> _interests = [];
  final List<CommunityEventModel> _events = AppDatabase.initialSeedEvents();
  final List<EventSignupModel> _signups = [];
  final List<CampaignModel> _campaigns = AppDatabase.initialSeedCampaigns();
  final List<DonationModel> _donations = [];

  @override
  Future<List<OrganizationModel>> getOrganizations() async => List.from(_orgs);

  @override
  Future<void> saveOrganization(OrganizationModel org) async {
    _orgs.removeWhere((o) => o.id == org.id);
    _orgs.add(org);
  }

  @override
  Future<List<VolunteerProfileModel>> getVolunteers() async => List.from(_vols);

  @override
  Future<void> saveVolunteer(VolunteerProfileModel volunteer) async {
    _vols.removeWhere((v) => v.id == volunteer.id);
    _vols.add(volunteer);
  }

  @override
  Future<List<CaseUpdateModel>> getCaseUpdates(String requestId) async =>
      _updates.where((u) => u.requestId == requestId).toList();

  @override
  Future<List<CaseUpdateModel>> getAllCaseUpdates() async => List.from(_updates);

  @override
  Future<void> addCaseUpdate(CaseUpdateModel update) async =>
      _updates.add(update);

  @override
  Future<List<ShelterAnimalModel>> getShelterAnimals() async =>
      List.from(_animals);

  @override
  Future<void> saveShelterAnimal(ShelterAnimalModel animal) async {
    _animals.removeWhere((a) => a.id == animal.id);
    _animals.insert(0, animal);
  }

  @override
  Future<List<AdoptionInterestModel>> getAdoptionInterests() async =>
      List.from(_interests);

  @override
  Future<void> addAdoptionInterest(AdoptionInterestModel interest) async =>
      _interests.insert(0, interest);

  @override
  Future<List<CommunityEventModel>> getEvents() async => List.from(_events);

  @override
  Future<void> saveEvent(CommunityEventModel event) async {
    _events.removeWhere((e) => e.id == event.id);
    _events.add(event);
  }

  @override
  Future<List<EventSignupModel>> getEventSignups() async => List.from(_signups);

  @override
  Future<void> addEventSignup(EventSignupModel signup) async =>
      _signups.insert(0, signup);

  @override
  Future<void> removeEventSignup(String eventId, String userId) async =>
      _signups.removeWhere((s) => s.eventId == eventId && s.userId == userId);

  @override
  Future<void> toggleSignupAttendance(String signupId, bool attended) async {}

  @override
  Future<List<CampaignModel>> getCampaigns() async => List.from(_campaigns);

  @override
  Future<void> saveCampaign(CampaignModel campaign) async {
    _campaigns.removeWhere((c) => c.id == campaign.id);
    _campaigns.insert(0, campaign);
  }

  @override
  Future<List<DonationModel>> getDonations() async => List.from(_donations);

  @override
  Future<void> addDonation(DonationModel donation) async =>
      _donations.insert(0, donation);
}

void main() {
  testWidgets(
      'Fluxo principal RedePatas: Onboarding, Welcome, Mural, Abas e Tema',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = InMemoryHelpRepository();
    final ongRepo = InMemoryOngRepository();

    await tester.pumpWidget(
      RedePatasApp(repository: repo, ongRepository: ongRepo),
    );
    await tester.pumpAndSettle();

    // 1. Primeiro acesso exibe Onboarding explicativo
    expect(find.text('Uma rede comunitária pelos animais de rua'), findsOneWidget);
    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();

    // 2. Verifica Tela de Boas-Vindas e tamanho mínimo de botão (56dp)
    expect(find.text('Toda ajuda conta.'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
    final enterButtonSize = tester.getSize(find.byType(FilledButton).first);
    expect(enterButtonSize.height, greaterThanOrEqualTo(56));

    // Entra no modo demonstração
    final demoButton = find.text('Entrar como Visitante / Demonstração');
    await tester.ensureVisible(demoButton);
    await tester.pumpAndSettle();
    await tester.tap(demoButton);
    await tester.pumpAndSettle();

    // 3. Verifica Mural Comunitário (Aba Início)
    expect(find.byType(HomeRequestsScreen), findsOneWidget);
    expect(find.text('Resumo da região'), findsOneWidget);
    expect(find.text('Cão caramelo'), findsOneWidget);

    // 4. Abre Detalhes do Pedido e testa "Quero Ajudar"
    await tester.ensureVisible(find.text('Cão caramelo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cão caramelo'));
    await tester.pumpAndSettle();
    expect(find.text('Detalhes do Pedido'), findsOneWidget);
    expect(find.text('Quero Ajudar este Animal'), findsOneWidget);

    await tester.tap(find.text('Quero Ajudar este Animal'));
    await tester.pumpAndSettle();
    final confirmBtn = find.text('Confirmar Compromisso');
    await tester.ensureVisible(confirmBtn);
    await tester.pumpAndSettle();
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    expect(find.text('Marcar ajuda como Concluída'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    // 5. Navega entre abas
    await tester.tap(find.byTooltip('Buscar'));
    await tester.pumpAndSettle();
    expect(find.text('Buscar e Filtrar'), findsOneWidget);

    await tester.tap(find.byTooltip('Pedidos'));
    await tester.pumpAndSettle();
    expect(find.text('Minhas Ações'), findsOneWidget);

    // 6. Minha área e troca suave de tema Claro/Escuro
    await tester.tap(find.byTooltip('Minha área'));
    await tester.pumpAndSettle();
    expect(find.text('Guia & Minha Área'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Tema do Aplicativo'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escuro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Claro'));
    await tester.pumpAndSettle();
  });

  test('Valida paleta terrosa, cache de ThemeData e AppSemanticColors', () {
    final light = AppTheme.lightTheme;
    final dark = AppTheme.darkTheme;

    expect(identical(light, AppTheme.lightTheme), isTrue);
    expect(identical(dark, AppTheme.darkTheme), isTrue);

    expect(light.colorScheme.primary.toARGB32(), 0xFFC85A32);
    expect(light.colorScheme.secondary.toARGB32(), 0xFFD48C46);
    expect(light.colorScheme.tertiary.toARGB32(), 0xFF5F7A61);
    expect(light.scaffoldBackgroundColor.toARGB32(), 0xFFFAF6F0);

    expect(dark.colorScheme.primary.toARGB32(), 0xFFE07A5F);
    expect(dark.scaffoldBackgroundColor.toARGB32(), 0xFF1A1412);
    expect(dark.colorScheme.surface.toARGB32(), 0xFF261E1B);

    expect(light.extension<AppSemanticColors>(), isNotNull);
    expect(dark.extension<AppSemanticColors>(), isNotNull);
  });

  test('Valida migração SQLite v1 -> v2 preservando dados antigos', () async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final tempDir = await Directory.systemTemp.createTemp('redepatas_mig_');
    final dbPath = '${tempDir.path}/test_mig.db';

    // Cria banco v1 com 1 registro legado
    final v1Db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE help_requests (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            species TEXT NOT NULL,
            needs TEXT NOT NULL,
            urgency TEXT NOT NULL,
            city TEXT NOT NULL,
            neighborhood TEXT NOT NULL,
            referencePoint TEXT NOT NULL,
            description TEXT NOT NULL,
            photoPath TEXT,
            status TEXT NOT NULL,
            authorId TEXT NOT NULL,
            authorName TEXT NOT NULL,
            authorPhone TEXT,
            helperId TEXT,
            helperName TEXT,
            helperCommitment TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.insert('help_requests', {
          'id': 'legacy_1',
          'title': 'Cão legado v1',
          'species': 'dog',
          'needs': 'water',
          'urgency': 'normal',
          'city': 'Rio do Sul',
          'neighborhood': 'Centro',
          'referencePoint': 'Praça',
          'description': 'Registro antigo',
          'status': 'open',
          'authorId': 'u1',
          'authorName': 'Lucas',
          'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        });
      },
    );
    await v1Db.close();

    // Abre via SqliteHelpRepository (AppDatabase v2)
    final repo = SqliteHelpRepository(customDatabasePath: dbPath);
    final requests = await repo.getAllRequests();
    expect(requests.length, 1);
    expect(requests.first.id, 'legacy_1');
    expect(requests.first.title, 'Cão legado v1');
    await repo.close();
    await tempDir.delete(recursive: true);
  });

  test('Valida métricas da ONG, Haversine, progresso de campanha e PDF/CSV',
      () async {
    final ongController = OngController(InMemoryOngRepository());
    await ongController.loadAll();

    final now = DateTime.now();
    final sampleRequests = [
      HelpRequestModel(
        id: 'm1',
        title: 'Crítico antigo',
        species: AnimalSpecies.dog,
        needs: const [NeedType.medical],
        urgency: UrgencyLevel.critical,
        city: 'Rio do Sul',
        neighborhood: 'Centro',
        referencePoint: 'Rua X',
        description: 'Ferido',
        status: RequestStatus.open,
        authorId: 'u1',
        authorName: 'Ana',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      HelpRequestModel(
        id: 'm2',
        title: 'Concluído 2h',
        species: AnimalSpecies.cat,
        needs: const [NeedType.food],
        urgency: UrgencyLevel.normal,
        city: 'Rio do Sul',
        neighborhood: 'Canoas',
        referencePoint: 'Rua Y',
        description: 'Alimentado',
        status: RequestStatus.completed,
        authorId: 'u1',
        authorName: 'Ana',
        createdAt: now.subtract(const Duration(hours: 5)),
        completedAt: now.subtract(const Duration(hours: 3)),
      ),
    ];

    final metrics = ongController.computeMetrics(sampleRequests);
    expect(metrics.openCount, 1);
    expect(metrics.completedCount, 1);
    expect(metrics.overdueCritical.length, 1);
    expect(metrics.avgResolutionHours, closeTo(2.0, 0.1));

    // Haversine
    final dist = LocationService.distanceKm(-27.2156, -49.6431, -27.2241, -49.6289);
    expect(dist, greaterThan(1.0));
    expect(dist, lessThan(3.0));
    expect(LocationService.formatDistance(0.45), '450 m');

    // Progresso de campanha
    final camp = CampaignModel(
      id: 'c1',
      organizationId: 'org1',
      title: 'Ração',
      description: 'Meta',
      kind: CampaignKind.item,
      goalAmount: 100,
      currentAmount: 50,
      unit: 'kg',
      createdAt: now,
    );
    expect(camp.progressPercent, 50);

    // Exportações CSV e PDF
    final csv = ReportExportService.buildRequestsCsv(sampleRequests);
    expect(csv, contains('Crítico antigo'));
    final pdfBytes = await ReportExportService.buildOngReportPdf(
      orgName: 'APAD Rio do Sul',
      periodLabel: '30 dias',
      metrics: metrics,
      requests: sampleRequests,
    );
    expect(pdfBytes.length, greaterThan(500));
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

  testWidgets(
      'Acessibilidade e QA (08): tela 360x640 e textScaler 1.3 sem overflow',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'redepatas_onboarding_done': true,
    });
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 640),
          textScaler: TextScaler.linear(1.3),
        ),
        child: RedePatasApp(
          repository: InMemoryHelpRepository(),
          ongRepository: InMemoryOngRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Toda ajuda conta.'), findsOneWidget);
    final demoBtn = find.text('Entrar como Visitante / Demonstração');
    await tester.ensureVisible(demoBtn);
    await tester.pumpAndSettle();
    await tester.tap(demoBtn);
    await tester.pumpAndSettle();

    expect(find.text('Registrar animal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Unit (09): HelpRequestModel legado/v2 e detecção de duplicidade', () {
    final legacyMap = {
      'id': 'leg_1',
      'title': 'Cão v1',
      'species': 'dog',
      'needs': 'water,food',
      'urgency': 'high',
      'city': 'Rio do Sul',
      'neighborhood': 'Centro',
      'referencePoint': 'Praça',
      'description': 'Sem campos v2',
      'status': 'open',
      'authorId': 'u1',
      'authorName': 'Ana',
      'createdAt': DateTime.now().toIso8601String(),
    };
    final req = HelpRequestModel.fromMap(legacyMap);
    expect(req.latitude, isNull);
    expect(req.animalCount, 1);

    final v2 = req.copyWith(latitude: -27.21, longitude: -49.64, animalCount: 2);
    final roundTrip = HelpRequestModel.fromMap(v2.toMap());
    expect(roundTrip.latitude, -27.21);
    expect(roundTrip.animalCount, 2);

    final ong = OngController(InMemoryOngRepository());
    final dup = ong.findPossibleDuplicate(
      allRequests: [v2],
      neighborhood: 'centro',
      species: AnimalSpecies.dog,
    );
    expect(dup?.id, 'leg_1');
  });

  testWidgets('Widget (09): Copiar Pix, inscrição em evento e escolha de papel',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final auth = AuthController();
    await auth.signInAsDemo(role: UserRole.volunteer);
    final ong = OngController(InMemoryOngRepository());
    await ong.loadAll();

    // 1. Campanhas: botão Copiar Pix
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: ong),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CampaignsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Copiar Pix'), findsOneWidget);

    // 2. Eventos: inscrição reduz vagas
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: ong),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const EventsOngsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('0/30 inscritos'), findsOneWidget);
    await tester.tap(find.text('Inscrever-se').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('1/30 inscritos'), findsOneWidget);

    // 3. Seleção de papel
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RoleSelectionScreen(popOnSelect: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('ONG / Protetor'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Confirmar perfil'), 200);
    await tester.tap(find.text('Confirmar perfil'));
    await tester.pumpAndSettle();
    expect(auth.currentUser?.role, UserRole.organization);
  });
}
