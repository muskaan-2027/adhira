import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/user_shell_layout.dart';
import 'chatbot_screen.dart';
import 'community_screen.dart';
import 'help_requests_screen.dart';
import 'need_guidance_screen.dart';
import 'profile_screen.dart';
import 'sos_screen.dart';
import 'volunteer_profiles_screen.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  void _replaceWith(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  List<UserNavItem> _navItems(BuildContext context) {
    return [
      UserNavItem(
        label: 'Dashboard',
        icon: Icons.home_outlined,
        section: UserNavSection.dashboard,
        onTap: () {},
      ),
      UserNavItem(
        label: 'Emergency SOS',
        icon: Icons.warning_amber_rounded,
        section: UserNavSection.sos,
        onTap: () => _replaceWith(context, const SOSScreen()),
      ),
      UserNavItem(
        label: 'Need Guidance',
        icon: Icons.support_agent_rounded,
        section: UserNavSection.needGuidance,
        onTap: () => _replaceWith(context, const NeedGuidanceScreen()),
      ),
      UserNavItem(
        label: 'Volunteer Profiles',
        icon: Icons.groups_2_outlined,
        section: UserNavSection.volunteers,
        onTap: () => _replaceWith(context, const VolunteerProfilesScreen()),
      ),
      UserNavItem(
        label: 'Community',
        icon: Icons.forum_outlined,
        section: UserNavSection.community,
        onTap: () => _replaceWith(context, const CommunityScreen()),
      ),
      UserNavItem(
        label: 'Chatbot Assistant',
        icon: Icons.chat_bubble_outline_rounded,
        section: UserNavSection.chatbot,
        onTap: () => _replaceWith(context, const ChatbotScreen()),
      ),
      UserNavItem(
        label: 'My Help Requests',
        icon: Icons.assignment_outlined,
        section: UserNavSection.helpRequests,
        onTap: () => _replaceWith(
          context,
          const HelpRequestsScreen(
            isVolunteer: false,
            title: 'My Help Requests',
          ),
        ),
      ),
    ];
  }

  void _showNotifications(BuildContext context) {
    NotificationService.showMessage(context, 'No new notifications right now');
  }

  void _openProfile(BuildContext context) {
    _replaceWith(context, const ProfileScreen());
  }

  Future<void> _logout(BuildContext context) {
    return context.read<AuthService>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final userName = user?.name ?? 'User';

    return UserShellLayout(
      selectedSection: UserNavSection.dashboard,
      title: 'Welcome back! 👋',
      subtitle: 'We are here to support you. Stay safe, stay strong.',
      userName: userName,
      accountRole: 'User',
      statusText: 'Stay Safe',
      supportHeadline: 'You are not alone.',
      supportMessage: 'Help is just a tap away.\nStay aware. Stay safe.',
      supportIcon: Icons.health_and_safety_rounded,
      onNotificationsTap: () => _showNotifications(context),
      onProfileTap: () => _openProfile(context),
      onLogout: () => _logout(context),
      navItems: _navItems(context),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1050 ? 3 : 2;
              final cardWidth =
                  (constraints.maxWidth - (columns - 1) * 16) / columns;
              final cardHeight = constraints.maxWidth >= 1050 ? 300.0 : 280.0;

              final cards = [
                _DashboardFeatureCard(
                  title: 'Emergency SOS',
                  subtitle:
                      'In an emergency? Send an alert to your trusted contacts instantly.',
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFDC284C),
                  iconBg: const Color(0xFFFFE8EE),
                  buttonLabel: 'Send SOS',
                  buttonBg: const Color(0xFFFFE9EE),
                  buttonColor: const Color(0xFFDC284C),
                  onTap: () => _replaceWith(context, const SOSScreen()),
                ),
                _DashboardFeatureCard(
                  title: 'Need Guidance',
                  subtitle:
                      'Get support and guidance from experts and trained professionals.',
                  icon: Icons.support_agent_rounded,
                  color: AppColors.primary,
                  iconBg: const Color(0xFFEDE7FF),
                  buttonLabel: 'Get Guidance',
                  buttonBg: const Color(0xFFF2EEFF),
                  buttonColor: AppColors.primary,
                  onTap: () =>
                      _replaceWith(context, const NeedGuidanceScreen()),
                ),
                _DashboardFeatureCard(
                  title: 'Volunteer Profiles',
                  subtitle:
                      'View verified volunteers who can help and assist you.',
                  icon: Icons.groups_2_rounded,
                  color: const Color(0xFF188A56),
                  iconBg: const Color(0xFFE8F7EF),
                  buttonLabel: 'View Volunteers',
                  buttonBg: const Color(0xFFEBF9F1),
                  buttonColor: const Color(0xFF188A56),
                  onTap: () =>
                      _replaceWith(context, const VolunteerProfilesScreen()),
                ),
                _DashboardFeatureCard(
                  title: 'Community',
                  subtitle:
                      'Join the community, share, support and empower each other.',
                  icon: Icons.forum_outlined,
                  color: const Color(0xFFEF7B1A),
                  iconBg: const Color(0xFFFFF2E8),
                  buttonLabel: 'Explore Community',
                  buttonBg: const Color(0xFFFFF3E9),
                  buttonColor: const Color(0xFFEF7B1A),
                  onTap: () => _replaceWith(context, const CommunityScreen()),
                ),
                _DashboardFeatureCard(
                  title: 'Chatbot Assistant',
                  subtitle:
                      'Chat with our AI assistant anytime for quick help and information.',
                  icon: Icons.smart_toy_outlined,
                  color: const Color(0xFF2166D8),
                  iconBg: const Color(0xFFEAF2FF),
                  buttonLabel: 'Chat Now',
                  buttonBg: const Color(0xFFEDF4FF),
                  buttonColor: const Color(0xFF2166D8),
                  onTap: () => _replaceWith(context, const ChatbotScreen()),
                ),
                _DashboardFeatureCard(
                  title: 'My Help Requests',
                  subtitle:
                      'Track your help requests and check the status in real-time.',
                  icon: Icons.assignment_outlined,
                  color: AppColors.primary,
                  iconBg: const Color(0xFFEDE7FF),
                  buttonLabel: 'View Requests',
                  buttonBg: const Color(0xFFF2EEFF),
                  buttonColor: AppColors.primary,
                  onTap: () => _replaceWith(
                    context,
                    const HelpRequestsScreen(
                      isVolunteer: false,
                      title: 'My Help Requests',
                    ),
                  ),
                ),
              ];

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: cards
                    .map(
                      (card) => SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: card,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFFF2EBFF), Color(0xFFEDE7FF)],
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, color: AppColors.primary, size: 42),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your safety is our priority.',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Report, connect and get help - because every woman matters.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.favorite_rounded,
                    color: AppColors.primary, size: 44),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color iconBg;
  final String buttonLabel;
  final Color buttonBg;
  final Color buttonColor;
  final VoidCallback onTap;

  const _DashboardFeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.iconBg,
    required this.buttonLabel,
    required this.buttonBg,
    required this.buttonColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 34),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: buttonColor,
              side: BorderSide(color: buttonColor.withValues(alpha: 0.35)),
              backgroundColor: buttonBg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onPressed: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  buttonLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
