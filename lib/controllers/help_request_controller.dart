import 'package:flutter/material.dart';

import '../models/help_request_model.dart';
import '../repositories/i_help_request_repository.dart';

enum HomeFilterCategory {
  all,
  water,
  food,
  shelter,
  urgent;

  String get label {
    switch (this) {
      case HomeFilterCategory.all:
        return 'Todos';
      case HomeFilterCategory.water:
        return 'Água';
      case HomeFilterCategory.food:
        return 'Alimento';
      case HomeFilterCategory.shelter:
        return 'Abrigo';
      case HomeFilterCategory.urgent:
        return 'Urgentes';
    }
  }

  IconData get icon {
    switch (this) {
      case HomeFilterCategory.all:
        return Icons.apps_rounded;
      case HomeFilterCategory.water:
        return Icons.water_drop_outlined;
      case HomeFilterCategory.food:
        return Icons.restaurant_outlined;
      case HomeFilterCategory.shelter:
        return Icons.home_outlined;
      case HomeFilterCategory.urgent:
        return Icons.warning_amber_rounded;
    }
  }
}

class HelpRequestController extends ChangeNotifier {
  final IHelpRequestRepository _repository;

  List<HelpRequestModel> _requests = [];
  bool _isLoading = false;
  String _searchQuery = '';
  HomeFilterCategory _selectedCategory = HomeFilterCategory.all;
  String? _selectedCityFilter; // null = Todas ("Rio do Sul e região")
  bool _showCompletedInHome = false;

  HelpRequestController(this._repository) {
    loadRequests();
  }

  List<HelpRequestModel> get allRequests => _requests;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  HomeFilterCategory get selectedCategory => _selectedCategory;
  String? get selectedCityFilter => _selectedCityFilter;
  bool get showCompletedInHome => _showCompletedInHome;

  List<String> get availableCities {
    final cities = <String>{'Rio do Sul'};
    for (final req in _requests) {
      if (req.city.trim().isNotEmpty) {
        cities.add(req.city.trim());
      }
    }
    return cities.toList()..sort();
  }

  List<HelpRequestModel> get filteredRequests {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = _requests.where((req) {
      // Por padrão no mural principal mostra ativos (Aberto / Em atendimento),
      // ou inclui concluídos se o usuário ativar o filtro de histórico.
      if (!_showCompletedInHome && req.status == RequestStatus.completed) {
        return false;
      }

      if (_selectedCityFilter != null &&
          req.city.toLowerCase() != _selectedCityFilter!.toLowerCase()) {
        return false;
      }

      switch (_selectedCategory) {
        case HomeFilterCategory.all:
          break;
        case HomeFilterCategory.water:
          if (!req.needs.contains(NeedType.water)) return false;
        case HomeFilterCategory.food:
          if (!req.needs.contains(NeedType.food)) return false;
        case HomeFilterCategory.shelter:
          if (!req.needs.contains(NeedType.shelter)) return false;
        case HomeFilterCategory.urgent:
          if (req.urgency == UrgencyLevel.normal &&
              !req.needs.contains(NeedType.medical)) {
            return false;
          }
      }

      if (query.isNotEmpty) {
        final matchesTitle = req.title.toLowerCase().contains(query);
        final matchesNeighborhood =
            req.neighborhood.toLowerCase().contains(query);
        final matchesCity = req.city.toLowerCase().contains(query);
        final matchesRef = req.referencePoint.toLowerCase().contains(query);
        final matchesSpecies = req.species.label.toLowerCase().contains(query);
        final matchesNeeds = req.needs.any(
          (n) => n.label.toLowerCase().contains(query),
        );
        if (!matchesTitle &&
            !matchesNeighborhood &&
            !matchesCity &&
            !matchesRef &&
            !matchesSpecies &&
            !matchesNeeds) {
          return false;
        }
      }

      return true;
    }).toList();

    // Ordena priorizando pedidos Abertos e Críticos mais recentes
    filtered.sort((a, b) {
      if (a.status != b.status) {
        if (a.status == RequestStatus.completed) return 1;
        if (b.status == RequestStatus.completed) return -1;
      }
      if (a.urgency != b.urgency) {
        return b.urgency.index.compareTo(a.urgency.index);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  List<HelpRequestModel> myHelpingRequests(String userId) {
    return _requests.where((r) => r.helperId == userId).toList();
  }

  List<HelpRequestModel> myCreatedRequests(String userId) {
    return _requests.where((r) => r.authorId == userId).toList();
  }

  HelpRequestModel? getById(String id) {
    for (final req in _requests) {
      if (req.id == id) return req;
    }
    return null;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(HomeFilterCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setCityFilter(String? city) {
    _selectedCityFilter = city;
    notifyListeners();
  }

  void toggleShowCompletedInHome(bool value) {
    _showCompletedInHome = value;
    notifyListeners();
  }

  Future<void> loadRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      _requests = await _repository.getAllRequests();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createRequest(HelpRequestModel request) async {
    await _repository.createRequest(request);
    await loadRequests();
  }

  Future<void> updateRequest(HelpRequestModel request) async {
    await _repository.updateRequest(request);
    await loadRequests();
  }

  Future<void> assignVolunteer({
    required String requestId,
    required String volunteerId,
    required String volunteerName,
    String? commitment,
  }) async {
    await _repository.assignVolunteer(
      requestId: requestId,
      volunteerId: volunteerId,
      volunteerName: volunteerName,
      commitment: commitment,
    );
    await loadRequests();
  }

  Future<void> updateStatus(
    String requestId,
    RequestStatus newStatus,
  ) async {
    await _repository.updateStatus(requestId, newStatus);
    await loadRequests();
  }
}
