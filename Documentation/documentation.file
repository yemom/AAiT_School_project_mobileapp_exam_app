Overview
This document explains the architecture, features, tech stack, data model, and workflows of the exam app, and how to run, configure, and extend it.

1. Project Purpose & Features
Goal: A role-based online exam app for a school.

Roles:
- User (Student):
  - Sign up & log in.
  - See categories and exams.
  - Take exams and view results (user views under lib/views/user).
- Admin:
  - Manage categories and exams.
  - View dashboard stats (totals, recent exams, per-category distribution).
- Super Admin:
  - Has all admin powers.
  - Additionally approves/rejects admin requests.
  - Can promote users to Admin / SuperAdmin via backend and tools.

2. Tech Stack
- Frontend (mobile app): Flutter
  - Material UI, custom theme (lib/theme/theme.dart)
  - Animation: flutter_animate
- Backend: Firebase
  - Auth: firebase_auth (email/password)
  - Database: cloud_firestore
  - Functions: cloud_functions (Node.js) for secure promotions
- Admin tools:
  - Firebase Cloud Functions in functions/index.js
  - Node script scripts/make-super-admin.js to create the first SuperAdmin

3. Project Structure (key parts)
- pubspec.yaml
  - Flutter app definition & dependencies (firebase_core, firebase_auth, cloud_firestore, cloud_functions, flutter_animate, google_fonts, etc.).
- lib/main.dart
  - Initializes Firebase.
  - Sets up MaterialApp with AppTheme.theme.
  - Uses _AuthGate as home to decide which screen to show based on login + role.

Auth and Role Logic
- lib/service/auth.dart
  - Core auth + role service using FirebaseAuth + Firestore:
    - signup(...)
    - login(...)
    - isSuperAdmin()
    - isAdmin()
    - approveAdminRequest(...)
    - rejectAdminRequest(...)
    - signOut()
- lib/login.dart – login screen UI.
- lib/signup.dart – signup screen UI (User or Admin request).
- lib/service/authenticate.dart – auth wrapper screen that routes to login/signup (used after some flows).

Admin UI (lib/views/admin/)
- admin_home_screen.dart – main admin dashboard:
  - Shows total categories, total exams, recent exams.
  - Shows category-level exam stats.
  - Navigation to manage exams, categories, admin requests.
  - Only Super Admins see the “Manage Admin Requests” card.
- Other admin screens:
  - manage_exames_screen.dart
  - manage_categories_screen.dart
  - manage_admin_requests.dart
  - adminSignupForm.dart
  - etc.

User UI (lib/views/user/)
- home_screen.dart – main user dashboard:
  - Fetches categories from Firestore.
  - Search and filter categories.
  - Grid of category cards → navigates to:
    - category_screen.dart – see exams in a category.
    - exam_play_screen.dart – take exam.
    - exam_result_screen.dart – see results.

Models (lib/model/)
- category.dart – category model & fromMap.
- exam.dart – exam model.
- question.dart – question model.

Theme
- lib/theme/theme.dart – defines AppTheme colors, typography and shared styles.

Backend Code
- functions/index.js – Firebase Cloud Functions:
  - promoteToAdmin
  - promoteToSuperAdmin
- scripts/make-super-admin.js – Node script to set superAdmin claim on a UID.

4. State Management
- Approach: Built-in Flutter StatefulWidget + setState only.
- Each screen (Login, Signup, AdminHomeScreen, HomeScreen, etc.) keeps its own local state (loading flags, lists, filters, etc.).
- There is no Provider, Bloc, Riverpod, Redux, or GetX.
- Global information (like logged-in user’s role) is obtained by:
  - Listening to FirebaseAuth.instance.authStateChanges() in _AuthGate (in main.dart).
  - Querying Firestore users/<uid> when needed (for role).

This makes the architecture straightforward but means some repeated reads from Firestore instead of shared global state.

5. Authentication & Role Flow

5.1 _AuthGate (in main.dart)
Responsibility: Decide which first screen to show.
- Listens to auth.FirebaseAuth.instance.authStateChanges():
  - If no user ⇒ show Login.
  - If user logged in:
    - Fetch Firestore users/<uid> and read role field.
    - Normalize role & route:
      - "Admin" or "SuperAdmin" ⇒ AdminHomeScreen
      - "User" ⇒ HomeScreen
      - Unknown ⇒ back to Login.

This ensures that role changes in Firestore affect what screen you see at startup.

5.2 Signup Flow (Signup + AuthService.signup)
- User chooses name, email, password, role (User/Admin).
- AuthService.signup:
  - Creates Firebase Auth user.
  - Writes users/<uid>:
    - name, email
    - role: initially "User" (even if they selected Admin)
    - createdAt timestamp
  - If they selected Admin:
    - Creates adminRequests/<uid> with:
      - status: "pending"
      - requestedAt
    - Returns 'Admin' so the UI can say “Admin request submitted. Waiting for Super Admin approval.”

5.3 Login Flow (Login + AuthService.login)
- AuthService.login:
  - Signs in with email/password.
  - Reads users/<uid> from Firestore.
  - Looks at role:
    - superadmin ⇒ 'SuperAdmin'
    - admin ⇒ 'Admin'
    - else ⇒ 'User'
- UI (login.dart) maps:
  - 'Admin' or 'SuperAdmin' ⇒ AdminHomeScreen
  - 'User' ⇒ HomeScreen
  - Auth errors like firebase_auth/user-not-found, firebase_auth/wrong-password ⇒ friendly messages.

