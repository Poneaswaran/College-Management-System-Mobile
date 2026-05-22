# Context: Student Navigation & More Tab Implementation (VELS Flavor)

This document details the visual redesign and navigation structural updates implemented for the **VELS (VISTAS)** flavor in the student mobile application workspace.

---

## 1. Updated Navigation Structure
The student bottom navigation bar was modified to replace the previous "Profile" tab with a feature-rich "More" tab, while keeping the "Attendance" tab intact (5 tabs total):

1. **Dashboard** (formerly Home - Index 0)
   - Updated label to `Dashboard`.
   - Updated icon to `Icons.grid_view_outlined` and active icon to `Icons.grid_view`.
2. **Schedule** (Index 1)
   - Kept calendar/timetable schedule page.
3. **Attendance** (Index 2)
   - Retained the primary Attendance tab.
4. **Results** (formerly Grades - Index 3)
   - Updated label to `Results`.
   - Updated icon to `Icons.school_outlined` / `Icons.school` (graduation cap).
5. **More** (Index 4)
   - Brand new tab implementing the menu grid of features.
   - Icon: `Icons.menu` (active inside the premium selection pill).

---

## 2. File and Component Structure

The following new widgets and screens were added under the VELS student folder, using a clean, reusable architecture:

```
collge_management_system_mobile/
└── lib/
    └── ui/
        └── vels/
            ├── widgets/
            │   ├── vels_bottom_nav.dart   # [MODIFIED] Re-mapped tabs to 5-position layout (More replacing Profile)
            │   └── more_feature_card.dart # [NEW] Reusable premium feature card with tinted icon containers
            └── screens/
                └── student/
                    ├── agent.md           # [NEW] This integration documentation file
                    ├── student_more_screen.dart # [NEW] Main dashboard More screen controller
                    ├── student_profile_details_screen.dart # [NEW] Dedicated screen showing detailed registry details
                    └── dashboard/
                        └── student_dashboard_screen.dart # [MODIFIED] Mapped tab routing and index-4 display to StudentMoreScreen
```

---

## 3. Detailed Component Implementation

### 1. `MoreFeatureCard` (`lib/ui/vels/widgets/more_feature_card.dart`)
- **Purpose**: Displays a grid item for student services.
- **Design Elements**:
  - Rounded white container with standard grey border (`VelsTheme.borderLight`).
  - Top-left icon wrapped inside a custom tinted container matching the icon's color at `10%` opacity.
  - Bold title text and muted description/action text.
  - Ripple tap highlights (`InkWell`) with rounded clips.

### 2. `StudentMoreScreen` (`lib/ui/vels/screens/student/student_more_screen.dart`)
- **Purpose**: Coordinates all features and dashboard overview tools.
- **Sections**:
  - **Centered Header**: Shows "More" title and "All Features" subtitle in white app bar.
  - **Tappable Profile Card**: Renders initials avatar, full name, registration number, and department. Tapping navigates to `StudentProfileDetailsScreen`.
  - **Metrics pills row**: Displays GPA (`currentGpa`), semester progress (`overallProgressPercentage`), and pending assignments (`totalPendingAssignments`) inside styled color pills.
  - **Grid of feature cards**: 2x4 layout containing navigation blocks:
    - *Attendance*: Navigates to `AttendanceScreen()`.
    - *Fees*, *Library*, *Exam Schedule*, *Announcements*, *Achievements*, *Bus Pass*, *Complaints*: Tapping triggers floating snackbars indicating that the feature is under active development.
  - **Account Settings list**: Box container styling settings shortcuts (Settings, Notifications, Privacy & Security, Help & Support).
  - **Logout button**: Red text and logout icon inside a light pink container (`Color(0xFFFEF2F2)`), which triggers auth sign-out and redirects back to `LoginScreen()`.
  - **Centered Footer**: Renders version number and Powered by VELS University info.

### 3. `StudentProfileDetailsScreen` (`lib/ui/vels/screens/student/student_profile_details_screen.dart`)
- **Purpose**: Sub-screen showing full account information when the profile card is clicked.
- **Design Elements**:
  - Large initials circle avatar.
  - Full Name & Register Number headers.
  - Detailed lists for email, system role, department, institution (VISTAS), and enrollment status.
