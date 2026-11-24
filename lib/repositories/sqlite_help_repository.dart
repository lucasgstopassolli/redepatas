import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../core/database/app_database.dart';
import '../models/help_request_model.dart';
import 'i_help_request_repository.dart';

class SqliteHelpRepository implements IHelpRequestRepository {
  static const String _tableName = 'help_requests';
  final AppDatabase _appDatabase;

  // Fallback em memória caso seja executado no navegador (Flutter Web)
  final List<HelpRequestModel> _webMemoryFallback = [];
  bool _webInitialized = false;

  SqliteHelpRepository({String? customDatabasePath, AppDatabase? database})
      : _appDatabase = database ??
            (customDatabasePath != null
                ? AppDatabase(customDatabasePath: customDatabasePath)
                : AppDatabase.instance);

  Future<Database?> get _database => _appDatabase.database;

  @override
  Future<List<HelpRequestModel>> getAllRequests() async {
    final db = await _database;
    if (db == null) {
      if (!_webInitialized) {
        _webMemoryFallback.addAll(AppDatabase.initialSeedRequests());
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
    final nowIso = DateTime.now().toIso8601String();
    final db = await _database;
    if (db == null) {
      final index = _webMemoryFallback.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _webMemoryFallback[index] = _webMemoryFallback[index].copyWith(
          status: RequestStatus.inProgress,
          helperId: volunteerId,
          helperName: volunteerName,
          helperCommitment: commitment,
          updatedAt: DateTime.now(),
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
        'updatedAt': nowIso,
      },
      where: 'id = ?',
      whereArgs: [requestId],
    );
  }

  @override
  Future<void> updateStatus(String requestId, RequestStatus newStatus) async {
    final now = DateTime.now();
    final nowIso = now.toIso8601String();
    final db = await _database;
    if (db == null) {
      final index = _webMemoryFallback.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _webMemoryFallback[index] = _webMemoryFallback[index].copyWith(
          status: newStatus,
          updatedAt: now,
          completedAt: newStatus == RequestStatus.completed ? now : null,
        );
      }
      return;
    }

    await db.update(
      _tableName,
      {
        'status': newStatus.name,
        'updatedAt': nowIso,
        if (newStatus == RequestStatus.completed) 'completedAt': nowIso,
      },
      where: 'id = ?',
      whereArgs: [requestId],
    );
  }

  Future<void> close() => _appDatabase.close();
}
