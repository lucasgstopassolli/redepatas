import 'package:flutter/foundation.dart';

import '../models/campaign_model.dart';
import '../models/case_update_model.dart';
import '../models/event_model.dart';
import '../models/help_request_model.dart';
import '../models/organization_model.dart';
import '../models/shelter_animal_model.dart';
import '../repositories/i_ong_repository.dart';

class OngDashboardMetrics {
  final int openCount;
  final int inProgressCount;
  final int completedCount;
  final double? avgResolutionHours;
  final List<HelpRequestModel> overdueCritical;
  final Map<NeedType, int> byNeed;
  final Map<AnimalSpecies, int> bySpecies;
  final Map<String, int> byNeighborhood;

  const OngDashboardMetrics({
    required this.openCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.avgResolutionHours,
    required this.overdueCritical,
    required this.byNeed,
    required this.bySpecies,
    required this.byNeighborhood,
  });
}

class OngController extends ChangeNotifier {
  final IOngRepository _repository;

  List<OrganizationModel> _organizations = [];
  List<VolunteerProfileModel> _volunteers = [];
  List<CaseUpdateModel> _caseUpdates = [];
  List<ShelterAnimalModel> _shelterAnimals = [];
  List<AdoptionInterestModel> _adoptionInterests = [];
  List<CommunityEventModel> _events = [];
  List<EventSignupModel> _eventSignups = [];
  List<CampaignModel> _campaigns = [];
  List<DonationModel> _donations = [];
  bool _isLoading = false;

  OngController(this._repository) {
    loadAll();
  }

