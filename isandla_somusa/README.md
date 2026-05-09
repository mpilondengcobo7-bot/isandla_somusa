# Isandla Somusa 🤲

> *"The helping hand"* — A mobile app connecting food donors with people and charities in need.

**No food wasted. No one hungry.**

---

## Overview

Isandla Somusa (short name: **Somusa**) is a cross-platform Flutter mobile application that addresses food waste on campuses and restaurants by connecting donors with recipients. Built with Firebase as the backend, it features AI-powered donor-recipient matching, real-time notifications, location mapping, and an NLP chatbot assistant.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| Backend | Firebase (BaaS) |
| Auth | Firebase Auth + Google OAuth + JWT |
| Database | Cloud Firestore (NoSQL) |
| Storage | Firebase Storage |
| Notifications | Firebase Cloud Messaging (FCM) |
| Maps | Google Maps Flutter SDK |
| AI Matching | Rule-based scoring engine (extendable to Vertex AI) |
| NLP Chatbot | Keyword-based intent classifier |
| State Management | Provider |
| Local Storage | SharedPreferences + SQLite (offline cache) |

---

## Features

- **Food donation postings** — photo, title, quantity, expiry, dietary tags
- **Request system** — recipients browse, request, and track donations
- **AI matching** — scores donations by proximity, expiry urgency, user history
- **Location mapping** — Google Maps with donor pins
- **Pickup scheduling** — time slot selection and confirmation
- **Push notifications** — FCM alerts for matches, approvals, pickups
- **Feedback & ratings** — 1–5 star ratings with NLP sentiment analysis
- **Somusa chatbot** — AI assistant for in-app help
- **Admin dashboard** — user management and platform analytics
- **POPIA compliant** — encrypted storage, hashed passwords, role-based access

---

## User Roles

| Role | Access |
|---|---|
| **Donor** | Post donations, manage listings, respond to requests |
| **Recipient** | Browse donations, send requests, schedule pickups, rate donors |
| **Admin** | View all data, manage users, monitor platform |

---

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart       ← Replace with your config
├── models/
│   ├── user_model.dart
│   ├── donation_model.dart
│   ├── request_model.dart
│   ├── notification_model.dart
├── services/
│   ├── auth_service.dart
│   ├── donation_service.dart
│   ├── ai_service.dart
│   └── notification_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── donation_provider.dart
│   └── notification_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── donor/
│   │   ├── donor_home_screen.dart
│   │   ├── create_donation_screen.dart
│   │   ├── donor_requests_screen.dart
│   │   └── donation_detail_screen.dart
│   ├── recipient/
│   │   ├── recipient_home_screen.dart
│   │   └── recipient_requests_screen.dart
│   ├── shared/
│   │   ├── map_screen.dart
│   │   ├── notifications_screen.dart
│   │   ├── chatbot_screen.dart
│   │   └── profile_screen.dart
│   └── admin/
│       └── admin_dashboard_screen.dart
├── widgets/
│   └── donation_card.dart
└── utils/
    ├── app_theme.dart
    ├── app_constants.dart
    ├── validators.dart
    └── helpers.dart
```

---

## Setup Instructions

### 1. Prerequisites
- Flutter SDK 3.x installed — https://docs.flutter.dev/get-started/install
- Android Studio or VS Code with Flutter plugin
- A Firebase account — https://firebase.google.com

### 2. Firebase Setup
1. Go to https://console.firebase.google.com
2. Create a new project named **isandla-somusa**
3. Enable these services:
   - **Authentication** → Email/Password + Google Sign-In
   - **Cloud Firestore** → Start in test mode, then apply `firestore.rules`
   - **Firebase Storage** → Default bucket
   - **Cloud Messaging** → For push notifications
4. Add Android app: package name `com.somusa.isandlaSomusa`
5. Add iOS app: bundle ID `com.somusa.isandlaSomusa`
6. Download `google-services.json` → place in `android/app/`
7. Download `GoogleService-Info.plist` → place in `ios/Runner/`
8. Run: `dart pub global activate flutterfire_cli` then `flutterfire configure`
   - This replaces the placeholder `firebase_options.dart`

### 3. Google Maps API Key
1. Go to https://console.cloud.google.com
2. Enable **Maps SDK for Android** and **Maps SDK for iOS**
3. Create an API key
4. In `android/app/src/main/AndroidManifest.xml`, replace `YOUR_GOOGLE_MAPS_API_KEY`
5. In `ios/Runner/AppDelegate.swift`, add: `GMSServices.provideAPIKey("YOUR_KEY")`

### 4. Install Dependencies
```bash
cd isandla_somusa
flutter pub get
```

### 5. Run the App
```bash
# Android emulator or device
flutter run

# Specific device
flutter devices
flutter run -d <device_id>
```

### 6. Apply Firestore Security Rules
In Firebase Console → Firestore → Rules, paste the contents of `firestore.rules`

---

## Scrum Sprint Plan

| Sprint | Focus | Duration |
|---|---|---|
| Sprint 1 | Auth screens, user roles, Firebase setup | Week 1–2 |
| Sprint 2 | Donation posting, request system, Firestore | Week 3–4 |
| Sprint 3 | Maps, location, pickup scheduling, notifications | Week 5–6 |
| Sprint 4 | AI matching, chatbot, ratings, admin dashboard, polish | Week 7–8 |

---

## POPIA Compliance

- Passwords are hashed using SHA-256 before local storage
- Personal data collected: name, email, phone (optional), location
- All data stored in Firebase (South African data residency recommended)
- Users can delete their accounts from the Profile screen
- Role-based access control prevents unauthorised data access
- Input sanitisation applied to all user-submitted text fields

---

## Team — Group 14

**Isandla Somusa** | University Project  
*"No food wasted. No one hungry."*

---

## License

Academic use only. Not for commercial distribution.
