import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/campaign_model.dart';
import '../../models/case_update_model.dart';
import '../../models/event_model.dart';
import '../../models/help_request_model.dart';
import '../../models/organization_model.dart';
import '../../models/shelter_animal_model.dart';

class AppDatabase {
  static const String dbFileName = 'redepatas_v1.db';
  static const int dbVersion = 2;

  static final AppDatabase instance = AppDatabase();

  final String? customDatabasePath;
  Database? _db;

  AppDatabase({this.customDatabasePath});

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String path;
    if (customDatabasePath != null) {
      path = customDatabasePath!;
    } else {
      final dbPath = await getDatabasesPath();
      path = p.join(dbPath, dbFileName);
    }

    return openDatabase(
      path,
      version: dbVersion,
      onCreate: (db, version) async {
        await _createV2Tables(db);
        await _seedInitialData(db, includeRequests: true);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _upgradeV1ToV2(db);
        }
      },
    );
  }

  Future<void> _createV2Tables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS help_requests (
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
        createdAt TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        organizationId TEXT,
        updatedAt TEXT,
        completedAt TEXT,
        photos TEXT,
        animalCount INTEGER DEFAULT 1,
        afterPhotoPath TEXT,
        reportedReason TEXT
      )
    ''');

    await _createOngTables(db);
  }

  Future<void> _createOngTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS organizations (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        city TEXT NOT NULL,
        phone TEXT,
        whatsapp TEXT,
        email TEXT,
        instagram TEXT,
        pixKey TEXT,
        pixName TEXT,
        logoPath TEXT,
        verified INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS volunteers (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        userName TEXT,
        userPhone TEXT,
        organizationId TEXT,
        skills TEXT,
        availability TEXT,
        hasVehicle INTEGER DEFAULT 0,
        radiusKm INTEGER DEFAULT 10,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS case_updates (
        id TEXT PRIMARY KEY,
        requestId TEXT NOT NULL,
        authorId TEXT NOT NULL,
        authorName TEXT NOT NULL,
        type TEXT NOT NULL,
        message TEXT NOT NULL,
        photoPath TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS shelter_animals (
        id TEXT PRIMARY KEY,
        organizationId TEXT NOT NULL,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        sex TEXT NOT NULL,
        ageGroup TEXT NOT NULL,
        size TEXT NOT NULL,
        temperament TEXT NOT NULL,
        health TEXT NOT NULL,
        vaccinated INTEGER DEFAULT 0,
        castrated INTEGER DEFAULT 0,
        status TEXT NOT NULL,
        photoPath TEXT,
        description TEXT NOT NULL,
        originRequestId TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS adoption_interests (
        id TEXT PRIMARY KEY,
        animalId TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        message TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS events (
        id TEXT PRIMARY KEY,
        organizationId TEXT NOT NULL,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        city TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        startsAt TEXT NOT NULL,
        endsAt TEXT,
        capacity INTEGER DEFAULT 20,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS event_signups (
        id TEXT PRIMARY KEY,
        eventId TEXT NOT NULL,
        userId TEXT NOT NULL,
        userName TEXT NOT NULL,
        phone TEXT,
        attended INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS campaigns (
        id TEXT PRIMARY KEY,
        organizationId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        kind TEXT NOT NULL,
        goalAmount REAL NOT NULL,
        currentAmount REAL DEFAULT 0,
        unit TEXT NOT NULL,
        deadline TEXT,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS donations (
        id TEXT PRIMARY KEY,
        campaignId TEXT NOT NULL,
        donorName TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeV1ToV2(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(help_requests)');
    final existingNames =
        columns.map((c) => c['name']?.toString() ?? '').toSet();

    final newColumns = <String, String>{
      'latitude': 'REAL',
      'longitude': 'REAL',
      'organizationId': 'TEXT',
      'updatedAt': 'TEXT',
      'completedAt': 'TEXT',
      'photos': 'TEXT',
      'animalCount': 'INTEGER DEFAULT 1',
      'afterPhotoPath': 'TEXT',
      'reportedReason': 'TEXT',
    };

    for (final entry in newColumns.entries) {
      if (!existingNames.contains(entry.key)) {
        await db.execute(
          'ALTER TABLE help_requests ADD COLUMN ${entry.key} ${entry.value}',
        );
      }
    }

    await _createOngTables(db);
    await _seedInitialData(db, includeRequests: false);
  }

  Future<void> _seedInitialData(
    Database db, {
    required bool includeRequests,
  }) async {
    if (includeRequests) {
      for (final req in initialSeedRequests()) {
        await db.insert(
          'help_requests',
          req.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }

    for (final org in initialSeedOrganizations()) {
      await db.insert(
        'organizations',
        org.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    for (final vol in initialSeedVolunteers()) {
      await db.insert(
        'volunteers',
        vol.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    for (final upd in initialSeedCaseUpdates()) {
      await db.insert(
        'case_updates',
        upd.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    for (final animal in initialSeedShelterAnimals()) {
      await db.insert(
        'shelter_animals',
        animal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    for (final event in initialSeedEvents()) {
      await db.insert(
        'events',
        event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    for (final campaign in initialSeedCampaigns()) {
      await db.insert(
        'campaigns',
        campaign.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  static List<HelpRequestModel> initialSeedRequests() {
    final now = DateTime.now();
    return [
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
        authorPhone: '47999112233',
        createdAt: now.subtract(const Duration(hours: 2)),
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
        referencePoint: 'Perto da ponte de Canoas, próximo ao ponto de ônibus',
        description:
            'Gatinha procurando abrigo da chuva, aparenta estar assustada.',
        status: RequestStatus.inProgress,
        authorId: 'user_seed_2',
        authorName: 'Carlos Eduardo',
        authorPhone: '47988223344',
        helperId: 'user_demo',
        helperName: 'Ariel Jahn',
        helperCommitment: 'Levando caixa de transporte e abrigo temporário hoje',
        createdAt: now.subtract(const Duration(hours: 5)),
        latitude: -27.2241,
        longitude: -49.6289,
      ),
      HelpRequestModel(
        id: 'seed_3',
        title: 'Filhote malhado',
        species: AnimalSpecies.dog,
        needs: const [NeedType.food, NeedType.shelter],
        urgency: UrgencyLevel.critical,
        city: 'Rio do Sul',
        neighborhood: 'Santana',
        referencePoint: 'Próximo à subida da UNIDAVI, calçada lateral',
        description:
            'Filhote sozinho próximo à calçada, precisa de acolhimento temporário urgente.',
        status: RequestStatus.open,
        authorId: 'user_demo',
        authorName: 'Lucas Gabriel Stopassoli',
        authorPhone: '47999556677',
        createdAt: now.subtract(const Duration(hours: 3, minutes: 20)),
        latitude: -27.2098,
        longitude: -49.6512,
      ),
    ];
  }

  static List<OrganizationModel> initialSeedOrganizations() {
    final now = DateTime.now();
    return [
      OrganizationModel(
        id: 'org_apad_demo',
        name: 'APAD Rio do Sul',
        description:
            'Associação Protetora dos Animais Desamparados de Rio do Sul. Atuação em resgate, castração, lar temporário e adoção responsável no Alto Vale.',
        city: 'Rio do Sul',
        phone: '4735210000',
        whatsapp: '47999110022',
        email: 'contato@apad.org.br',
        instagram: '@apad.riodosul',
        pixKey: '00.123.456/0001-99',
        pixName: 'APAD Rio do Sul',
        verified: true,
        createdAt: now.subtract(const Duration(days: 120)),
      ),
      OrganizationModel(
        id: 'org_patas_vale',
        name: 'Patas do Alto Vale',
        description:
            'Coletivo comunitário de protetores independentes focado em alimentação de colônias e feiras mensais de adoção.',
        city: 'Rio do Sul',
        phone: '47988445566',
        whatsapp: '47988445566',
        email: 'patasaltovale@exemplo.org',
        instagram: '@patasaltovale',
        pixKey: 'patasaltovale@exemplo.org',
        pixName: 'Coletivo Patas do Alto Vale',
        verified: true,
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    ];
  }

  static List<VolunteerProfileModel> initialSeedVolunteers() {
    final now = DateTime.now();
    return [
      VolunteerProfileModel(
        id: 'vol_demo_1',
        userId: 'user_demo',
        userName: 'Ariel Jahn',
        userPhone: '47999556677',
        organizationId: 'org_apad_demo',
        skills: const ['Transporte', 'Abrigo temporário', 'Alimentação'],
        availability: const ['Tarde', 'Fins de semana'],
        hasVehicle: true,
        radiusKm: 15,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      VolunteerProfileModel(
        id: 'vol_demo_2',
        userId: 'user_seed_1',
        userName: 'Mariana Souza',
        userPhone: '47999112233',
        organizationId: 'org_apad_demo',
        skills: const ['Alimentação', 'Divulgação', 'Resgate'],
        availability: const ['Manhã', 'Fins de semana'],
        hasVehicle: false,
        radiusKm: 8,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }

  static List<CaseUpdateModel> initialSeedCaseUpdates() {
    final now = DateTime.now();
    return [
      CaseUpdateModel(
        id: 'upd_seed_1',
        requestId: 'seed_1',
        authorId: 'user_seed_1',
        authorName: 'Mariana Souza',
        type: CaseUpdateType.criado,
        message: 'Pedido registrado no mural comunitário.',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      CaseUpdateModel(
        id: 'upd_seed_2',
        requestId: 'seed_2',
        authorId: 'user_seed_2',
        authorName: 'Carlos Eduardo',
        type: CaseUpdateType.criado,
        message: 'Gatinha avistada perto da ponte de Canoas sob chuva.',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      CaseUpdateModel(
        id: 'upd_seed_3',
        requestId: 'seed_2',
        authorId: 'user_demo',
        authorName: 'Ariel Jahn',
        type: CaseUpdateType.assumido,
        message: 'Levando caixa de transporte e abrigo temporário hoje.',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      CaseUpdateModel(
        id: 'upd_seed_4',
        requestId: 'seed_3',
        authorId: 'user_demo',
        authorName: 'Lucas Gabriel Stopassoli',
        type: CaseUpdateType.criado,
        message: 'Filhote encontrado sozinho próximo à subida da UNIDAVI.',
        createdAt: now.subtract(const Duration(hours: 3, minutes: 20)),
      ),
    ];
  }

  static List<ShelterAnimalModel> initialSeedShelterAnimals() {
    final now = DateTime.now();
    return [
      ShelterAnimalModel(
        id: 'animal_1',
        organizationId: 'org_apad_demo',
        name: 'Paçoca',
        species: AnimalSpecies.dog,
        sex: 'Macho',
        ageGroup: 'Adulto',
        size: 'Médio',
        temperament: 'Dócil e companheiro',
        health: 'Saudável, vermifugado',
        vaccinated: true,
        castrated: true,
        status: AnimalStatus.disponivel,
        description:
            'Resgatado no Centro após enchente. Adora passeios curtos e se dá bem com crianças e outros cães.',
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      ShelterAnimalModel(
        id: 'animal_2',
        organizationId: 'org_apad_demo',
        name: 'Luna',
        species: AnimalSpecies.cat,
        sex: 'Fêmea',
        ageGroup: 'Filhote',
        size: 'Pequeno',
        temperament: 'Curiosa e carinhosa',
        health: 'Vacinada (1ª dose), negativa para FIV/FeLV',
        vaccinated: true,
        castrated: false,
        status: AnimalStatus.larTemporario,
        description:
            'Precisa de lar temporário por 15 dias até completar o ciclo vacinal e castração.',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      ShelterAnimalModel(
        id: 'animal_3',
        organizationId: 'org_patas_vale',
        name: 'Thor',
        species: AnimalSpecies.dog,
        sex: 'Macho',
        ageGroup: 'Idoso',
        size: 'Grande',
        temperament: 'Calmo e protetor',
        health: 'Em acompanhamento veterinário de rotina',
        vaccinated: true,
        castrated: true,
        status: AnimalStatus.disponivel,
        description:
            'Senhorzinho tranquilo que busca um quintal seguro e muito carinho para a aposentadoria.',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
    ];
  }

  static List<CommunityEventModel> initialSeedEvents() {
    final now = DateTime.now();
    return [
      CommunityEventModel(
        id: 'evt_1',
        organizationId: 'org_apad_demo',
        title: 'Feira de Adoção na Praça Ermembergo',
        type: EventType.feiraAdocao,
        description:
            'Traga sua família para conhecer cães e gatos castrados e vacinados prontos para um novo lar.',
        city: 'Rio do Sul',
        address: 'Praça Ermembergo Pellizzetti, Centro',
        latitude: -27.2152,
        longitude: -49.6435,
        startsAt: now.add(const Duration(days: 4)),
        capacity: 30,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      CommunityEventModel(
        id: 'evt_2',
        organizationId: 'org_apad_demo',
        title: 'Mutirão de Alimentação e Limpeza do Abrigo',
        type: EventType.mutirao,
        description:
            'Ação coletiva para limpeza de canis, troca de água e organização de doações de ração.',
        city: 'Rio do Sul',
        address: 'Bairro Santana, sede comunitária',
        latitude: -27.2088,
        longitude: -49.6520,
        startsAt: now.add(const Duration(days: 7)),
        capacity: 15,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  static List<CampaignModel> initialSeedCampaigns() {
    final now = DateTime.now();
    return [
      CampaignModel(
        id: 'camp_1',
        organizationId: 'org_apad_demo',
        title: 'Ração para cães e gatos do mês',
        description:
            'Meta mensal para alimentar mais de 40 animais acolhidos e pontos comunitários de alimentação.',
        kind: CampaignKind.item,
        goalAmount: 120,
        currentAmount: 78,
        unit: 'kg',
        deadline: now.add(const Duration(days: 14)),
        status: 'ativa',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      CampaignModel(
        id: 'camp_2',
        organizationId: 'org_apad_demo',
        title: 'Fundo de Castração Solidária',
        description:
            'Arrecadação via Pix para custear 10 castrações de animais resgatados nos bairros Canoas e Budag.',
        kind: CampaignKind.dinheiro,
        goalAmount: 1800,
        currentAmount: 1150,
        unit: 'R\$',
        deadline: now.add(const Duration(days: 20)),
        status: 'ativa',
        createdAt: now.subtract(const Duration(days: 6)),
      ),
    ];
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
