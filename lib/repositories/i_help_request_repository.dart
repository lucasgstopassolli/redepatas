import '../models/help_request_model.dart';

abstract class IHelpRequestRepository {
  Future<List<HelpRequestModel>> getAllRequests();
  Future<void> createRequest(HelpRequestModel request);
  Future<void> updateRequest(HelpRequestModel request);
  Future<void> assignVolunteer({
    required String requestId,
    required String volunteerId,
    required String volunteerName,
    String? commitment,
  });
  Future<void> updateStatus(String requestId, RequestStatus newStatus);
}
