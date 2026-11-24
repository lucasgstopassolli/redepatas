import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../core/database/app_database.dart';
import '../models/campaign_model.dart';
import '../models/case_update_model.dart';
import '../models/event_model.dart';
import '../models/organization_model.dart';
import '../models/shelter_animal_model.dart';
import 'i_ong_repository.dart';

class SqliteOngRepository implements IOngRepository {
  final AppDatabase _appDatabase;

  // Fallback em memória para Flutter Web
  bool _webInit = false;
  final List<OrganizationModel> _webOrgs = [];
  final List<VolunteerProfileModel> _webVolunteers = [];
  final List<CaseUpdateModel> _webUpdates = [];
  final List<ShelterAnimalModel> _webAnimals = [];
  final List<AdoptionInterestModel> _webInterests = [];
  final List<CommunityEventModel> _webEvents = [];
  final List<EventSignupModel> _webSignups = [];
  final List<CampaignModel> _webCampaigns = [];
  final List<DonationModel> _webDonations = [];

  SqliteOngRepository({AppDatabase? database})
      : _appDatabase = database ?? AppDatabase.instance;

  Future<Database?> get _db => _appDatabase.database;

  void _ensureWebInit() {
    if (_webInit) return;
    _webOrgs.addAll(AppDatabase.initialSeedOrganizations());
    _webVolunteers.addAll(AppDatabase.initialSeedVolunteers());
    _webUpdates.addAll(AppDatabase.initialSeedCaseUpdates());
    _webAnimals.addAll(AppDatabase.initialSeedShelterAnimals());
    _webEvents.addAll(AppDatabase.initialSeedEvents());
    _webCampaigns.addAll(AppDatabase.initialSeedCampaigns());
    _webInit = true;
  }

  @override
  Future<List<OrganizationModel>> getOrganizations() async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      return List.from(_webOrgs);
    }
    final rows = await db.query('organizations', orderBy: 'name ASC');
    return rows.map(OrganizationModel.fromMap).toList();
  }

  @override
  Future<void> saveOrganization(OrganizationModel org) async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      _webOrgs.removeWhere((o) => o.id == org.id);
      _webOrgs.add(org);
      return;
    }
    await db.insert(
      'organizations',
      org.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<VolunteerProfileModel>> getVolunteers() async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      return List.from(_webVolunteers);
    }
    final rows = await db.query('volunteers', orderBy: 'createdAt DESC');
    return rows.map(VolunteerProfileModel.fromMap).toList();
  }

  @override
  Future<void> saveVolunteer(VolunteerProfileModel volunteer) async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      _webVolunteers.removeWhere((v) => v.id == volunteer.id);
      _webVolunteers.insert(0, volunteer);
      return;
    }
    await db.insert(
      'volunteers',
      volunteer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<CaseUpdateModel>> getCaseUpdates(String requestId) async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      return _webUpdates.where((u) => u.requestId == requestId).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    final rows = await db.query(
      'case_updates',
      where: 'requestId = ?',
      whereArgs: [requestId],
      orderBy: 'createdAt ASC',
    );
    return rows.map(CaseUpdateModel.fromMap).toList();
  }

  @override
  Future<List<CaseUpdateModel>> getAllCaseUpdates() async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      return List.from(_webUpdates);
    }
    final rows = await db.query('case_updates', orderBy: 'createdAt ASC');
    return rows.map(CaseUpdateModel.fromMap).toList();
  }

  @override
  Future<void> addCaseUpdate(CaseUpdateModel update) async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      _webUpdates.add(update);
      return;
    }
    await db.insert(
      'case_updates',
      update.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<ShelterAnimalModel>> getShelterAnimals() async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      return List.from(_webAnimals);
    }
    final rows = await db.query('shelter_animals', orderBy: 'createdAt DESC');
    return rows.map(ShelterAnimalModel.fromMap).toList();
  }

  @override
  Future<void> saveShelterAnimal(ShelterAnimalModel animal) async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      _webAnimals.removeWhere((a) => a.id == animal.id);
      _webAnimals.insert(0, animal);
      return;
    }
    await db.insert(
      'shelter_animals',
      animal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<AdoptionInterestModel>> getAdoptionInterests() async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      return List.from(_webInterests);
    }
    final rows =
        await db.query('adoption_interests', orderBy: 'createdAt DESC');
    return rows.map(AdoptionInterestModel.fromMap).toList();
  }

  @override
  Future<void> addAdoptionInterest(AdoptionInterestModel interest) async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      _webInterests.insert(0, interest);
      return;
    }
    await db.insert(
      'adoption_interests',
      interest.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<CommunityEventModel>> getEvents() async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      return List.from(_webEvents);
    }
    final rows = await db.query('events', orderBy: 'startsAt ASC');
    return rows.map(CommunityEventModel.fromMap).toList();
  }

  @override
  Future<void> saveEvent(CommunityEventModel event) async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      _webEvents.removeWhere((e) => e.id == event.id);
      _webEvents.add(event);
      return;
    }
    await db.insert(
      'events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<EventSignupModel>> getEventSignups() async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      return List.from(_webSignups);
    }
    final rows = await db.query('event_signups', orderBy: 'createdAt DESC');
    return rows.map(EventSignupModel.fromMap).toList();
  }

  @override
  Future<void> addEventSignup(EventSignupModel signup) async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      _webSignups.removeWhere(
        (s) => s.eventId == signup.eventId && s.userId == signup.userId,
      );
      _webSignups.insert(0, signup);
      return;
    }
    await db.insert(
      'event_signups',
      signup.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeEventSignup(String eventId, String userId) async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      _webSignups.removeWhere(
        (s) => s.eventId == eventId && s.userId == userId,
      );
      return;
    }
    await db.delete(
      'event_signups',
      where: 'eventId = ? AND userId = ?',
      whereArgs: [eventId, userId],
    );
  }

  @override
  Future<void> toggleSignupAttendance(String signupId, bool attended) async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      final idx = _webSignups.indexWhere((s) => s.id == signupId);
      if (idx != -1) {
        final s = _webSignups[idx];
        _webSignups[idx] = EventSignupModel(
          id: s.id,
          eventId: s.eventId,
          userId: s.userId,
          userName: s.userName,
          phone: s.phone,
          attended: attended,
          createdAt: s.createdAt,
        );
      }
      return;
    }
    await db.update(
      'event_signups',
      {'attended': attended ? 1 : 0},
      where: 'id = ?',
      whereArgs: [signupId],
    );
  }

  @override
  Future<List<CampaignModel>> getCampaigns() async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      return List.from(_webCampaigns);
    }
    final rows = await db.query('campaigns', orderBy: 'createdAt DESC');
    return rows.map(CampaignModel.fromMap).toList();
  }

  @override
  Future<void> saveCampaign(CampaignModel campaign) async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      _webCampaigns.removeWhere((c) => c.id == campaign.id);
      _webCampaigns.insert(0, campaign);
      return;
    }
    await db.insert(
      'campaigns',
      campaign.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<DonationModel>> getDonations() async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      return List.from(_webDonations);
    }
    final rows = await db.query('donations', orderBy: 'createdAt DESC');
    return rows.map(DonationModel.fromMap).toList();
  }

  @override
  Future<void> addDonation(DonationModel donation) async {
    final db = await _db;
    if (db == null) {
      _ensureWebInit();
      _webDonations.insert(0, donation);
      return;
    }
    await db.insert(
      'donations',
      donation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
