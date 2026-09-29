# TaskFlow Enterprise — Flutter Mobile Application Documentation

**Project Name:** TaskFlow Enterprise (Mobile)  
**Platform:** Flutter (Android & iOS)  
**Target Package:** `taskflow_flutter`  
**Flutter SDK:** `>=3.10.0` | **Dart SDK:** `>=3.0.0 <4.0.0`  
**Architecture:** Feature-First Clean Architecture with Riverpod 2  
**Backend:** Shared Node.js / Express / MongoDB REST API (`:5000/api`)  

---

## 1. Project Overview

**TaskFlow Enterprise Mobile** is a production-grade cross-platform mobile application developed with **Flutter & Dart**. It provides enterprise workforce management capabilities for two distinct roles:

*   **Administrator Portal:** Team task allocation, priority management, employee directory oversight, leave approval workflows, and live productivity analytics.
*   **Employee Portal:** Personal task tracking, real-time progress updates (0–100%), leave applications with status tracking, profile management, and weekly calendar scheduling.

The mobile application is designed as the mobile client within a unified enterprise ecosystem, communicating over a shared REST backend with a companion web management portal.

---

## 2. System Architecture

The mobile application connects directly to the shared enterprise backend while maintaining complete client-side autonomy:

```
┌────────────────────────────────────────────────────────┐
│               TaskFlow Mobile (Flutter)                │
│       Android / iOS (lib/ · Riverpod 2 · Dio)          │
└───────────────────────────┬────────────────────────────┘
                            │
              REST API (HTTP / Bearer JWT)
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│             Shared Enterprise Backend API              │
│       Node.js · Express 5 · TypeScript (Port 5000)     │
│       (Also serves companion Web Portal)               │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│                        MongoDB                         │
│   Collections: users, tasks, leaves, notifications     │
└────────────────────────────────────────────────────────┘
```

### Architectural Principles
1. **Feature-First Modularity:** Each business domain (`auth`, `dashboard`, `tasks`, `leaves`, `employees`, `notifications`, `profile`, `calendar`, `reports`) encapsulates its own `data/` (models, repositories) and `presentation/` (providers, screens, widgets) layers.
2. **Compile-Time Safe Dependency Injection:** Powered by **Riverpod 2** (`StateNotifierProvider`, `ProviderScope`), eliminating context-dependent lookups in business logic.
3. **Resilient Network Layer:** Custom `DioClient` with token injection interceptor, queue-based 401 refresh deduplication, and automatic account-lockout detection.
4. **Secure Credential Storage:** Tokens stored securely in platform-native hardware keystores via `FlutterSecureStorage` (`encryptedSharedPreferences: true` on Android, `kSecAttrAccessibleFirstUnlock` on iOS).

---

## 3. Technology Stack

### Mobile Frontend
*   **Framework:** Flutter (Android, iOS)
*   **Language:** Dart 3 (Null-safety enabled)
*   **State Management:** `flutter_riverpod ^2.5.1`
*   **HTTP Client:** `dio ^5.4.3+1`
*   **Secure Storage:** `flutter_secure_storage ^9.2.2` (AES encryption)
*   **Local Cache:** `shared_preferences ^2.2.3`
*   **Typography & Styling:** `google_fonts ^6.2.1` (Inter typography)
*   **Validation:** `phone_numbers_parser ^9.0.26` (ITU-T E.164 international standard)
*   **Media:** `image_picker ^1.1.2`
*   **Date & Locale:** `intl ^0.19.0`
*   **Testing:** `flutter_test`, `flutter_lints ^3.0.0`

### Shared Backend
*   **Runtime:** Node.js (TypeScript) + Express 5
*   **Database:** MongoDB via Mongoose 9 ODM
*   **Authentication:** Dual-token JWT (10m Access / 30d Refresh with rotation & reuse detection)
*   **External Services:** Nodemailer (SMTP OTP), Twilio (SMS), Cloudinary (Asset CDN)

---

## 4. Mobile Application Features

### 4.1 Authentication & Registration
*   **Public Registration:** Multi-step registration validating First Name, Last Name, Email, Password, Phone Number, DOB, and Gender.
*   **OTP Verification:** Dedicated email OTP verification step prior to account creation.
*   **Contextual Password Policy:** Enforces 8+ chars, uppercase, lowercase, numbers, special characters, and blocks passwords containing the user's name or email handle.
*   **Login & Remember Me:** Issues JWT access and refresh tokens, securely persisting credentials when selected.
*   **Forgot Password:** 3-step OTP-gated password recovery workflow.
*   **Role-Aware Shell Navigation:** Routes authenticated users into the `AdminShell` or `EmployeeShell` automatically.

### 4.2 Task Management
*   **Admin Task Allocation:** Full task creation with assignee picker, priority (Low/Medium/High), due date, category, estimated hours, and tags.
*   **Task Filtering:** Live filtering across statuses (Pending, In Progress, Review, Completed, Blocked) and priorities.
*   **Employee Progress Tracking:** Interactive slider enabling employees to update task completion percentage (0–100%) and post comments.

