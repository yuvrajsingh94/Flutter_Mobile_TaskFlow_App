# TaskFlow Enterprise — Project Documentation

**Version:** 1.0 | **Last Updated:** September 2026
**Package:** `project-2` (Web) · `taskflow_flutter` (Mobile) · `backend`
**Primary Language:** TypeScript (Backend + Web Frontend) · Dart (Mobile Client)

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Project Architecture](#2-project-architecture)
3. [Technology Stack](#3-technology-stack)
4. [Application Features](#4-application-features)
5. [Frontend Architecture — Web](#5-frontend-architecture--web)
6. [Frontend Architecture — Mobile](#6-frontend-architecture--mobile-flutter)
7. [Shared Backend Architecture](#7-shared-backend-architecture)
8. [Authentication & Authorization](#8-authentication--authorization)
9. [API Documentation](#9-api-documentation)
10. [Database Design](#10-database-design)
11. [Validation & Error Handling](#11-validation--error-handling)
12. [Security](#12-security)
13. [Integrations & External Services](#13-integrations--external-services)
14. [Testing & Quality Assurance](#14-testing--quality-assurance)
15. [Project Structure](#15-project-structure)
16. [Environment & Setup](#16-environment--setup)
17. [Current Implementation & Limitations](#17-current-implementation--limitations)
18. [Future Improvements](#18-future-improvements)
19. [Conclusion](#19-conclusion)

---

## 1. Project Overview

**TaskFlow Enterprise** is a multi-client workforce management platform designed for organisations that need structured task delegation, leave management, and employee oversight across both web and mobile interfaces.

The system addresses a common operational problem: disconnected tools for assigning work, tracking progress, and managing team leave. TaskFlow Enterprise consolidates these workflows into a single platform with two distinct user roles — **Administrator** and **Employee** — each with a fully differentiated interface and permission model.

### What the System Does

- **Administrators** create and assign tasks to employees, track overall progress, manage the employee lifecycle (onboard, block, restore), review and action leave requests, and monitor productivity analytics.
- **Employees** view their assigned tasks, update progress and status, apply for leave, verify their contact details, and manage their personal profile.

### Clients

The platform has two production-ready client applications, both pointing at the same shared backend API:

1. **Web Application** — React 19 + Vite SPA (`PROJECT 2/frontend/`) targeting desktop/browser users.
2. **Flutter Mobile Application** — Flutter/Dart (`Flutter-code/`) targeting Android and iOS devices.

Both clients are fully independent but share identical business capabilities and connect to the same Node.js REST API.

---

## 2. Project Architecture

### System Overview

```
┌────────────────────────┐     ┌────────────────────────────┐
│   Web Application      │     │  Flutter Mobile Application │
│   React 19 + Vite      │     │  Flutter/Dart (Android/iOS) │
│   PROJECT 2/frontend/  │     │  Flutter-code/              │
└──────────┬─────────────┘     └────────────┬───────────────┘
           │  HTTP + HttpOnly Cookies         │  HTTP + Bearer Token
           │  credentials: 'include'          │  Authorization Header
           ▼                                  ▼
┌──────────────────────────────────────────────────────────┐
│              Shared Backend API  (:5000/api)             │
│              Node.js + Express 5 + TypeScript            │
│              PROJECT 2/backend/                          │
│                                                          │
│  ┌────────────┐  ┌───────────┐  ┌─────────────────────┐ │
│  │  Routes    │  │Controllers│  │  Services           │ │
│  │  authRoutes│  │authCtrl   │  │  emailService       │ │
│  │  taskRoutes│  │taskCtrl   │  │  cloudinaryService  │ │
│  │  leaveRoutes│ │leaveCtrl  │  │  smsService         │ │
│  │  empRoutes │  │empCtrl    │  │  notificationService│ │
│  │  notifRoutes│ │dashCtrl   │  └─────────────────────┘ │
│  └────────────┘  └───────────┘                          │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ Middleware: verifyToken → requireAdmin              │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────┬───────────────────────────┘
                               │  Mongoose ODM
                               ▼
              ┌─────────────────────────────────┐
              │  MongoDB                        │
              │  Collections:                  │
              │  users, tasks, leaves,         │
              │  notifications, otps,           │
              │  activitylogs, archivedusers    │
              └─────────────────────────────────┘
                               │
             ┌─────────────────┼──────────────────┐
             ▼                 ▼                  ▼
      ┌────────────┐   ┌──────────────┐   ┌────────────────┐
      │ Cloudinary │   │  Nodemailer  │   │  Twilio SMS    │
      │ (Image CDN)│   │  (SMTP Email)│   │  (Phone OTP)   │
      └────────────┘   └──────────────┘   └────────────────┘
```

### Shared Backend — Evidence

The backend explicitly configures CORS to allow both web browser origins **and** Expo/mobile origins from the same server (`server.ts` L37–68):

```typescript
// PROJECT 2/backend/src/server.ts  L53–65
origin.includes('localhost') ||
origin.includes('172.16.')  ||   // LAN physical devices
origin.includes('192.168.') ||
origin.startsWith('exp://')  ||   // Expo Go mobile client
origin.includes(':8081')         // React Native Metro
```

The Flutter mobile client targets the same port 5000 at the same LAN IP (`Flutter-code/lib/core/config/api_config.dart` L7, L43):

```dart
static const String defaultLanIp = '172.16.2.15';  // same as backend default
static const int defaultPort = 5000;
```

Both the web frontend and Flutter mobile client call the identical API endpoint namespaces (`/api/login`, `/api/tasks`, `/api/employees`, etc.).

---

## 3. Technology Stack

### Web Frontend (`PROJECT 2/frontend/`)

| Technology | Version | Purpose |
|---|---|---|
| React | ^19.2.7 | UI component library |
| TypeScript | ~6.0.2 | Type-safe JavaScript |
| Vite | ^8.1.1 | Build tool and dev server |
| React Router DOM | ^7.18.1 | Client-side routing |
| React Hook Form | ^7.81.0 | Form state management |
| Zod | ^4.4.3 | Schema-based form validation |
| `@hookform/resolvers` | ^5.4.0 | Zod ↔ React Hook Form bridge |
| Tailwind CSS | ^3.4.19 | Utility-first CSS |
| Framer Motion | ^12.42.2 | Animations and transitions |
| Recharts | ^3.10.1 | Analytics charts |
| Lucide React | ^1.23.0 | Icon library |
| date-fns | ^4.4.0 | Date formatting and manipulation |
| react-hot-toast | ^2.6.0 | Toast notifications |
| react-phone-input-2 | ^2.15.1 | International phone input |
| oxlint | ^1.71.0 | Fast linter (Rust-based) |

### Mobile Frontend (`Flutter-code/`)

| Technology | Version | Purpose |
|---|---|---|
| Flutter SDK | ≥3.10.0 | Cross-platform mobile framework |
| Dart SDK | ≥3.0.0 | Language |
| flutter_riverpod | ^2.5.1 | State management |
| Dio | ^5.4.3+1 | HTTP client with interceptors |
| flutter_secure_storage | ^9.2.2 | Encrypted token storage |
| shared_preferences | ^2.2.3 | Local preferences persistence |
| google_fonts | ^6.2.1 | Inter font family |
| image_picker | ^1.1.2 | Profile photo selection |
| phone_numbers_parser | ^9.0.26 | ITU phone validation |
| intl | ^0.19.0 | Date/locale formatting |

### Shared Backend (`PROJECT 2/backend/`)

| Technology | Version | Purpose |
|---|---|---|
| Node.js | LTS | Runtime |
| Express | ^5.2.1 | HTTP framework |
| TypeScript | ^6.0.3 | Type-safe Node.js |
| Mongoose | ^9.7.4 | MongoDB ODM |
| jsonwebtoken | ^9.0.3 | JWT generation and verification |
| bcryptjs | ^3.0.3 | Password hashing |
| cookie-parser | ^1.4.7 | HttpOnly cookie parsing |
| helmet | ^8.3.0 | Security HTTP headers |
| cors | ^2.8.6 | Cross-origin request handling |
| express-rate-limit | ^8.6.2 | Rate limiting |
| nodemailer | ^9.0.3 | SMTP email delivery |
| cloudinary | ^2.10.0 | Image CDN upload/delete |
| twilio | ^6.0.2 | SMS OTP delivery |
| libphonenumber-js | ^1.13.9 | E.164 phone validation |
| dotenv | ^17.4.2 | Environment variable loading |
| nodemon | ^3.1.14 | Dev hot-reload |
| ts-node | ^10.9.2 | TypeScript execution |

### Database

| Technology | Purpose |
|---|---|
| MongoDB | Primary document database |
| Mongoose | ODM — schema definition, validation, query interface |

---

## 4. Application Features

### 4.1 Registration with OTP Verification

**Purpose:** New users self-register with verified email (and optionally phone) before account creation.

**Frontend (Web):** `Register.tsx` → multi-step form; `OTPInput.tsx` for 6-digit code entry; `PasswordInput.tsx` with strength meter.

**Backend:**
1. `POST /api/send-email-otp` — generates a 6-digit OTP via `crypto.randomInt()`, hashes it with SHA-256, stores it in the `Otp` collection (TTL: 10 minutes), and dispatches the OTP email via Nodemailer.
2. `POST /api/verify-email-otp-public` — verifies the hashed OTP with brute-force protection (max 7 attempts; 10-minute lockout on failure).
3. `POST /api/send-phone-otp-public` — optional; sends OTP via Twilio SMS.
4. `POST /api/register` — validates OTPs, runs server-side validators (`validatePasswordStrength`, `validateFirstName`, `validateLastName`, `validatePhoneNumber`), hashes password with `bcrypt.hash(password, 10)`, optionally uploads profile picture to Cloudinary, creates the `User` document with `role: 'employee'` always enforced, issues JWT access/refresh tokens, and sets HttpOnly cookies.

**Database:** `users` collection + `otps` collection (TTL auto-delete).

**User Flow:**
```
User fills form → Frontend validation (Zod schema)
→ POST /send-email-otp → Email dispatched
→ User enters OTP → POST /verify-email-otp-public → verified
→ Optional: POST /send-phone-otp-public + verify
→ POST /register → password hashed, user saved, tokens issued
→ AuthContext.login() called → navigate to dashboard
```

---

### 4.2 Login

**Purpose:** Authenticate returning users and issue session tokens.

**Frontend (Web):** `Login.tsx` — email/password form with "Remember Me" checkbox.

**Backend (`POST /api/login`):**
- Finds user by email; checks `isBlocked` and `status === 'BLOCKED'` before password comparison.
- Calls `bcrypt.compare(password, user.password)` — credentials never stored or logged in plain text.
- Generates access token (10 minutes, HS256) and refresh token (30 days, HS256) via `jwt.sign()`.
- SHA-256 hashes the refresh token and stores the hash in `user.refreshTokenHash`.
- Sets three HttpOnly cookies: `accessToken`, `token` (compatibility alias), and `refreshToken`.
- Returns a user object (no password field) and raw tokens in the response body for mobile client Bearer header use.

**Database:** Reads `users`; updates `refreshTokenHash` + `refreshTokenExpiresAt`.

---

### 4.3 Token Refresh with Reuse Detection

**Purpose:** Maintain sessions without requiring re-login, while detecting stolen tokens.

**Backend (`POST /api/refresh`):**
- Accepts the refresh token from HttpOnly cookie, request body, or `x-refresh-token` header — enabling both web (cookie) and mobile (header/body) clients.
- Verifies JWT signature with HS256.
- Looks up the user and compares `SHA-256(incomingToken)` against `user.refreshTokenHash`.
- **Reuse detection:** If the hashes do not match (old or stolen token presented), clears `refreshTokenHash` entirely — revoking all active sessions for that user.
- On success, issues a new access token AND rotates the refresh token (old one is immediately invalidated).

**Web Frontend:** `fetchWithAuth()` in `apiClient.ts` — automatically calls `/api/refresh` on any 401 response, queuing concurrent failed requests until refresh completes before replaying them.

**Mobile Frontend:** `DioClient` in `dio_client.dart` — same queue-deduplication pattern using `List<Completer>`.

---

### 4.4 Forgot Password (OTP-Gated Reset)

**Purpose:** Allow users to securely reset a forgotten password via email OTP.

**Backend (3-step flow):**
1. `POST /api/forgot-password-otp` — verifies the email exists, generates and sends OTP.
2. `POST /api/verify-forgot-password-otp` — validates OTP (7-attempt lockout). OTP record is **not** deleted yet; it is reused by the next step.
3. `POST /api/reset-password` — verifies OTP again, enforces `validatePasswordStrength()` server-side, hashes new password, clears `refreshTokenHash` (invalidating all active sessions), deletes OTP.

---

### 4.5 Admin Dashboard

**Purpose:** Give admins an at-a-glance view of organisational task health and pending leave.

**Frontend (Web):** `AdminDashboard.tsx` — stat cards (Total Tasks, In Progress, Pending, Completed), recent task list with status badges.

**Backend (`GET /api/dashboard/admin`, admin-only):** `dashboardController.ts` — aggregates task counts by status from the `tasks` collection, pending leave count from `leaves`, and returns combined statistics.

**User Flow:**
```
AdminLayout → AdminDashboard component mounts
→ fetchWithAuth(API_ENDPOINTS.DASHBOARD_ADMIN)
→ verifyToken → requireAdmin → getAdminDashboard
→ MongoDB aggregation → JSON response → UI renders stat cards
```

---

### 4.6 Task Management

**Purpose:** Admins create, assign, edit, delete tasks; employees update their status and progress.

**Frontend (Web):** `TaskManagement.tsx` (list/filter/search); `AssignTask.tsx` (create form); `TaskDetailModal.tsx`, `TaskEditModal.tsx`, `TaskStatusUpdateModal.tsx`.

**Backend routes (`/api/tasks`):**

| Operation | Who | Endpoint | Business Rule |
|---|---|---|---|
| List tasks | Both | `GET /tasks` | Employees see only their own; admins see all (filterable by `status`, `priority`, `category`, `assignedTo`) |
| Create task | Admin | `POST /tasks` | Task can only be assigned to active, non-admin users; always starts as `Pending` |
| Get by ID | Both | `GET /tasks/:id` | |
| Full update | Both | `PUT /tasks/:id` | |
| Delete | Admin | `DELETE /tasks/:id` | Triggers `task_deleted` notification |
| Update status | Both | `PATCH /tasks/:id/status` | Triggers `task_status_changed` notification |
| Update progress | Both | `PATCH /tasks/:id/progress` | 0–100 integer |
| Reassign | Admin | `PATCH /tasks/:id/assign` | |
| Change priority | Admin | `PATCH /tasks/:id/priority` | Triggers `priority_changed` notification |

**Database:** `tasks` collection — each task has `assignedTo` and `createdBy` as `ObjectId` refs to `users`. `comments` is an embedded array of subdocuments.

**Notifications:** Every task mutation automatically calls `createNotification()` in `notificationService.ts`, which silently inserts a `Notification` document. Failures never propagate to the primary request.

---

### 4.7 Employee Management (Admin)

**Purpose:** Admins manage the employee lifecycle — onboard, edit, block, archive, restore.

**Frontend (Web):** `EmployeeManagement.tsx` (list, search, add); `EmployeeProfile.tsx` (detail view, task list, block/unblock).

**Backend routes (`/api/employees`, all admin-only except self-routes):**
- Create employee: `POST /employees` — generates a temporary password, creates the user with `firstLogin: true`, and dispatches a welcome email via `emailService.sendWelcomeEmail()` with login credentials.
- Block: `PUT /employees/:id/block` — sets `isBlocked: true`, `status: BLOCKED`, records `blockedBy`, `blockedAt`, `blockReason`.
- Unblock: `PUT /employees/:id/unblock` — restores `isBlocked: false`, `status: ACTIVE`.
- Delete (archive): `DELETE /employees/:id` — moves the user document to the `ArchivedUser` collection and removes from `users`.
- Restore: `PUT /employees/:id/restore` — moves the document back from `archivedusers` to `users`.
- Get employee tasks: `GET /employees/:id/tasks` — returns all tasks assigned to the specified employee.

---

### 4.8 Leave Management

**Purpose:** Employees apply for leave; admins review and approve or reject.

**Frontend (Web):** `MyLeaves.tsx` (employee); `AdminLeaveManagement.tsx` (admin); `ApplyLeaveModal.tsx`; `AdminLeaveReviewModal.tsx`.

**Backend routes (`/api/leaves`):**

| Operation | Who | Endpoint |
|---|---|---|
| Apply for leave | Employee | `POST /leaves` |
| View leaves | Both | `GET /leaves` (scoped by role) |
| View single leave | Both | `GET /leaves/:id` |
| Cancel pending leave | Employee | `PATCH /leaves/:id/cancel` |
| Approve or Reject | Admin | `PATCH /leaves/:id/status` |

**Database:** `Leave` model — `employee` references `User`. `approvedBy` is set only on admin action. A compound index `{ employee, startDate, endDate }` supports overlap detection. `reason` has `minlength: 10`, `maxlength: 500` enforced at schema level.

---

### 4.9 User Profile & Contact Verification

**Purpose:** All users manage their own profile details, profile picture, and contact verification status.

**Frontend (Web):** `Profile.tsx` — inline editing; `EmailVerificationBanner.tsx`, `EmailVerificationModal.tsx`, `PhoneVerificationModal.tsx`.

**Backend routes (`/api/employees`, self-routes available to any authenticated user):**
- `GET /employees/profile` — returns own profile.
- `PUT /employees/profile` — updates bio, qualification, department, designation, and optionally profile/cover photos (uploaded to Cloudinary).
- `POST /employees/send-verification-email` — sends a 6-digit email verification OTP stored on the User document with 15-minute expiry and lockout.
- `POST /employees/verify-email` — verifies the OTP and sets `user.emailVerified = true`.
- `POST /employees/send-phone-otp` → `POST /employees/verify-phone-otp` — same flow for phone.
- `POST /employees/profile/initiate-contact-change` → `POST /employees/profile/verify-contact-change` — OTP-gated flow for changing email or phone on an existing account.
- `POST /employees/change-temporary-password` — enforced on first login (`firstLogin: true`); clears the flag on success.
- `DELETE /employees/me` — self-account deletion.

---

### 4.10 Notifications

**Purpose:** Real-time-ish event feed for task and account events.

**Frontend (Web):** `Notifications.tsx` — unread badge count, mark-individual-read, mark-all-read, archive, delete.

**Backend routes (`/api/notifications`):**

| Endpoint | Purpose |
|---|---|
| `GET /notifications` | Fetch own notifications |
| `PATCH /notifications/read-all` | Bulk mark all as read |
| `PATCH /notifications/:id/read` | Mark single as read |
| `PATCH /notifications/:id/archive` | Archive single |
| `DELETE /notifications/clear-all` | Delete all |
| `DELETE /notifications/:id` | Delete single |

Notifications are created server-side as a side effect of task operations in `notificationService.createNotification()`.

---

### 4.11 Analytics & Reports

**Frontend (Web):** `Analytics.tsx` — Recharts charts for task status distribution and priority breakdown. `Reports.tsx` — employee performance comparison.

**Backend:** Reuses `GET /api/tasks` (with admin's unfiltered access) and `GET /api/users` for employee-level breakdown. No dedicated report aggregation endpoint.

---

### 4.12 Activity Log

**Purpose:** An audit trail of significant actions within the system.

**Backend:** `GET /api/activity` (authenticated, no role restriction) — returns `ActivityLog` documents. Logs are created automatically by `notificationService.createActivityLog()` on actions like task assignments, employee onboarding, and password changes.

---

### 4.13 Settings (Web)

**Frontend (Web):** `Settings.tsx` — Light/Dark theme toggle; custom backend URL override (dev mode, guarded by `kReleaseMode` equivalent); connection test that pings `/api/me` to verify backend reachability.

**Mobile:** `settings_screen.dart` — same theme toggle; backend URL override with `ApiConfig.setCustomBaseUrl()` persisted to `SharedPreferences`.

---

## 5. Frontend Architecture — Web

### Framework & Build

The web frontend is a **React 19 SPA** built with **Vite 8** and written in **TypeScript**. It uses `@vitejs/plugin-react` for fast refresh during development. The linter is **oxlint** (Rust-based, replacing ESLint).

### Folder Structure

```
PROJECT 2/frontend/src/
├── App.tsx                     # Route declarations
├── main.tsx                    # React root; providers
├── config/
│   └── api.ts                  # All API endpoint constants (dynamic base URL from window.location)
├── contexts/
│   ├── AuthContext.tsx          # Auth state, login/logout, session management
│   └── ThemeContext.tsx         # Dark/light mode with localStorage persistence
├── lib/
│   ├── apiClient.ts            # fetchWithAuth() — 401 auto-refresh + queue
│   ├── toast.ts                # Typed toast helpers
│   └── utils.ts                # Utility functions
├── layouts/
│   ├── AdminLayout.tsx         # Admin shell (sidebar + header)
│   └── EmployeeLayout.tsx      # Employee shell
├── components/
│   ├── guards/ProtectedRoute.tsx  # Route-level auth + role guard
│   ├── ui/                        # Reusable UI primitives
│   │   ├── Button.tsx, Input.tsx, Modal.tsx, Table.tsx …
│   │   ├── OTPInput.tsx
│   │   ├── PasswordInput.tsx
│   │   ├── PhoneInput.tsx
│   │   └── ThemeToggle.tsx
│   ├── EmailVerificationBanner.tsx
│   ├── PhoneVerificationModal.tsx
│   └── VerificationReminderPopup.tsx
├── features/
│   ├── auth/
│   │   ├── pages/              # Login, Register, ForgotPassword, VerifyEmail, VerifyPhone
│   │   ├── schemas/auth.schema.ts   # Zod schemas for form validation
│   │   ├── components/AuthLayout.tsx
│   │   └── services/signupSession.ts
│   ├── admin/pages/            # AdminDashboard, EmployeeManagement, TaskManagement, …
│   ├── employee/pages/         # EmployeeDashboard, MyTasks, Calendar
│   ├── leaves/                 # MyLeaves, AdminLeaveManagement, modals
│   ├── tasks/                  # TaskDetailModal, TaskEditModal, TaskStatusUpdateModal
│   └── profile/pages/Profile.tsx
├── hooks/
│   ├── useOtpCooldown.ts       # OTP resend cooldown timer
│   └── useTheme.ts             # Theme hook
├── providers/
│   └── ConfirmProvider.tsx     # Global confirmation dialog provider
├── types/
│   └── models.ts               # Shared TypeScript types (UserProfile, Task, Leave, …)
└── utils/
    ├── validators.ts           # Client-side field validators
    ├── emailValidation.ts      # Email format validation
    ├── inputFilters.ts         # Input character filters
    └── secureStorage.ts        # sessionStorage wrapper for signup flow data
```

### Routing

Routes are declared in `App.tsx` using **React Router DOM v7**. Role enforcement uses a `ProtectedRoute` wrapper that reads `user.role` from `AuthContext` and either renders the child routes or redirects:

```
/login, /register, /verify-email, /verify-phone, /forgot-password  → Public
/admin/*    → ProtectedRoute(allowedRoles=['admin']) → AdminLayout
/employee/* → ProtectedRoute(allowedRoles=['employee']) → EmployeeLayout
```

Authenticated users landing on public paths are redirected automatically by `AuthContext` to their role-appropriate dashboard (`/admin/dashboard` or `/employee/dashboard`).

### Authentication State

`AuthContext` (`contexts/AuthContext.tsx`) manages the session:

- On application load, it calls `GET /api/me` (via `fetchWithAuth`) to rehydrate the user object from the server-side cookie session.
- A `localStorage` flag (`taskflow_session_active`) is used as a hint to skip the network request on public pages when no session is expected.
- `login()` accepts a `UserProfile` object and navigates to the appropriate dashboard.
- `logout()` calls `POST /api/logout` (best-effort), clears localStorage and sessionStorage, sets `user` to `null`, and navigates to `/login`.

### API Communication

All authenticated requests go through `fetchWithAuth()` in `lib/apiClient.ts`:
- Sets `credentials: 'include'` so HttpOnly cookies are automatically sent.
- Intercepts 401 responses, calls `POST /api/refresh` once, queues any concurrent 401s, then replays all queued requests after refresh succeeds.
- On blocked/deleted account errors (`Account no longer exists`, `Account has been blocked`), shows a toast and redirects to `/login` immediately.

### Form Validation

Forms use **React Hook Form** with **Zod** schemas for declarative validation. Schemas live in `features/auth/schemas/auth.schema.ts` and `features/leaves/schemas/leave.schema.ts`. Server-side validation errors are mapped back to field-level errors in the form state.

### Theme

`ThemeContext.tsx` stores the current theme (`light`/`dark`) in `localStorage` and applies a CSS class to the document root. `ThemeToggle.tsx` provides the UI switch.

---

## 6. Frontend Architecture — Mobile (Flutter)

### Framework & Pattern

The Flutter client is structured around **Riverpod 2** for state management and **Dio** for HTTP. It follows a **feature-first** folder structure with layered `data/`, `presentation/` subdirectories per feature.

### Key Differences from Web Client

| Concern | Web Client | Mobile Client |
|---|---|---|
| Token transmission | HttpOnly cookies (`credentials: 'include'`) | Bearer token in `Authorization` header |
| Token storage | Server HttpOnly cookie (not accessible to JS) | `FlutterSecureStorage` (Android: `encryptedSharedPreferences`) |
| State management | React Context | Riverpod `StateNotifier` |
| HTTP client | `fetch()` with `fetchWithAuth()` wrapper | `Dio` with interceptor chain |
| Navigation | React Router DOM | Named routes + `SlidePageRoute` |
| Theme storage | `localStorage` | `SharedPreferences` |

### API URL Resolution

The mobile client resolves the backend base URL dynamically based on platform (`api_config.dart`):
- Android/iOS physical device: LAN IP `172.16.2.15:5000/api`
- Development override: user-configurable via Settings screen, persisted to `SharedPreferences`
- Release build: `--dart-define=API_URL=<url>` compile-time constant

Both clients ultimately reach the same backend endpoint namespace.

---

## 7. Shared Backend Architecture

**Location:** `PROJECT 2/backend/`

The backend is a **Node.js + Express 5** application written in **TypeScript**, compiled with `tsc` and executed with `ts-node` in development (via `nodemon`). It follows an **MVC-adjacent** pattern with a Services layer for cross-cutting concerns (email, image upload, notifications).

### Server Startup Sequence

```
src/server.ts
│
├── 1. Apply Helmet (CSP, XSS, noSniff)
├── 2. CORS (allowedOrigins list + Expo/LAN wildcard)
├── 3. Rate limiters:
│      authLimiter: 30 req / 15 min (prod) on auth endpoints
│      apiLimiter:  3000 req / 15 min (prod) on all /api/* routes
├── 4. cookieParser, express.json (10 MB limit)
├── 5. Mount routes:
│      /api           → authRoutes
│      /api/tasks     → taskRoutes
│      /api/employees → employeeRoutes
│      /api/dashboard → dashboardRoutes
│      /api/notifications → notificationRoutes
│      /api/activity  → activityRoutes
│      /api/leaves    → leaveRoutes
└── 6. connectDB() → app.listen(0.0.0.0:5000)
```

### Request Lifecycle

```
Client HTTP Request
       ↓
Rate Limiter (express-rate-limit)
       ↓
CORS Check
       ↓
Route Match (Express Router)
       ↓
verifyToken middleware
  ├── reads accessToken from cookie OR Authorization header
  ├── jwt.verify() with HS256 algorithm enforcement
  ├── User.findById() DB check (real-time blocked/deleted detection)
  └── sets req.user = { id, role }
       ↓
requireAdmin middleware (admin-only routes)
  └── User.findById() → checks role === 'admin'
       ↓
Controller Function
  ├── Input validation
  ├── Business logic
  ├── Service calls (email, Cloudinary, notifications)
  └── Database operations (via Mongoose)
       ↓
JSON Response
       ↓
Client
```

### Controllers

| File | Handles |
|---|---|
| `authController.ts` | Registration OTP flow, login, logout, token refresh (with reuse detection), forgot-password OTP, reset-password, `/me`, `/users` |
| `taskController.ts` | Task CRUD, status/progress/assign/priority patches, notification side-effects |
| `employeeController.ts` | Employee CRUD, block/unblock, archive/restore, self-profile edit, email/phone verification, contact change OTP flow, temporary password change |
| `dashboardController.ts` | Admin and employee dashboard aggregations |
| `leaveController.ts` | Apply, list, cancel, approve/reject leaves |
| `notificationController.ts` | Fetch, mark-read, archive, delete notifications |
| `activityController.ts` | Return activity log entries |

### Middleware

| File | Purpose |
|---|---|
| `authMiddleware.ts` | JWT verification via cookie or Bearer header; real-time account status check; populates `req.user` |
| `roleMiddleware.ts` | `requireAdmin` — re-queries DB to confirm `role === 'admin'`; cannot be bypassed by token manipulation |

### Services

| File | Responsibility |
|---|---|
| `emailService.ts` | Nodemailer SMTP client; supports Gmail and generic SMTP; falls back to Ethereal test mailbox in development. Sends OTP emails, welcome emails (with temporary password), and verification OTP emails |
| `cloudinaryService.ts` | Upload (base64 → Cloudinary), delete, and update image assets; validates MIME type, 5 MB size limit, and binary magic bytes (JPEG: `FFD8FF`, PNG: `89504E47`, WebP: `52494646…57454250`) |
| `smsService.ts` | Twilio SMS — sends OTP via `client.messages.create()`; falls back to `console.log` simulation in development when credentials are absent |
| `notificationService.ts` | `createNotification()` and `notifyAdmins()` — silently insert Notification documents; `createActivityLog()` — insert ActivityLog documents |

### Configuration

| File | Purpose |
|---|---|
| `config/db.ts` | `mongoose.connect(ENV.MONGODB_URI)` |
| `config/env.ts` | Validates all required environment variables at startup; enforces minimum 32-character secrets in production |
| `config/security.ts` | (present in repo; security-related constants) |

---

## 8. Authentication & Authorization

### Registration Flow

```
Client → POST /api/send-email-otp
  └── generateOtp() [crypto.randomInt — CSPRNG]
  └── hashToken(otp) [SHA-256]  → stored in Otp collection (TTL 10 min)
  └── emailService.sendOTP()

Client → POST /api/verify-email-otp-public
  └── OTP retrieved from DB
  └── hashToken(input) compared to stored hash
  └── 7-attempt lockout enforced

Client → POST /api/register
  └── Validates OTPs (email required, phone optional)
  └── Server-side: validatePasswordStrength(), validateFirstName(), validatePhoneNumber()
  └── bcrypt.hash(password, 10) — cost factor 10
  └── User.create({ role: 'employee' }) — role always forced to employee
  └── generateAccessToken(userId, role) — jwt.sign, HS256, 10 min
  └── generateRefreshToken(userId) — jwt.sign, HS256, 30 days
  └── user.refreshTokenHash = SHA-256(refreshToken) — only hash stored in DB
  └── setTokenCookies() → 3 HttpOnly cookies
```

### Login Flow

```
Client → POST /api/login
  └── User.findOne({ email })
  └── Checks isBlocked / status === 'BLOCKED'
  └── bcrypt.compare(password, user.password)
  └── generateAccessToken + generateRefreshToken
  └── user.refreshTokenHash = SHA-256(refreshToken)
  └── setTokenCookies() — httpOnly: true, secure: true (prod), sameSite: 'lax'
  └── Response: { token, refreshToken, user } — no password field
```

### Token Architecture

| Token | Duration | Storage (Web) | Storage (Mobile) | Transport |
|---|---|---|---|---|
| Access Token | 10 minutes | HttpOnly cookie `accessToken` | `FlutterSecureStorage` (encrypted) | Cookie / Bearer header |
| Refresh Token | 30 days | HttpOnly cookie `refreshToken` | `FlutterSecureStorage` (encrypted) | Cookie / request body / `x-refresh-token` header |

The raw refresh token is never stored in the database — only its `SHA-256` hash is persisted in `user.refreshTokenHash`.

### Token Refresh with Reuse Detection

```
Client → POST /api/refresh (cookie or body)
  └── jwt.verify(token, REFRESH_SECRET, { algorithms: ['HS256'] })
  └── User.findById(decoded.id)
  └── SHA-256(incoming) vs user.refreshTokenHash
      ├── Match: issue new access + new refresh → ROTATE
      └── No match: REVOKE all sessions (refreshTokenHash cleared)
  └── Check refreshTokenExpiresAt < now → reject if expired
  └── New tokens issued and cookies updated
```

### Logout

```
Client → POST /api/logout
  └── Resolves userId from cookie or decoded refresh token
  └── User.findByIdAndUpdate(userId, { $unset: { refreshTokenHash, refreshTokenExpiresAt } })
  └── clearTokenCookies() — removes all three cookies
```

### Protected Route Guards

Every protected route applies `verifyToken` middleware first. For admin-only operations, `requireAdmin` is chained:

```typescript
// taskRoutes.ts — example
router.post('/', requireAdmin, createTask);      // Admin only
router.patch('/:id/status', patchStatus);        // Any authenticated user
```

`requireAdmin` performs a fresh database query (`User.findById`) to derive the role — the JWT role claim is not trusted alone.

### Role-Based Access Control

| Role | Capabilities |
|---|---|
| **admin** | All task operations; all employee management; leave approvals; admin dashboard; analytics; reports; user listing |
| **employee** | Own tasks (view/update status & progress); own leaves (apply/cancel); own profile; own notifications; employee dashboard |

Employees cannot access any `/api/employees/:id` (admin-only) endpoint; the server returns `403 Forbidden: Admins only`.

---

## 9. API Documentation

### Authentication APIs (`/api`)

| Method | Endpoint | Purpose | Auth | Role |
|---|---|---|---|---|
| POST | `/send-email-otp` | Send registration email OTP | None | Public |
| POST | `/verify-email-otp-public` | Verify registration email OTP | None | Public |
| POST | `/send-phone-otp-public` | Send registration SMS OTP | None | Public |
| POST | `/register` | Complete user registration | None | Public |
| POST | `/login` | Authenticate user | None | Public |
| POST | `/logout` | Invalidate session and clear cookies | Optional | Any |
| POST | `/refresh` | Rotate access + refresh tokens | Refresh token | Any |
| POST | `/forgot-password-otp` | Send password-reset OTP | None | Public |
| POST | `/verify-forgot-password-otp` | Verify password-reset OTP | None | Public |
| POST | `/reset-password` | Set new password (OTP-gated) | None | Public |
| GET | `/me` | Return current user profile | ✅ Access token | Any |
| GET | `/users` | List all users (paginated, filterable) | ✅ Access token | Admin |

### Task APIs (`/api/tasks`)

| Method | Endpoint | Purpose | Auth | Role |
|---|---|---|---|---|
| GET | `/tasks` | List tasks (scoped by role) | ✅ | Any |
| POST | `/tasks` | Create new task | ✅ | Admin |
| GET | `/tasks/:id` | Get task by ID | ✅ | Any |
| PUT | `/tasks/:id` | Full task update | ✅ | Any |
| DELETE | `/tasks/:id` | Delete task | ✅ | Admin |
| PATCH | `/tasks/:id/status` | Update task status | ✅ | Any |
| PATCH | `/tasks/:id/progress` | Update progress (0–100) | ✅ | Any |
| PATCH | `/tasks/:id/assign` | Reassign task to another employee | ✅ | Admin |
| PATCH | `/tasks/:id/priority` | Change task priority | ✅ | Admin |

### Employee APIs (`/api/employees`)

| Method | Endpoint | Purpose | Auth | Role |
|---|---|---|---|---|
| GET | `/employees` | List all employees | ✅ | Admin |
| POST | `/employees` | Create employee (sends welcome email) | ✅ | Admin |
| GET | `/employees/archived` | List archived employees | ✅ | Admin |
| GET | `/employees/profile` | Get own profile | ✅ | Any |
| PUT | `/employees/profile` | Update own profile | ✅ | Any |
| POST | `/employees/profile/initiate-contact-change` | Begin email/phone change with OTP | ✅ | Any |
| POST | `/employees/profile/verify-contact-change` | Complete contact change with OTP | ✅ | Any |
| POST | `/employees/change-temporary-password` | Change first-login temp password | ✅ | Any |
| POST | `/employees/send-verification-email` | Send email verification OTP | ✅ | Any |
| POST | `/employees/verify-email` | Verify email with OTP | ✅ | Any |
| POST | `/employees/send-phone-otp` | Send phone verification OTP | ✅ | Any |
| POST | `/employees/verify-phone-otp` | Verify phone with OTP | ✅ | Any |
| DELETE | `/employees/me` | Delete own account | ✅ | Any |
| GET | `/employees/:id` | Get employee by ID | ✅ | Admin |
| PUT | `/employees/:id` | Update employee | ✅ | Admin |
| PUT | `/employees/:id/restore` | Restore archived employee | ✅ | Admin |
| PUT | `/employees/:id/block` | Block employee | ✅ | Admin |
| PUT | `/employees/:id/unblock` | Unblock employee | ✅ | Admin |
| DELETE | `/employees/:id` | Archive (soft-delete) employee | ✅ | Admin |
| GET | `/employees/:id/tasks` | List tasks assigned to employee | ✅ | Admin |

### Leave APIs (`/api/leaves`)

| Method | Endpoint | Purpose | Auth | Role |
|---|---|---|---|---|
| POST | `/leaves` | Apply for leave | ✅ | Any |
| GET | `/leaves` | List leaves (scoped by role) | ✅ | Any |
| GET | `/leaves/:id` | Get leave by ID | ✅ | Any |
| PATCH | `/leaves/:id/cancel` | Cancel a pending leave | ✅ | Any |
| PATCH | `/leaves/:id/status` | Approve or reject leave | ✅ | Admin |

### Dashboard APIs (`/api/dashboard`)

| Method | Endpoint | Purpose | Auth | Role |
|---|---|---|---|---|
| GET | `/dashboard/admin` | Admin task + leave stats | ✅ | Admin |
| GET | `/dashboard/employee` | Employee personal task stats | ✅ | Any |

### Notification APIs (`/api/notifications`)

| Method | Endpoint | Purpose | Auth | Role |
|---|---|---|---|---|
| GET | `/notifications` | Get own notifications | ✅ | Any |
| PATCH | `/notifications/read-all` | Mark all as read | ✅ | Any |
| PATCH | `/notifications/:id/read` | Mark single as read | ✅ | Any |
| PATCH | `/notifications/:id/archive` | Archive single | ✅ | Any |
| DELETE | `/notifications/clear-all` | Delete all | ✅ | Any |
| DELETE | `/notifications/:id` | Delete single | ✅ | Any |

### Activity API (`/api/activity`)

| Method | Endpoint | Purpose | Auth | Role |
|---|---|---|---|---|
| GET | `/activity` | Get activity log | ✅ | Any |

---

## 10. Database Design

**Database:** MongoDB  
**ODM:** Mongoose 9  
**Connection:** `mongoose.connect(ENV.MONGODB_URI)` (`config/db.ts`)

### Models

| Model | Collection | Purpose |
|---|---|---|
| `User` | `users` | All platform users (admins and employees) |
| `Task` | `tasks` | Task assignments and progress tracking |
| `Leave` | `leaves` | Leave applications and decisions |
| `Notification` | `notifications` | In-app notifications per user |
| `Otp` | `otps` | Short-lived OTP records (TTL: 10 minutes) |
| `ActivityLog` | `activitylogs` | Audit trail of significant actions |
| `ArchivedUser` | `archivedusers` | Soft-deleted employee records |

### Model Details

**User** (`src/models/User.ts`)

| Field | Type | Notes |
|---|---|---|
| `firstName`, `lastName` | String | Required |
| `email` | String | Required, unique |
| `password` | String | Required — bcrypt hash only |
| `role` | Enum: `employee`, `admin` | Default: `employee` |
| `status` | Enum: `ACTIVE`, `INACTIVE`, `BLOCKED` | Default: `ACTIVE` |
| `phoneNumber`, `countryCode` | String | Phone required |
| `dob`, `gender`, `qualification`, `bio` | String | Optional profile fields |
| `profilePicture`, `coverPhoto` | String | Cloudinary CDN URLs |
| `profilePicturePublicId`, `coverPhotoPublicId` | String | Cloudinary deletion keys |
| `emailVerified`, `phoneVerified` | Boolean | Default: `false` |
| `firstLogin` | Boolean | Triggers temp-password change flow |
| `refreshTokenHash` | String | SHA-256 hash of active refresh token |
| `refreshTokenExpiresAt` | Date | Expiry enforced server-side |
| `isBlocked`, `blockedAt`, `blockedBy`, `blockReason` | Mixed | Admin block fields |
| `emailVerification*`, `phoneVerification*` | Mixed | OTP + lockout state on User document |
| `pendingEmail`, `pendingPhoneNumber` | String | Contact change staging |
| `contactChange*` | Mixed | OTP state for contact changes |
| `timestamps` | auto | `createdAt`, `updatedAt` |

**Task** (`src/models/Task.ts`)

| Field | Type | Notes |
|---|---|---|
| `title`, `description` | String | Required |
| `status` | Enum | `Pending`, `In Progress`, `Review`, `Completed`, `Blocked` |
| `priority` | Enum | `Low`, `Medium`, `High` |
| `dueDate` | String | Required |
| `category`, `tags` | String / [String] | |
| `estimatedTime` | Number | Hours |
| `progress` | Number | 0–100 |
| `comments` | [{user, text, createdAt}] | Embedded subdocuments |
| `assignedTo` | ObjectId → `User` | Required |
| `createdBy` | ObjectId → `User` | Required |
| `timestamps` | auto | |

**Leave** (`src/models/Leave.ts`)

| Field | Type | Notes |
|---|---|---|
| `employee` | ObjectId → `User` | Required; indexed |
| `startDate`, `endDate` | Date | Required; `startDate` indexed |
| `leaveType` | Enum | Casual, Sick, Earned, Unpaid, Maternity, Paternity, Compensatory |
| `reason` | String | Required; 10–500 chars |
| `totalDays` | Number | Required; min 1 |
| `status` | Enum | `Pending`, `Approved`, `Rejected`, `Cancelled`; indexed |
| `approvedBy`, `approvedAt` | ObjectId → `User` / Date | Set by admin action |
| `rejectionReason` | String | Max 300 chars |
| `cancelledAt` | Date | |
| Compound index | `{ employee, startDate, endDate }` | Overlap detection |

**Otp** (`src/models/Otp.ts`)

| Field | Type | Notes |
|---|---|---|
| `email` | String | Email or phone used as identifier |
| `otp` | String | SHA-256 hash of the 6-digit code |
| `attempts` | Number | Failed verification count |
| `lockoutUntil` | Date | Populated after 7 failed attempts |
| `createdAt` | Date | TTL index: auto-deletes after 600 seconds |

**Notification** (`src/models/Notification.ts`)

| Field | Type | Notes |
|---|---|---|
| `user` | ObjectId → `User` | Required; recipient |
| `title`, `message` | String | Required |
| `type` | Enum | 10 event types (task_assigned, task_updated, password_changed, etc.) |
| `taskId`, `taskTitle` | ObjectId → `Task` / String | Optional task reference |
| `sender`, `senderName` | ObjectId → `User` / String | Optional actor reference |
| `isRead`, `isArchived` | Boolean | Default: `false` |

**ActivityLog** (`src/models/ActivityLog.ts`)

| Field | Type | Notes |
|---|---|---|
| `user` | ObjectId → `User` | Required; actor |
| `action` | Enum | login, logout, task_assigned, task_updated, task_deleted, task_completed, employee_updated, employee_joined, password_changed, profile_updated |
| `description` | String | Required; human-readable summary |
| `timestamps` | auto | |

### Entity Relationships

```
User ──────────────────────────────────────────────────────┐
  │ (assignedTo, createdBy)                                │
  ├──── Task (many tasks per user)                         │
  │       └── comments[].user → User                      │
  │                                                        │
  ├──── Leave (employee field → User)                     │
  │       └── approvedBy → User                           │
  │                                                        │
  ├──── Notification (user field → User)                  │
  │       ├── taskId → Task                               │
  │       └── sender → User                               │
  │                                                        │
  ├──── ActivityLog (user field → User)                   │
  │                                                        │
  └──── (isBlocked) blockedBy → User                      │
                                                           │
ArchivedUser ← soft-deleted User document ─────────────────┘
```

---

## 11. Validation & Error Handling

### Server-Side Validation (Backend)

**Password strength** (`validators.ts` → `validatePasswordStrength()`):
- Minimum 8 characters, maximum 64 characters
- Must contain: uppercase, lowercase, digit, special character
- Must not contain spaces
- Applied at both registration and password reset

**Name validation** (`validateFirstName()`, `validateLastName()`):
- First name: 2–50 alphabetic characters only, no spaces
- Last name: allows spaces, hyphens, apostrophes; no leading spaces or double spaces

**Phone validation** (`validatePhoneNumber()`):
- 7–15 digits; rejects all-same-digit patterns
- Uses `libphonenumber-js` for E.164 format validation per country

**OTP lockout:**
- 7 failed attempts → 10-minute lockout stored on the OTP document
- Applies to: email OTP verification, phone OTP verification, forgot-password OTP

**Email uniqueness:** `User.findOne({ email })` before registration; Mongoose schema enforces `unique: true`.

**Task business rules:**
- Due date cannot be in the past
- Task cannot be assigned to an admin account
- Task cannot be assigned to a blocked employee

**Leave schema validation:** `reason` has `minlength: 10`, `maxlength: 500` enforced by Mongoose.

### Client-Side Validation (Web Frontend)

Zod schemas in `features/auth/schemas/auth.schema.ts` and `features/leaves/schemas/leave.schema.ts` validate forms before any API request is made. `react-hook-form` with `@hookform/resolvers` presents field-level error messages inline.

### Error Responses

The backend follows consistent JSON error response format:

```json
{ "message": "Human-readable error description", "code": "MACHINE_READABLE_CODE" }
```

Error codes (e.g., `TOKEN_EXPIRED`, `ACCOUNT_BLOCKED`, `NO_REFRESH_TOKEN`) allow clients to take differentiated actions rather than relying solely on HTTP status codes.

### Frontend Error Handling

- `fetchWithAuth()` checks for `Account no longer exists` and `Account has been blocked` messages and triggers immediate logout.
- `react-hot-toast` displays server-side error messages to the user.
- An `ErrorBoundary` component (`components/ErrorBoundary.tsx`) catches React render errors.

---

## 12. Security

### Password Storage

Passwords are hashed with `bcryptjs` at cost factor 10 (`bcrypt.hash(password, 10)`) before storage. Plain-text passwords are never stored, logged, or returned in any API response. The `User.select('-password')` projection is used consistently in all user-returning queries.

### JWT Security

- Both access and refresh token secrets are validated at startup (`env.ts`) — production secrets shorter than 32 characters cause a hard fatal error.
- HS256 algorithm is explicitly enforced via `{ algorithms: ['HS256'] }` in `jwt.verify()` to prevent algorithm-confusion attacks.
- Refresh tokens are stored as SHA-256 hashes only — the raw token is never persisted.
- Token reuse detection: presenting a previously-issued (stale) refresh token immediately revokes all active sessions for the affected user.

### Cookie Security

HttpOnly cookies are used for the web client — JavaScript in the browser cannot access these cookies:

```typescript
res.cookie('accessToken', token, {
  httpOnly: true,
  secure:   isProd,      // HTTPS-only in production
  sameSite: 'lax',
  maxAge:   10 * 60 * 1000,
});
```

### HTTP Security Headers

`helmet` is applied at the Express application level, providing:
- `Content-Security-Policy` (with explicit `defaultSrc 'self'`; Cloudinary CDN whitelisted for images)
- `X-XSS-Protection`
- `X-Content-Type-Options: nosniff`

### Rate Limiting

Two tiers of rate limiting (`express-rate-limit`):
- **Auth endpoints** (login, register, OTP): 30 requests per 15 minutes per IP in production.
- **General API**: 3,000 requests per 15 minutes per IP in production.
- Local/LAN IPs are exempted in development mode.

### CORS

Explicit allow-list for web origins; LAN subnets (`172.16.*`, `192.168.*`, `10.*`) and Expo origins (`exp://`) are allowed to support mobile development without exposing the API publicly.

### Image Upload Security

Cloudinary upload (`cloudinaryService.ts`) validates:
1. MIME type must be `image/jpeg`, `image/png`, or `image/webp`.
2. Maximum file size: 5 MB.
3. Binary magic bytes verified against declared MIME type to prevent MIME spoofing.

### Role Enforcement

`requireAdmin` middleware re-queries the database on every admin request — role cannot be spoofed via a crafted JWT because the server always derives the authoritative role from the live database record (`authMiddleware.ts` L55–56).

### Account State Checks

Every authenticated request checks `user.isBlocked` and `user.status` in the `verifyToken` middleware. Blocked or deleted accounts receive a `403` or `401` response immediately, regardless of token validity.

### Environment Variables

Secrets are never committed to source code. The `.env.example` file documents required variables with placeholder values. The `ENV` module in `config/env.ts` throws a `[FATAL]` error at startup if any required secret is missing.

---

## 13. Integrations & External Services

### 1. Nodemailer (SMTP Email)

**Purpose:** OTP delivery, welcome emails with temporary passwords, email verification codes.

**Location:** `PROJECT 2/backend/src/services/emailService.ts`

**Configuration:** SMTP credentials via `EMAIL_USER` / `EMAIL_APP_PASSWORD` / `EMAIL_HOST` environment variables. Gmail is auto-detected by domain. In development without credentials, automatically creates an **Ethereal** test mailbox and logs the preview URL.

**Emails sent:**
- Registration OTP (`sendOTP()`)
- In-app email verification OTP (`sendVerificationOtpEmail()`)
- New employee welcome with temporary password (`sendWelcomeEmail()`)

---

### 2. Cloudinary (Image CDN)

**Purpose:** Profile pictures and cover photos — uploaded as base64 data URLs from the client, stored in Cloudinary, CDN URLs saved to the database.

**Location:** `PROJECT 2/backend/src/services/cloudinaryService.ts`

**Data flow:**
```
Client submits base64 image
→ Backend validateImagePayload() [MIME + size + magic bytes]
→ cloudinary.uploader.upload(base64, { folder: 'taskflow/avatars' })
→ result.secure_url saved to User.profilePicture
→ result.public_id saved to User.profilePicturePublicId
→ Old image deleted via cloudinary.uploader.destroy(oldPublicId)
```

**Configuration:** `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET` in `.env`.

---

### 3. Twilio (SMS OTP)

**Purpose:** Optional phone number verification via SMS during registration and profile contact changes.

**Location:** `PROJECT 2/backend/src/services/smsService.ts`

**Data flow:**
```
Server generates 6-digit OTP → formatE164Phone(number) → twilio.messages.create()
```

**Fallback:** When Twilio credentials are absent (development), the OTP is logged to the console with `[SMS Simulation]` prefix — requests succeed without SMS delivery.

**Configuration:** `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_PHONE_NUMBER` in `.env`.

---

## 14. Testing & Quality Assurance

### Mobile Client Tests

The Flutter mobile client (`Flutter-code/test/`) contains **15 test files with 97 passing tests** (confirmed by `flutter test` run):

| Test File | Scope |
|---|---|
| `widget_test.dart` | App smoke test |
| `register_screen_test.dart` | Registration form |
| `register_back_button_test.dart` | Back navigation |
| `registration_enhancements_test.dart` | OTP step, edge cases |
| `validation_and_auth_audit_test.dart` | Validators: email, password, phone, name, DOB |
| `logout_confirmation_sheet_test.dart` | Logout bottom sheet UI + role-aware copy |
| `logout_flow_test.dart` | Full logout sequence |
| `dashboard_stat_card_filter_test.dart` | Stat card → filtered task list navigation |
| `admin_task_leave_management_test.dart` | Admin task CRUD and leave approval |
| `task_header_action_test.dart` | Task detail header actions |
| `profile_screen_test.dart` | Profile screen display and edit mode |
| `profile_screen_widget_test.dart` | Profile widget integration |
| `enterprise_audit_fixes_test.dart` | Dark mode button and dialog contrast |
| `theme_settings_test.dart` | Theme toggle persistence |
| `theme_synchronization_and_contrast_test.dart` | Theme reactive update across screens |

**All 97 tests pass. `flutter analyze` reports 0 issues.**

### Web Frontend Tests

No automated test files were found in `PROJECT 2/frontend/` (`*.test.ts` / `*.spec.ts`). The web frontend relies on manual testing and `oxlint` for static analysis.

### Backend Tests

No automated test files were found in `PROJECT 2/backend/`. Manual API testing is the current approach.

### Static Analysis

- **Web Frontend:** `oxlint` configured via `.oxlintrc.json`; run with `npm run lint`.
- **Flutter:** `flutter_lints ^3.0.0` dev dependency; `flutter analyze` passes with 0 issues.
- **Backend:** TypeScript compilation (`tsc --noEmit`) serves as the type-level static check.

---

## 15. Project Structure

```
Desktop/
├── PROJECT 2/                        # Primary project submission
│   ├── frontend/                     # React 19 + Vite web application
│   │   ├── src/
│   │   │   ├── App.tsx               # Route declarations
│   │   │   ├── main.tsx              # React root
│   │   │   ├── config/api.ts         # API endpoint constants
│   │   │   ├── contexts/             # AuthContext, ThemeContext
│   │   │   ├── lib/                  # apiClient.ts (fetchWithAuth)
│   │   │   ├── layouts/              # AdminLayout, EmployeeLayout
│   │   │   ├── components/guards/    # ProtectedRoute
│   │   │   ├── components/ui/        # Reusable UI primitives (17 components)
│   │   │   ├── features/
│   │   │   │   ├── auth/             # Login, Register, ForgotPassword, Verify*
│   │   │   │   ├── admin/pages/      # Dashboard, Employees, Tasks, Analytics, Reports…
│   │   │   │   ├── employee/pages/   # Dashboard, MyTasks, Calendar
│   │   │   │   ├── leaves/           # MyLeaves, AdminLeaveManagement
│   │   │   │   ├── tasks/            # Task modals
│   │   │   │   └── profile/          # Profile page
│   │   │   ├── hooks/                # useOtpCooldown, useTheme
│   │   │   ├── types/models.ts       # Shared TypeScript interfaces
│   │   │   └── utils/                # validators, emailValidation, secureStorage
│   │   ├── package.json
│   │   ├── vite.config.ts
│   │   └── tailwind.config.js
│   │
│   └── backend/                      # Shared Node.js + Express API
│       ├── src/
│       │   ├── server.ts             # App bootstrap: Helmet, CORS, rate limiters, route mount
│       │   ├── config/
│       │   │   ├── db.ts             # MongoDB connection
│       │   │   ├── env.ts            # Environment variable validation
│       │   │   └── security.ts
│       │   ├── controllers/          # authController, taskController, employeeController,
│       │   │                         # dashboardController, leaveController,
│       │   │                         # notificationController, activityController
│       │   ├── middleware/
│       │   │   ├── authMiddleware.ts  # verifyToken — JWT + DB account check
│       │   │   └── roleMiddleware.ts  # requireAdmin — DB-verified role check
│       │   ├── models/               # User, Task, Leave, Notification, Otp,
│       │   │                         # ActivityLog, ArchivedUser
│       │   ├── routes/               # authRoutes, taskRoutes, employeeRoutes,
│       │   │                         # leaveRoutes, notificationRoutes,
│       │   │                         # dashboardRoutes, activityRoutes
│       │   ├── services/             # emailService, cloudinaryService,
│       │   │                         # smsService, notificationService
│       │   ├── utils/
│       │   │   ├── validators.ts     # generateOtp, validatePasswordStrength,
│       │   │   │                     # validateFirstName, validatePhoneNumber, sanitizeUser
│       │   │   └── emailValidation.ts
│       │   └── scripts/seedAdmin.ts  # Admin seed script
│       ├── .env.example
│       ├── package.json
│       └── tsconfig.json
│
└── Flutter-code/                     # Flutter mobile application (also targets :5000/api)
    ├── lib/
    │   ├── main.dart
    │   ├── app.dart
    │   ├── core/
    │   │   ├── config/api_config.dart       # Dynamic LAN/emulator URL resolution
    │   │   ├── network/dio_client.dart      # Dio + interceptors + token refresh queue
    │   │   ├── storage/storage_service.dart # FlutterSecureStorage token management
    │   │   ├── theme/                       # AppTheme, AppColors, ThemeProvider
    │   │   ├── utils/validators.dart        # 535-line validator library
    │   │   └── widgets/                     # 17 reusable UI widgets
    │   └── features/                        # auth, dashboard, tasks, employees,
    │                                        # leaves, notifications, profile, settings,
    │                                        # calendar, reports, navigation
    ├── test/                                # 15 test files, 97 tests
    └── pubspec.yaml
```

---

## 16. Environment & Setup

### Prerequisites

- Node.js LTS (for backend and web frontend)
- Flutter SDK ≥ 3.10.0 (for mobile)
- MongoDB instance (local or Atlas)
- (Optional) Cloudinary account, Twilio account, Gmail App Password

### Backend Setup

```bash
# Navigate to backend
cd "PROJECT 2/backend"

# Install dependencies
npm install

# Create environment file
cp .env.example .env
# Edit .env with your values (see below)

# Development server (ts-node + nodemon)
npm run dev

# Production build and start
npm run build
npm start
```

**Required environment variables (`.env`):**

```env
PORT=5000
MONGODB_URI=mongodb://localhost:27017/auth_db
JWT_ACCESS_SECRET=<min_32_char_random_string>
JWT_REFRESH_SECRET=<min_32_char_random_string>
JWT_SECRET=<min_32_char_random_string>
NODE_ENV=development
APP_URL=http://localhost:5173

# Optional — email OTPs (falls back to Ethereal in dev if omitted)
GMAIL_USER=your@gmail.com
GMAIL_PASS=your_app_password

# Optional — profile picture upload
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=

# Optional — SMS OTP (simulated in console if omitted)
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_PHONE_NUMBER=
```

> **Note:** In production, all three JWT secrets must be ≥ 32 characters. The server will throw a fatal error and refuse to start otherwise.

### Web Frontend Setup

```bash
cd "PROJECT 2/frontend"
npm install
npm run dev          # Dev server at http://localhost:5173
npm run build        # Production build → dist/
npm run lint         # oxlint static analysis
```

The frontend auto-detects the backend URL from `window.location.hostname` — it assumes the backend is on the same host at port 5000. For a different setup, modify `src/config/api.ts`.

### Flutter Mobile Setup

```bash
cd Flutter-code
flutter pub get
flutter run                              # Run on connected device
flutter run --dart-define=API_URL=http://your-server:5000/api  # Override backend URL
flutter test                             # Run all 97 tests
flutter analyze                          # Static analysis (should report 0 issues)
```

The backend IP can also be changed at runtime via the Settings screen in the mobile app.

### Seed Admin Account

```bash
cd "PROJECT 2/backend"
npx ts-node src/scripts/seedAdmin.ts
```

---

## 17. Current Implementation & Limitations

### Fully Working Features

- Complete authentication lifecycle: registration with OTP, login, logout, token refresh with reuse detection, forgot-password with OTP
- Role-based access control for all API endpoints (admin and employee)
- Full task CRUD with assignment, status tracking, progress (0–100), priority, and comments
- Employee lifecycle management: onboard, block, unblock, archive, restore
- Leave management: apply, cancel, approve, reject with reason
- In-app notifications: per-event notification creation, mark-read, archive, clear
- Activity log: automatic recording of significant system events
- Profile management: edit, profile/cover photo upload to Cloudinary, email/phone OTP verification
- OTP-gated contact change (email or phone change on existing accounts)
- First-login temporary password enforcement
- Dark/light mode with persistence
- Analytics charts (Web: Recharts) and reports
- Weekly calendar view (Mobile: Flutter)
- Real-time backend URL configuration (Settings screen, both clients)
- 97/97 Flutter tests passing

### Partial or Conditional Features

- **SMS OTP (Twilio):** Fully implemented server-side, but requires a funded Twilio account with a provisioned phone number. In development, OTPs are printed to the server console.
- **Cloudinary image upload:** Fully implemented but requires Cloudinary credentials in `.env`. Without credentials, registration still succeeds without a profile picture.
- **Email delivery:** Requires configured SMTP credentials for production. Development falls back to Ethereal test mailbox — emails are not actually delivered to recipients.

### Known Limitations

- **No automated tests for web frontend or backend:** Only the Flutter mobile client has a test suite (97 tests). The React web frontend and Node.js backend do not have unit or integration tests.
- **No CI/CD pipeline:** No GitHub Actions or similar workflow is configured.
- **Reports computed client-side (mobile):** The Flutter reports screen derives analytics from locally-loaded task data rather than a dedicated server aggregation endpoint. This means reports only reflect tasks currently loaded in the provider state.
- **No WebSocket/real-time push:** Notifications are fetched via polling on page load — there is no persistent connection for real-time delivery.
- **No pagination on task list:** `GET /tasks` returns all tasks for the authenticated user without pagination. For large datasets, this will become a performance concern.
- **`qualification` field on User schema is not enforced as required** — `validateBeforeSave: false` is used in several `user.save()` calls to bypass schema validation for admin accounts (which don't have this field set).

---

## 18. Future Improvements

### Testing

- Add unit and integration tests for the Express backend (e.g., using Vitest + Supertest).
- Add component tests for the React web frontend (e.g., Vitest + React Testing Library).
- Add E2E tests across the full stack (e.g., Playwright for web, integration_test for Flutter).

### Performance

- Add pagination to `GET /tasks` — currently returns all records in a single query.
- Add server-side report aggregation endpoints to replace client-side computation.
- Add database indexes on `tasks.assignedTo`, `tasks.status`, and `tasks.createdAt` for query performance at scale.

### Real-Time Notifications

- Implement WebSocket (e.g., `socket.io`) or Server-Sent Events on the backend to push notifications to connected clients instead of requiring a page refresh or manual fetch.

### Deployment

- Add Dockerfile(s) for both backend and frontend.
- Configure a production-ready CI/CD pipeline.
- Implement environment-specific configuration for staging vs production.

### Security Hardening

- Add CSRF token protection for the web frontend (currently relies on `sameSite: 'lax'`).
- Add request body sanitization middleware (e.g., `express-mongo-sanitize`) to prevent NoSQL injection.
- Implement refresh token revocation list or family tracking for more granular session control.

### UX & Accessibility

- Add keyboard navigation and ARIA roles to custom UI components in the web frontend.
- Improve empty states and skeleton loading across both clients.
- Add task due-date reminder notifications generated by a scheduled backend job.

---

## 19. Conclusion

TaskFlow Enterprise is a complete, multi-client workforce management platform consisting of a **React 19 web application**, a **Flutter mobile application**, and a **shared Node.js + Express backend**, all connected to a **MongoDB** database.

The shared backend (`PROJECT 2/backend/`) serves both client applications over the same REST API at port 5000. The CORS configuration explicitly accommodates both browser origins and mobile/LAN clients simultaneously, and both clients implement identical token refresh queue logic to maintain seamless sessions.

The authentication system implements production-grade patterns: bcrypt password hashing, short-lived access tokens (10 minutes), long-lived refresh tokens (30 days) stored as SHA-256 hashes in the database, HttpOnly cookie transmission for web clients, Bearer token transmission for the mobile client, and automatic token reuse detection that revokes all sessions on suspicious activity.

The application delivers working features across the full user journey: registration with OTP-verified email and optional phone, role-differentiated dashboards, complete task lifecycle management with notifications, leave application and approval, employee onboarding and lifecycle management, profile editing with Cloudinary image upload, and activity logging.

The Flutter mobile client is the more thoroughly tested of the two frontends, with 97 passing tests across 15 test files covering auth flows, task management, leave management, theme synchronization, and navigation transitions. The web frontend and backend do not yet have automated tests — manual testing has been used for those components.

External integrations — Nodemailer for email, Twilio for SMS, and Cloudinary for image storage — are fully implemented with graceful development fallbacks that allow the application to run without configured third-party credentials.
