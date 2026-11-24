# 🐾 RedePatas 2.0

A community mobile application developed in **Flutter (Material 3)** to register, organize, and track support requests for stray animals in need of **Water**, **Food**, **Shelter**, or **Rescue/Care** in **Rio do Sul (SC)** and the **Alto Vale do Itajaí** region — now featuring a complete **NGO & Protector Management Suite**.

- **Course:** Mobile Platform Development
- **Program:** Information Systems (Outreach Project — Development and Citizenship)
- **Team:** Ariel Jahn and Lucas Gabriel Stopassoli

---

## ✨ Key Features

1. **Onboarding & Welcome (`OnboardingScreen` + `WelcomeScreen`)**:
   - First-access 4-step walkthrough explaining how RedePatas works for citizens, volunteers, and NGOs.
   - Live animated community counters and quick Demo / **NGO Demo** sign-in.
2. **Community Feed & OSM Map (`HomeRequestsScreen` + `RequestsMapScreen`)**:
   - Regional summary card, quick category/city filters, **"Perto de mim"** Haversine sorting, and seamless **List / Map** toggle with OpenStreetMap pins.
3. **Lifecycle & Case Timeline (`RequestDetailScreen`)**:
   - Animated horizontal status stepper (`Aberto` → `Em atendimento` → `Concluído`).
   - Chronological case timeline (`case_updates`), direct WhatsApp contact, route opening, sharing, and one-tap conversion to sheltered animal.
4. **NGO Dashboard & Accountability Reports (`OrgDashboardScreen`)**:
   - Period filter (`7 days`, `30 days`, `All`), key metrics, average resolution time, overdue critical alerts (> 2h), needs distribution chart (`fl_chart`), and **PDF / CSV** report export.
5. **Adoption & Sheltered Animals (`AdoptionScreen`)**:
   - Public adoption & temporary foster showcase with status filters, NGO animal registration, interest form, and pre-filled WhatsApp contact.
6. **Events, Mutirões & NGO Directory (`EventsOngsScreen`)**:
   - Community events with 1-tap signup, seat counter, CSV attendee export, local reminder, regional NGO directory, and volunteer skills/availability profiles.
7. **Donations & Pix Campaigns (`CampaignsScreen`)**:
   - Supply & financial campaigns with animated progress bars, 1-tap **Copy Pix**, and donation tracking.
8. **Abuse Reporting Guide (`AbuseReportScreen`)**:
   - Legal guidance (Lei 14.064/2020), evidence checklist, direct emergency buttons (`190`, `193`, `181`), and shareable report summary.
9. **Smooth Theme Switching & Accessibility (`AppTheme` + `AppSemanticColors`)**:
   - Cached `ThemeData` with `AppSemanticColors` `ThemeExtension` for smooth 300ms light/dark transitions, earthy terracotta palette, 56dp primary buttons, and readable typography (`>= 14px`).

---

## 🚀 How to Run & Test

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
