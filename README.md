# College Management System - Mobile Application

[![Flutter Version](https://img.shields.io/badge/Flutter-%5E3.12.0-blue.svg?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey.svg)](#)
[![Multi-Tenant Architecture](https://img.shields.io/badge/Architecture-Tenant--Based%20%2F%20White--Label-orange.svg)](#)

A cross-platform mobile application built with **Flutter** for the **College Management System**. This application acts as the front-end interface for Students, Faculty, and Administrators, interacting seamlessly with the multi-tenant Django backend through REST APIs and Strawberry GraphQL.

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Architecture & Design Decisions](#-architecture--design-decisions)
  - [Tenant-Based White-Labeling](#1-tenant-based-white-labeling-flavors)
  - [Directory Structure](#2-directory-structure)
- [Feature Modules](#-feature-modules)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running the App](#running-the-app)
- [Backend Integration](#-backend-integration)
- [Adding a New Tenant](#-adding-a-new-tenant-step-by-step)
- [Future Enhancements](#-future-enhancements)

---

## 🔍 Overview

The College Management System mobile client is engineered to deliver a customized user experience for different academic institutions (tenants) using a single codebase. By using Flutter's white-label capabilities and flavor configurations, the app dynamically loads themes, logos, assets, routes, and screen layouts based on the active tenant (e.g., **VELS University**, **Sathyabama Institute**).

---

## 🏛️ Architecture & Design Decisions

### 1. Tenant-Based White-Labeling (Flavors)

The application implements a tenant-first architecture, corresponding to the backend's department/tenant division.
- **Flavors**: Configuration files in `lib/config/flavors/` store tenant-specific properties.
- **Tenant-Scoped UI**: Code is partitioned so each tenant can have custom styling, widgets, routing, and dashboards.
  - Core structures are placed under `lib/core/`.
  - Tenant-specific UI resides in isolated namespaces (e.g., `lib/ui/vels/`).
- **Assets**: Tenant-specific branding assets like logos are stored in `assets/app_logos/` and referenced based on the active build flavor.

### 2. Directory Structure

```text
collge_management_system_mobile/
├── android/                  # Android native project configuration
├── ios/                      # iOS native project configuration
├── assets/
│   └── app_logos/            # Logos for different tenants (vels_logo.png, sathyabama_logo.jpg)
├── lib/
│   ├── config/               # Tenant flavor configurations
│   │   ├── flavor_config.dart
│   │   └── flavors/
│   │       └── vels_config.dart
│   ├── core/                 # Shared models, utilities, and helpers
│   │   ├── academic_models.dart
│   │   ├── auth_provider.dart
│   │   ├── constants.dart    # Configures base URLs per tenant
│   │   ├── router.dart
│   │   ├── storage_helper.dart
│   │   └── user_model.dart
│   ├── services/             # API services communicating with backend
│   │   ├── academic_service.dart
│   │   ├── api_client.dart
│   │   └── auth_service.dart
│   ├── ui/                   # Root UI folder
│   │   └── vels/             # UI elements for VELS tenant
│   │       ├── router/       # VELS-specific routing config
│   │       ├── screens/      # VELS screens divided by role (Admin, Faculty, Student)
│   │       │   ├── admin/
│   │       │   ├── faculty/
│   │       │   ├── student/
│   │       │   ├── login_screen.dart
│   │       │   └── splash_screen.dart
│   │       ├── theme/        # VELS branding theme (colors, fonts, styles)
│   │       └── widgets/      # Reusable VELS-branded widgets
│   └── main.dart             # Application entry point
├── pubspec.yaml              # Package dependencies and assets definition
└── README.md                 # Project documentation
```

---

## 🚀 Feature Modules

### 👤 Role-Based Portals (VELS Example)

The UI is divided into role-based screens for a personalized workflow:

| Role | Screens & Components | Description |
| :--- | :--- | :--- |
| **Admin** | `admin_dashboard.dart`<br>`user_management_screen.dart` | Manage institution configurations, onboarding, departments, and user roles. |
| **Faculty** | `faculty_dashboard.dart`<br>`mark_attendance_screen.dart`<br>`upload_marks_screen.dart` | Manage student attendance, submit grades, view schedules, and log leaves. |
| **Student** | `student_dashboard.dart`<br>`attendance_screen.dart`<br>`grades_screen.dart`<br>`timetable_screen.dart` | View class timetables, attendance history, term grades, and submit grievances. |

### 🛠️ Common Widgets & Utilities

- **Custom Button** (`custom_button.dart`): Reusable styled buttons matching tenant theme colors.
- **Custom Text Field** (`custom_text_field.dart`): Configured fields with validation and error-handling.
- **Loading Overlay** (`loading_overlay.dart`): Loading indicator shown during API roundtrips.
- **Navigation** (`vels_bottom_nav.dart` & `vels_app_bar.dart`): Tenant-themed navigation controls.

---

## 🛠️ Getting Started

### Prerequisites

Ensure you have the following installed on your machine:
- **Flutter SDK** (`^3.12.0`)
- **Dart SDK** (`^3.0.0`)
- **Android Studio** (for Android emulator) / **Xcode** (for iOS simulator, macOS only)
- **VS Code** or **Android Studio** with Flutter & Dart extensions

### Installation

1. Clone the repository and navigate to the mobile app subdirectory:
   ```bash
   cd collge_management_system_mobile
   ```

2. Fetch pub packages:
   ```bash
   flutter pub get
   ```

### Running the App

Run the application on a connected device or emulator.

For the **VELS** tenant flavor:
```bash
flutter run --flavor vels -t lib/main.dart
```

To build a release bundle for a specific tenant:
```bash
# Android APK
flutter build apk --flavor vels -t lib/main.dart

# iOS App Bundle
flutter build ipa --flavor vels -t lib/main.dart
```

---

## 🔌 Backend Integration

The app connects to a Django backend. Ensure that the backend server is running and configure the endpoints in the mobile client.

### API Configuration

Modify the base URL in `lib/core/constants.dart`:
```dart
class AppConstants {
  static const String baseUrl = 'http://<tenant-subdomain>.yourdomain.com/';
}
```
*Note: In production, the subdomain is dynamically set depending on the user's tenant context or selected flavor.*

### Authentication Flow
- The mobile app performs credential authentication via the `/api/token/` (or equivalent endpoint) to obtain a **JWT Access & Refresh Token**.
- Tokens are stored locally on the device using `lib/core/storage_helper.dart` (backing package recommendation: `flutter_secure_storage`).
- All subsequent HTTP calls via `lib/services/api_client.dart` (backed by `dio`) automatically attach the `Authorization: Bearer <token>` header.

---

## 🎨 Adding a New Tenant (Step-by-Step)

To add support for a new college/tenant (e.g., `Sathyabama`):

1. **Add Assets**: Place the logo (`sathyabama_logo.jpg`) in `assets/app_logos/` and declare it in `pubspec.yaml`.
2. **Add Config**: Create a configuration file `lib/config/flavors/sathyabama_config.dart` containing institutional details.
3. **Add UI Namespace**: Create a new directory `lib/ui/sathyabama/` and structure it with:
   - `theme/sathyabama_theme.dart` (defining custom primary/secondary colors).
   - `router/sathyabama_router.dart` (specifying custom routing maps).
   - `screens/` and `widgets/` tailored to Sathyabama requirements.
4. **Wire up Entry Point**: Modify `lib/main.dart` or flavor-specific entry files to load the new config and theme on startup.

---

## 🔮 Future Enhancements

- **GraphQL Integration**: Fully transition resource fetches (grades, timetable, attendance) to Strawberry GraphQL using a client package like `ferry` or `graphql_flutter`.
- **Offline Sync**: Use a local database (e.g., `Hive` or `Isar`) to cache class timetables and student profiles for offline access.
- **Push Notifications**: Connect the Django backend notification event dispatcher with Firebase Cloud Messaging (FCM).
