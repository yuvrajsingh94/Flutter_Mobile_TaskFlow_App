# TaskFlow - Cross-Platform Flutter Mobile & Web Application

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Feature--Driven-blue.svg)](https://flutter.dev)
[![State Management](https://img.shields.io/badge/State-Flutter%20Riverpod%202.5-blueviolet)](https://riverpod.dev)
[![Tests](https://img.shields.io/badge/Tests-97%20Passing%20(100%25)-success)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-brightgreen)](#)

TaskFlow is a production-grade, enterprise Employee & Task Management mobile and web application built with **Flutter & Dart**. It provides complete role-based workflows for **Administrators** and **Employees**, with 100% feature and visual parity, connecting to a centralized Express & MongoDB backend.

---

## Key Highlights

- **Enterprise Feature-Driven Clean Architecture**: Strict separation of concerns across `core`, `features`, `data` (models & repositories), and `presentation` (screens, widgets, providers).
- **Dual-Role Portals**:
  - **Admin Portal**: Real-time stats dashboard, interactive task filtering (Pending, In Progress, Completed), task creation & assignment with multi-select dependencies, leave management (instant Approve / Reject with reason), employee management & status control.
  - **Employee Portal**: Personalized task list, live task progress updates, leave request submission with date-range picker and balance calculation, profile customization.
- **Robust Authentication & Security**: JWT authentication with automatic token refresh, secure key-value token storage (`flutter_secure_storage`), persistent session rehydration, and full logout navigation stack protection.
- **Dynamic Country-Aware Validation**: Real-time ITU metadata parsing for international phone numbers, smart title-casing for names, live password strength checklist meter, and strict email verification.
- **Material 3 Theme System**: Full light and dark mode synchronization with centralized design tokens, high-contrast states, and reactive instant theme toggling.
- **Zero Analyzer Warnings & 100% Test Coverage**: Verified with `flutter analyze` (0 issues) and 97 comprehensive unit and widget tests.

---

## Project Structure

```text
lib/
├── app.dart                          # Root MaterialApp, Riverpod integration, and routing
├── main.dart                         # Bootstrap, environment loading, and error handling
├── core/
│   ├── constants/                    # Application bounds, API routes, pagination defaults
│   ├── errors/                       # Failures (ServerFailure, NetworkFailure) & Exceptions
│   ├── network/                      # Dio HTTP client, interceptors, error extraction
│   ├── storage/                      # Secure storage & shared preferences service
│   ├── theme/                        # Light & Dark color tokens, Typography, ThemeData
│   ├── utils/                        # Validators, date/time formatters, input formatters
│   └── widgets/                      # Shared reusable UI (AppButton, AppTextField, Cards, Badges)
└── features/
    ├── auth/                         # Login, Register, Forgot Password, OTP verification
    ├── dashboard/                    # Admin & Employee analytics, summary stat cards
    ├── tasks/                        # Task list, detail, creation, assignment & filtering
    ├── leave/                        # Leave application, review, approve/reject workflows
    ├── profile/                      # Profile view, editing, avatar upload, password change
    └── settings/                     # Appearance/Theme switcher, language, notification preferences
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.10.0`)
- [Dart SDK](https://dart.dev/get-dart) (`>= 3.0.0`)
- Android Studio / Xcode (for mobile builds) or Chrome (for web)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yuvrajsingh94/Flutter_Mobile_TaskFlow_App.git
   cd Flutter_Mobile_TaskFlow_App
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Environment**:
   Copy `.env.example` to `.env` and set your backend API URL:
   ```bash
   cp .env.example .env
   ```
   Example:
   ```env
   EXPO_PUBLIC_API_URL=http://localhost:5000/api
   ```

---

## Running the Application

### Using Flutter CLI

- **Chrome (Web)**:
  ```bash
  flutter run -d chrome --web-port 8080
  ```
- **Android Device / Emulator**:
  ```bash
  flutter run -d android
  ```
- **iOS Simulator**:
  ```bash
  flutter run -d ios
  ```

### Using npm Scripts (Optional Workflow)

```bash
npm run dev        # Launch Web on Chrome port 8080
npm run android    # Launch on connected Android device
npm run test       # Run 97 unit & widget tests
npm run analyze    # Run static analysis
npm run build:apk  # Build debug APK
npm run build:web  # Build production web release
```

---

## Running Tests & Code Quality

Verify all unit and widget tests:
```bash
flutter test
```

Run Dart static analysis:
```bash
flutter analyze
```

---

## Technology Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter (Material 3) |
| **Language** | Dart |
| **State Management** | Flutter Riverpod |
| **Networking** | Dio 5.x with custom interceptors |
| **Persistence** | Flutter Secure Storage & SharedPreferences |
| **UI & Icons** | Cupertino Icons, Google Fonts |
| **Form Handling** | Custom controllers, dynamic ITU phone validation |

---

## License

This project is proprietary and confidential. All rights reserved.