### 4.3 Leave Management
*   **Employee Application:** Date-range selector, leave type selection (Casual, Sick, Earned, Unpaid, Maternity, Paternity, Compensatory), and required justification.
*   **Admin Review Workflow:** Modal review interface allowing one-click Approval or Rejection with mandatory reason logging.
*   **Reactive Theme Synchronization:** Instant color and contrast updates across leave cards when switching between Light and Dark modes.

### 4.4 Employee Directory (Admin)
*   **Directory Management:** Searchable list of all employees with contact badges and departmental info.
*   **Lifecycle Control:** Admin actions for account blocking, unblocking, and soft-delete/archival.
*   **Employee Task Audit:** View all tasks assigned to a specific team member.

### 4.5 Productivity Analytics & Calendar
*   **Executive Dashboard:** Interactive stat cards deep-linking directly to pre-filtered task lists.
*   **Weekly Calendar:** Interactive 7-day strip filtering tasks scheduled for the selected date.
*   **Productivity Reports:** Status distribution grids, priority progress breakdown, and employee performance leaderboard.

### 4.6 Polished Android UX & Navigation
*   **Strict Navigation Hierarchy:** PUSH transitions enter `Right → Left`; POP transitions exit `Left → Right`.
*   **Material 3 Bottom Sheet:** Polished role-aware confirmation modal on logout ("Are you sure you want to log out of the Admin Portal / Employee Portal?").
*   **Zero-Flicker Logout:** Animated transition smoothly slides out the authenticated shell directly to the login interface.

---

## 5. Mobile Project Structure

```
Flutter-code/
├── lib/
│   ├── main.dart                          # App entry point & service bootstrap
│   ├── app.dart                           # MaterialApp root, theme listening
│   │
│   ├── core/
│   │   ├── config/api_config.dart         # Dynamic LAN/Emulator API endpoint resolution
│   │   ├── constants/api_endpoints.dart   # 35+ REST API route definitions
│   │   ├── navigation/                    # Custom SlidePageRoute & navigation service
│   │   ├── network/dio_client.dart        # Dio interceptors, auto-refresh queue, error extraction
│   │   ├── storage/storage_service.dart   # EncryptedSharedPreferences token storage
│   │   ├── theme/                         # AppTheme (Light & Dark), AppColors, ThemeNotifier
│   │   ├── utils/validators.dart          # Comprehensive 535-line validation suite
│   │   └── widgets/                       # 17+ Reusable Material 3 design system components
│   │
│   └── features/
│       ├── auth/                          # Login, Register, Forgot Password, Models, Providers
│       ├── dashboard/                     # Admin & Employee Dashboard screens & stat cards
│       ├── tasks/                         # Task list, Create Task, Task Detail, Filter modals
│       ├── leaves/                        # Admin & Employee leave management screens
│       ├── employees/                     # Employee directory, profile, block/unblock
│       ├── notifications/                 # In-app notifications feed with mark-read/archive
│       ├── profile/                       # User profile edit, avatar picker, password modal
│       ├── calendar/                      # Weekly calendar scheduling view
│       ├── reports/                       # Productivity charts and performance leaderboard
│       ├── settings/                      # Dark/Light theme toggle & custom backend URL tester
│       └── navigation/                    # RootNavigation, AdminShell, EmployeeShell
│
├── test/                                  # 15 Test Files (97 Unit & Widget tests)
│   ├── admin_task_leave_management_test.dart
│   ├── dashboard_stat_card_filter_test.dart
│   ├── enterprise_audit_fixes_test.dart
│   ├── logout_confirmation_sheet_test.dart
│   ├── logout_flow_test.dart
│   ├── profile_screen_test.dart
│   ├── profile_screen_widget_test.dart
│   ├── register_back_button_test.dart
│   ├── register_screen_test.dart
│   ├── registration_enhancements_test.dart
│   ├── task_header_action_test.dart
│   ├── theme_settings_test.dart
│   ├── theme_synchronization_and_contrast_test.dart
│   ├── validation_and_auth_audit_test.dart
│   └── widget_test.dart
│
└── pubspec.yaml                           # Dependencies and asset configuration
```

---

## 6. Testing & Verification

The Flutter application includes comprehensive test coverage verifying state management, business logic, user interface widgets, and edge-case handling:

*   **Total Test Files:** 15
*   **Total Test Cases:** **97 Passing Tests** (`flutter test` exit code `0`)
*   **Static Code Analysis:** **0 Warnings / 0 Errors** (`flutter analyze` clean)

### Test Verification Command
```bash
flutter test --reporter=compact
```

---

## 7. Running the Application

### Prerequisites
*   Flutter SDK ≥ 3.10.0
*   Android SDK / Studio or physical Android device

### Setup & Execution
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run static analysis
flutter analyze

# 3. Execute automated test suite
flutter test

# 4. Launch on connected device (Default points to LAN backend 172.16.2.15:5000)
flutter run

# Optional: Override backend URL at launch
flutter run --dart-define=API_URL=http://<YOUR_IP>:5000/api
```
