import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/help_request_model.dart';
import 'i_help_request_repository.dart';

class SqliteHelpRepository implements IHelpRequestRepository {
  static const String _tableName = 'help_requests';
  final String? customDatabasePath;
  Database? _db;

  // Fallback em memória caso seja executado no navegador (Flutter Web)
  final List<HelpRequestModel> _webMemoryFallback = [];
  bool _webInitialized = false;

  SqliteHelpRepository({this.customDatabasePath});

  Future<Database?> get _database async {
    if (kIsWeb) {
      return null;
    }
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
      path = p.join(dbPath, 'redepatas_v1.db');
    }

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
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

        for (final seed in _initialSeedRequests()) {
          await db.insert(_tableName, seed.toMap());
        }
      },
    );
  }

  List<HelpRequestModel> _initialSeedRequests() {
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
        createdAt: now.subtract(const Duration(minutes: 40)),
      ),
    ];
  }

  @override
  Future<List<HelpRequestModel>> getAllRequests() async {
    final db = await _database;
    if (db == null) {
      if (!_webInitialized) {
        _webMemoryFallback.addAll(_initialSeedRequests());
        _webInitialized = true;
      }
      final list = List<HelpRequestModel>.from(_webMemoryFallback);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }

    final rows = await db.query(_tableName, orderBy: 'createdAt DESC');
    return rows.map(HelpRequestModel.fromMap).toList();
  }

  @override
  Future<void> createRequest(HelpRequestModel request) async {
    final db = await _database;
    if (db == null) {
      _webMemoryFallback.insert(0, request);
      return;
    }

    await db.insert(
      _tableName,
      request.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateRequest(HelpRequestModel request) async {
    final db = await _database;
    if (db == null) {
      final index = _webMemoryFallback.indexWhere((r) => r.id == request.id);
      if (index != -1) {
        _webMemoryFallback[index] = request;
      }
      return;
    }

    await db.update(
      _tableName,
      request.toMap(),
      where: 'id = ?',
      whereArgs: [request.id],
    );
  }

  @override
  Future<void> assignVolunteer({
    required String requestId,
    required String volunteerId,
    required String volunteerName,
    String? commitment,
  }) async {
    final db = await _database;
    if (db == null) {
      final index = _webMemoryFallback.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _webMemoryFallback[index] = _webMemoryFallback[index].copyWith(
          status: RequestStatus.inProgress,
          helperId: volunteerId,
          helperName: volunteerName,
          helperCommitment: commitment,
        );
      }
      return;
    }

    await db.update(
      _tableName,
      {
        'status': RequestStatus.inProgress.name,
        'helperId': volunteerId,
        'helperName': volunteerName,
        'helperCommitment': commitment,
      },
      where: 'id = ?',
      whereArgs: [requestId],
    );
  }

  @override
  Future<void> updateStatus(String requestId, RequestStatus newStatus) async {
    final db = await _database;
    if (db == null) {
      final index = _webMemoryFallback.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _webMemoryFallback[index] = _webMemoryFallback[index].copyWith(
          status: newStatus,
        );
      }
      return;
    }

    await db.update(
      _tableName,
      {'status': newStatus.name},
      where: 'id = ?',
      whereArgs: [requestId],
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
