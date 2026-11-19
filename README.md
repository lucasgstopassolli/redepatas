# 🐾 RedePatas

A community mobile application developed in **Flutter (Material 3)** to register, organize, and track support requests for stray animals in need of **Water**, **Food**, **Shelter**, or **Rescue/Care** in **Rio do Sul (SC)** and the **Alto Vale do Itajaí** region.

- **Course:** Mobile Platform Development
- **Program:** Information Systems (Outreach Project — Development and Citizenship)
- **Team:** Ariel Jahn and Lucas Gabriel Stopassoli

---

## ✨ Key Features

1. **Welcome & Quick Sign-In (`WelcomeScreen`)**:
   - Simplified access (Log In, Sign Up, or Guest/Demo mode).
2. **Community Feed (`HomeRequestsScreen` — `Home` Tab)**:
   - Text search by neighborhood, species, or need.
   - Quick category filters (`All`, `💧 Water`, `🥣 Food`, `🏠 Shelter`, `🚨 Urgent`, `✓ Completed`) and city filter.
3. **Lifecycle & Assistance (`RequestDetailScreen`)**:
   - Clear statuses: **`Open`**, **`In Progress`**, and **`Completed`**.
   - **"I Want to Help This Animal"** workflow logging the volunteer's commitment along with a direct **WhatsApp** contact button.
4. **My Actions (`MyActionsScreen` — `Requests` Tab)**:
   - **Helping** and **Created by Me** sub-tabs.
5. **New Request Registration (`NewRequestScreen` — `New` Tab)**:
   - Multiple needs (`Water`, `Food`, `Shelter`, `Rescue/Care`) and Urgency Levels (`Normal`, `High`, `Critical`).
   - **Smart Location**: Pre-configured official neighborhoods of **Rio do Sul - SC** + integration with the **official IBGE API** covering all municipalities in Santa Catarina.
   - Optional photo capture via Camera or Gallery (`image_picker`).
6. **Guide & My Area (`ProfileGuideScreen` — `My Area` Tab)**:
   - Persistent Theme selector (`☀️ Light`, `🌙 Dark`, `📱 System`) featuring an earthy/terracotta color palette.
   - Quick Safe Approach Guide and Useful Contacts (APAD Rio do Sul, City Hall/Animal Welfare, Fire Department 193, Military Police 190).

---

## 🚀 How to Run

```bash
flutter pub get
flutter run
```