  bool get isLoading => _isLoading;
  List<OrganizationModel> get organizations => _organizations;
  List<VolunteerProfileModel> get volunteers => _volunteers;
  List<ShelterAnimalModel> get shelterAnimals => _shelterAnimals;
  List<AdoptionInterestModel> get adoptionInterests => _adoptionInterests;
  List<CommunityEventModel> get events => _events;
  List<EventSignupModel> get eventSignups => _eventSignups;
  List<CampaignModel> get campaigns => _campaigns;
  List<DonationModel> get donations => _donations;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getOrganizations(),
        _repository.getVolunteers(),
        _repository.getAllCaseUpdates(),
        _repository.getShelterAnimals(),
        _repository.getAdoptionInterests(),
        _repository.getEvents(),
        _repository.getEventSignups(),
        _repository.getCampaigns(),
        _repository.getDonations(),
      ]);
      _organizations = results[0] as List<OrganizationModel>;
      _volunteers = results[1] as List<VolunteerProfileModel>;
      _caseUpdates = results[2] as List<CaseUpdateModel>;
      _shelterAnimals = results[3] as List<ShelterAnimalModel>;
      _adoptionInterests = results[4] as List<AdoptionInterestModel>;
      _events = results[5] as List<CommunityEventModel>;
      _eventSignups = results[6] as List<EventSignupModel>;
      _campaigns = results[7] as List<CampaignModel>;
      _donations = results[8] as List<DonationModel>;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  OrganizationModel? getOrganizationById(String? id) {
    if (id == null) return _organizations.isNotEmpty ? _organizations.first : null;
    for (final org in _organizations) {
      if (org.id == id) return org;
    }
    return _organizations.isNotEmpty ? _organizations.first : null;
  }

  Future<void> saveOrganization(OrganizationModel org) async {
    await _repository.saveOrganization(org);
    _organizations = await _repository.getOrganizations();
    notifyListeners();
  }

  VolunteerProfileModel? getVolunteerByUserId(String userId) {
    for (final v in _volunteers) {
      if (v.userId == userId) return v;
    }
    return null;
  }

  Future<void> saveVolunteer(VolunteerProfileModel volunteer) async {
    await _repository.saveVolunteer(volunteer);
    _volunteers = await _repository.getVolunteers();
    notifyListeners();
  }

  List<VolunteerProfileModel> matchingVolunteersForRequest(
    HelpRequestModel req,
  ) {
    return _volunteers.where((v) {
      if (req.needs.contains(NeedType.shelter) &&
          v.skills.contains('Abrigo temporário')) {
        return true;
      }
      if (req.needs.contains(NeedType.food) &&
          v.skills.contains('Alimentação')) {
        return true;
      }
      if (req.needs.contains(NeedType.medical) &&
          (v.skills.contains('Veterinário') ||
              v.skills.contains('Resgate') ||
              v.hasVehicle)) {
        return true;
      }
      return v.skills.isNotEmpty;
    }).toList();
  }

  List<CaseUpdateModel> updatesForRequest(String requestId) {
    return _caseUpdates.where((u) => u.requestId == requestId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> addCaseUpdate(CaseUpdateModel update) async {
    await _repository.addCaseUpdate(update);
    _caseUpdates = await _repository.getAllCaseUpdates();
    notifyListeners();
  }

  Future<void> saveShelterAnimal(ShelterAnimalModel animal) async {
    await _repository.saveShelterAnimal(animal);
    _shelterAnimals = await _repository.getShelterAnimals();
    notifyListeners();
  }

  List<AdoptionInterestModel> interestsForAnimal(String animalId) {
    return _adoptionInterests.where((i) => i.animalId == animalId).toList();
  }

  Future<void> addAdoptionInterest(AdoptionInterestModel interest) async {
    await _repository.addAdoptionInterest(interest);
    _adoptionInterests = await _repository.getAdoptionInterests();
    notifyListeners();
  }

  Future<void> saveEvent(CommunityEventModel event) async {
    await _repository.saveEvent(event);
    _events = await _repository.getEvents();
    notifyListeners();
  }

  List<EventSignupModel> signupsForEvent(String eventId) {
    return _eventSignups.where((s) => s.eventId == eventId).toList();
  }

  bool isUserSignedUp(String eventId, String userId) {
    return _eventSignups
        .any((s) => s.eventId == eventId && s.userId == userId);
  }

  int eventsAttendedByUser(String userId) {
    return _eventSignups.where((s) => s.userId == userId).length;
  }

  Future<void> toggleEventSignup({
    required String eventId,
    required String userId,
    required String userName,
    String? phone,
  }) async {
    if (isUserSignedUp(eventId, userId)) {
      await _repository.removeEventSignup(eventId, userId);
    } else {
      await _repository.addEventSignup(
        EventSignupModel(
          id: 'sig_${DateTime.now().millisecondsSinceEpoch}',
          eventId: eventId,
          userId: userId,
          userName: userName,
          phone: phone,
          createdAt: DateTime.now(),
        ),
      );
    }
    _eventSignups = await _repository.getEventSignups();
    notifyListeners();
  }

  Future<void> toggleSignupAttendance(String signupId, bool attended) async {
    await _repository.toggleSignupAttendance(signupId, attended);
    _eventSignups = await _repository.getEventSignups();
    notifyListeners();
  }

  Future<void> saveCampaign(CampaignModel campaign) async {
    await _repository.saveCampaign(campaign);
    _campaigns = await _repository.getCampaigns();
    notifyListeners();
  }

  List<DonationModel> donationsForCampaign(String campaignId) {
    return _donations.where((d) => d.campaignId == campaignId).toList();
  }

  Future<void> registerDonation(DonationModel donation) async {
    await _repository.addDonation(donation);
    final idx = _campaigns.indexWhere((c) => c.id == donation.campaignId);
    if (idx != -1) {
      final camp = _campaigns[idx];
      await _repository.saveCampaign(
        camp.copyWith(currentAmount: camp.currentAmount + donation.amount),
      );
    }
    _donations = await _repository.getDonations();
    _campaigns = await _repository.getCampaigns();
    notifyListeners();
  }

  /// Métricas calculadas para o Painel da ONG (período em dias; null = tudo).
  OngDashboardMetrics computeMetrics(
    List<HelpRequestModel> allRequests, {
    int? periodDays,
  }) {
    final now = DateTime.now();
    final filtered = periodDays == null
        ? allRequests
        : allRequests
            .where((r) => now.difference(r.createdAt).inDays <= periodDays)
            .toList();

    int open = 0;
    int inProgress = 0;
    int completed = 0;
    final resolutionHours = <double>[];
    final overdueCritical = <HelpRequestModel>[];
    final byNeed = <NeedType, int>{};
    final bySpecies = <AnimalSpecies, int>{};
    final byNeighborhood = <String, int>{};

    for (final req in filtered) {
      switch (req.status) {
        case RequestStatus.open:
          open++;
          if (req.urgency == UrgencyLevel.critical &&
              now.difference(req.createdAt).inMinutes >= 120) {
            overdueCritical.add(req);
          }
        case RequestStatus.inProgress:
          inProgress++;
        case RequestStatus.completed:
          completed++;
          final doneAt = req.completedAt ?? req.updatedAt;
          if (doneAt != null && doneAt.isAfter(req.createdAt)) {
            resolutionHours.add(
              doneAt.difference(req.createdAt).inMinutes / 60.0,
            );
          }
      }

      for (final n in req.needs) {
        byNeed[n] = (byNeed[n] ?? 0) + 1;
      }
      bySpecies[req.species] = (bySpecies[req.species] ?? 0) + 1;
      byNeighborhood[req.neighborhood] =
          (byNeighborhood[req.neighborhood] ?? 0) + 1;
    }

    final double? avgHours = resolutionHours.isEmpty
        ? null
        : resolutionHours.reduce((a, b) => a + b) / resolutionHours.length;

    return OngDashboardMetrics(
      openCount: open,
      inProgressCount: inProgress,
      completedCount: completed,
      avgResolutionHours: avgHours,
      overdueCritical: overdueCritical,
      byNeed: byNeed,
      bySpecies: bySpecies,
      byNeighborhood: byNeighborhood,
    );
  }

  /// Conquistas / selos simples calculados para o usuário.
  List<String> computeUserBadges({
    required int createdCount,
    required int helpingCount,
    required int completedHelpingCount,
    required int eventsCount,
  }) {
    final badges = <String>[];
    if (helpingCount >= 1) badges.add('Primeira ajuda');
    if (completedHelpingCount >= 5) badges.add('5 resgates concluídos');
    if (createdCount >= 1) badges.add('Olhar atento');
    if (eventsCount >= 1) badges.add('Presença em mutirão');
    return badges;
  }

  /// Detecta possível pedido duplicado no mesmo bairro e espécie nas últimas 24h.
  HelpRequestModel? findPossibleDuplicate({
    required List<HelpRequestModel> allRequests,
    required String neighborhood,
    required AnimalSpecies species,
  }) {
    final now = DateTime.now();
    final target = neighborhood.trim().toLowerCase();
    for (final req in allRequests) {
      if (req.status == RequestStatus.completed) continue;
      if (req.species == species &&
          req.neighborhood.trim().toLowerCase() == target &&
          now.difference(req.createdAt).inHours <= 24) {
        return req;
      }
    }
    return null;
  }
}
