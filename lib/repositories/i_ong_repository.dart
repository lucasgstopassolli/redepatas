import '../models/campaign_model.dart';
import '../models/case_update_model.dart';
import '../models/event_model.dart';
import '../models/organization_model.dart';
import '../models/shelter_animal_model.dart';

abstract class IOngRepository {
  // Organizações
  Future<List<OrganizationModel>> getOrganizations();
  Future<void> saveOrganization(OrganizationModel org);

  // Voluntários
  Future<List<VolunteerProfileModel>> getVolunteers();
  Future<void> saveVolunteer(VolunteerProfileModel volunteer);

  // Linha do tempo dos casos
  Future<List<CaseUpdateModel>> getCaseUpdates(String requestId);
  Future<List<CaseUpdateModel>> getAllCaseUpdates();
  Future<void> addCaseUpdate(CaseUpdateModel update);

  // Animais acolhidos e adoção
  Future<List<ShelterAnimalModel>> getShelterAnimals();
  Future<void> saveShelterAnimal(ShelterAnimalModel animal);
  Future<List<AdoptionInterestModel>> getAdoptionInterests();
  Future<void> addAdoptionInterest(AdoptionInterestModel interest);

  // Eventos e mutirões
  Future<List<CommunityEventModel>> getEvents();
  Future<void> saveEvent(CommunityEventModel event);
  Future<List<EventSignupModel>> getEventSignups();
  Future<void> addEventSignup(EventSignupModel signup);
  Future<void> removeEventSignup(String eventId, String userId);
  Future<void> toggleSignupAttendance(String signupId, bool attended);

  // Campanhas e doações
  Future<List<CampaignModel>> getCampaigns();
  Future<void> saveCampaign(CampaignModel campaign);
  Future<List<DonationModel>> getDonations();
  Future<void> addDonation(DonationModel donation);
}
