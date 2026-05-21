# Context: Student Dashboard REST API & Mobile Integration (VELS Flavor)

This document provides system context, architecture, and integration details for the Student Dashboard feature implemented for the **VELS (VISTAS)** flavor in the College Management System.

---

## 1. Backend REST API Structure

The backend provides a secure REST API for the student dashboard. It dynamically scopes queries based on the authenticated user's token, preventing security cross-access.

*   **Endpoint:** `GET /api/profile/students/me/dashboard/`
*   **Authentication:** Requires a Bearer JWT Token in the `Authorization` header.
*   **Resolution Logic:** The `"me"` parameter is resolved to the authenticated student's `register_number` (or the child's `register_number` if queried by a parent). Students are prohibited from querying other students' data (returns `403 Forbidden`).
*   **Tenant Scoping:** Scoped to the `vels` tenant schema context.
*   **Payload structure:**
    *   `student_name` (String)
    *   `register_number` (String)
    *   `profile_photo_url` (String?)
    *   `assignments_due_this_week` (List of Assignments)
    *   `total_pending_assignments` (Int)
    *   `total_overdue_assignments` (Int)
    *   `recent_activities` (List of Activities)
    *   `course_progress` (List of Course Progress Percentages)
    *   `overall_progress_percentage` (Double)
    *   `current_gpa` (Double?)
    *   `today_classes` (List of Timetable Entries)
    *   `next_class` (Upcoming Class Map)

---

## 2. Mobile App Architecture & File Structure

The mobile application has been updated with the custom **VELS** theme, reusable navigation components, and modular dashboard widgets located under the requested file structure.

### Key Files Created & Modified

```
collge_management_system_mobile/
├── lib/
│   ├── core/
│   │   ├── academic_models.dart      # [NEW] Dart Models for parsing the Dashboard API payload
│   │   └── academic_service.dart     # [NEW] API Service to fetch student dashboard details
│   └── ui/
│       └── vels/
│           ├── theme/
│           │   └── vels_theme.dart   # [NEW] Custom theme config containing brand colors and visual styles
│           ├── widgets/
│           │   ├── vels_bottom_nav.dart # [NEW] Reusable Bottom Navigation Bar (Home, Schedule, Grades, Profile)
│           │   └── vels_header.dart     # [NEW] Reusable Common Header with profile avatar and logout/notification actions
│           └── screens/
│               ├── login_screen.dart # [MODIFIED] Uses VelsTheme and redirects to StudentDashboardScreen
│               └── student/
│                   └── dashboard/    # [NEW] Modular dashboard components
│                       ├── student_dashboard_screen.dart # Main screen controller coordinating tabs & api fetch
│                       ├── metrics_grid.dart             # Horizontal grid of KPIs (GPA, Progress, Pending, Overdue)
│                       ├── progress_card.dart            # Overall progress bar
│                       ├── next_class_card.dart          # Next upcoming class card with left accent bar
│                       └── today_classes_list.dart       # List of today's schedule entries
```

---

## 3. Running & Verifying the Setup

### Backend Verification
Verify the backend starts correctly and passes system checks:
```bash
# In College-Management-System-Backend root
python manage.py check
python manage.py runserver 8085
```
You can verify the security and API resolution rules by running the backend test script:
```bash
$env:PYTHONIOENCODING="utf-8"; python .gemini/antigravity/scratch/test_me_dashboard.py
```

### Mobile Verification
The mobile app compiles and connects to the backend using `ApiClient` which resolves `AppConstants.baseUrl` to target the active server.
Ensure that the assets (`assets/app_logos/vels_logo.png` and `assets/app_logos/vels_background.png`) are present.
The application theme, login form, navigation bar, and API-driven lists are fully integrated.