5.4 Admin Requests & Super Admin
- When a user chooses Admin during signup:
  - An adminRequests/<uid> doc with status: "pending" is created.
- Super Admin:
  - AuthService.isSuperAdmin() checks:
    - Firebase Auth custom claims (superAdmin), or
    - Firestore fields (role or isSuperAdmin).
  - In AdminHomeScreen, _isSuperAdmin controls showing the “Manage Admin Requests” card.
- Approve/reject is handled by AuthService.approveAdminRequest / rejectAdminRequest:
  - Update adminRequests/<userId> (status, approvedBy, approvedAt).
  - Update users/<userId> role (Admin or User).

6. Admin Dashboard & Management

6.1 AdminHomeScreen
Key responsibilities:
- Check super admin:
  - AuthService.isSuperAdmin() run on initState.
  - If true, subscribes to adminRequests with status == "pending" and counts them.
- Statistics:
  - Reads:
    - categories count.
    - exames count.
    - Latest exames ordered by createdAt.
    - For each category, counts how many exams belong to it.
  - Renders:
    - Total categories and exams.
    - Per-category exam counts with percentages.
    - Recent exams list (“Recent Activity”).
- Actions:
  - Card buttons to:
    - Manage exams (ManageExamesScreen).
    - Manage categories (ManageCategoriesScreen).
  - If super admin:
    - “Manage Admin Requests” tile with current pending count.
  - Logout icon:
    - Calls FirebaseAuth.instance.signOut() then navigates to Authenticate.

Other admin screens under lib/views/admin handle the actual CRUD for exams and categories.

7. User Experience (Student Side)

7.1 HomeScreen (User dashboard)
On initState:
- Fetches categories from Firestore (categories collection, ordered by createdAt).
- Maps to Category model list.

Maintains:
- _allCategories
- _filteredCategories
- _categoryFiltters = ["All", ...category names...]
- _selectedFiltter
- _searchController

UI:
- SliverAppBar:
  - App title.
  - “Welcome Student!” header and subtitle.
  - Search bar (filters _filteredCategories).
  - Logout icon → Authenticate after FirebaseAuth.instance.signOut().
- Horizontal ChoiceChips for category filters.
- SliverGrid of category cards:
  - Each card shows icon, category name, description.
  - Animated entry using flutter_animate.
  - On tap: CategoryScreen(category: category).

7.2 Exam Flow
- CategoryScreen (in lib/views/user/category_screen.dart):
  - Lists exams in a category.
- ExamPlayScreen:
  - Shows questions for a chosen exam and handles answering, timer, progress, etc.
- ExamResultScreen:
  - Shows the final score and/or breakdown, reading result data from Firestore or local state.

8. Firebase Cloud Functions & Scripts

8.1 Cloud Functions (functions/index.js)
- promoteToAdmin
  - Callable HTTPS function.
  - Requires caller to be authenticated and have superAdmin === true in their token.
  - Validates target uid.
  - Merges admin: true into target’s custom claims and sets Firestore user role to Admin.
- promoteToSuperAdmin
  - Callable HTTPS function.
  - Requires caller to be superAdmin.
  - Sets superAdmin: true and admin: true in custom claims.
  - Updates Firestore user role to SuperAdmin.

These are the secure backend entry points for promotion, beyond just Firestore field changes.

8.2 scripts/make-super-admin.js
Purpose: Bootstrap the first super admin from the CLI.
Usage:
- node scripts/make-super-admin.js <UID>
It:
- Uses firebase-admin.
- Fetches the user and merges superAdmin: true into their custom claims.
- After that, isSuperAdmin() in the app will return true for this user.

9. How to Run the Project

9.1 Prerequisites
- Flutter SDK compatible with Dart SDK ^3.7.2.
- Node.js and Firebase CLI (npm install -g firebase-tools).
- Firebase project created and configured (using FlutterFire to generate firebase_options.dart).

9.2 Frontend (Flutter app)
From the project root, run:
- flutter pub get
- flutter run
This will:
- Install dependencies.
- Build and run the app on your connected device/emulator.

9.3 Backend (Cloud Functions)
From the functions directory, run:
- cd functions
- npm install
- firebase deploy --only functions
Make sure firebase.json is pointing at your Firebase project.

9.4 Create the first Super Admin
- Sign up a user through the app (or directly in Firebase console).
- Get their UID from Firebase Auth.
- From the project root, run:
  - node scripts/make-super-admin.js <UID>
Now this user is a Super Admin and can:
- Access admin dashboard.
- Approve admin requests.
- Use admin-only features.

10. How to Extend the Project
- Add new user roles:
  - Extend AuthService.login, _AuthGate, and possibly Cloud Functions to support new roles.
  - Add new Firestore fields and custom claims for that role.
  - Add new screens or restrict existing screens based on role checks.
- Add new exam features:
  - e.g. time limits, question difficulty, negative marking:
  - Update exam.dart and Firestore schema.
  - Adjust admin exam creation forms.
  - Use new fields in ExamPlayScreen / ExamResultScreen.
- Improve state management:
  - Introduce Provider, Riverpod, or Bloc if you want:
    - Centralized auth state.
    - Shared exam state across screens.
    - Cleaner separation of presentation and logic.
- Enhance security:
  - Add Firestore security rules to enforce roles server-side, so that:
    - Only admins can write categories or exames.
    - Only super admins can approve admin requests.