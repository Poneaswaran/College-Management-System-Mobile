import 'package:flutter/material.dart';
import '../theme/vels_theme.dart';
import '../../../../core/auth_service.dart';
import '../screens/login_screen.dart';

class VelsHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? profilePhotoUrl;
  final IconData? avatarIcon;
  final bool showNotification;
  final bool showLogout;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onLogoutPressed;

  const VelsHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.profilePhotoUrl,
    this.avatarIcon,
    this.showNotification = false,
    this.showLogout = false,
    this.onNotificationPressed,
    this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Generate initials for avatar fallback if no photo URL or icon is provided
    String initials = '';
    if (title.isNotEmpty && avatarIcon == null && profilePhotoUrl == null) {
      // Clean greeting prefixes for initials if present
      String cleanTitle = title;
      if (title.startsWith('Good Morning, ')) {
        cleanTitle = title.replaceFirst('Good Morning, ', '');
      } else if (title.startsWith('Welcome, Prof. ')) {
        cleanTitle = title.replaceFirst('Welcome, Prof. ', '');
      } else if (title.startsWith('Admin: ')) {
        cleanTitle = title.replaceFirst('Admin: ', '');
      }
      
      final parts = cleanTitle.trim().split(' ');
      if (parts.isNotEmpty) {
        initials = parts[0][0].toUpperCase();
        if (parts.length > 1 && parts[1].isNotEmpty) {
          initials += parts[1][0].toUpperCase();
        }
      }
    }
    if (initials.isEmpty) initials = 'U';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: VelsTheme.primaryBlue, // VELS Premium Dark Blue
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 24),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // User Avatar Container
            Container(
              padding: const EdgeInsets.all(2.0),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: VelsTheme.secondaryBlue,
                backgroundImage: profilePhotoUrl != null ? NetworkImage(profilePhotoUrl!) : null,
                child: profilePhotoUrl == null
                    ? (avatarIcon != null
                        ? Icon(avatarIcon, color: Colors.white, size: 24)
                        : Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ))
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            // Header Titles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Actions
            if (showNotification)
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white, size: 26),
                    onPressed: onNotificationPressed ?? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications are under development')),
                      );
                    },
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: VelsTheme.overdueRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            if (showLogout)
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 24),
                onPressed: onLogoutPressed ?? () async {
                  await AuthService.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
