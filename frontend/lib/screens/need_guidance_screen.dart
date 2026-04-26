import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/user_shell_layout.dart';
import 'chatbot_screen.dart';
import 'community_screen.dart';
import 'help_requests_screen.dart';
import 'profile_screen.dart';
import 'sos_screen.dart';
import 'user_dashboard_screen.dart';
import 'volunteer_profiles_screen.dart';

class NeedGuidanceScreen extends StatelessWidget {
  const NeedGuidanceScreen({super.key});

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
        onTap: () => _replaceWith(context, const UserDashboardScreen()),
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
        onTap: () {},
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

  Future<void> _requestVolunteerHelp(BuildContext context) async {
    final controller = TextEditingController();

    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Volunteer Help'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Describe what support you need',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );

    if (message == null || message.isEmpty) return;
    if (!context.mounted) return;

    try {
      final token = context.read<AuthService>().token;
      if (token == null) throw Exception('Please login again');
      await ApiService.createHelpRequest(token, message: message);
      if (!context.mounted) return;
      NotificationService.showMessage(
          context, 'Help request sent to volunteers');
    } catch (err) {
      if (!context.mounted) return;
      NotificationService.showMessage(
        context,
        err.toString().replaceFirst('Exception: ', ''),
      );
    }
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
    final userName = context.watch<AuthService>().currentUser?.name ?? 'User';
    return UserShellLayout(
      selectedSection: UserNavSection.needGuidance,
      title: 'Need Guidance',
      subtitle: 'Choose a support type to get the help and guidance you need.',
      userName: userName,
      onNotificationsTap: () => _showNotifications(context),
      onProfileTap: () => _openProfile(context),
      onLogout: () => _logout(context),
      navItems: _navItems(context),
      child: Column(
        children: [
          ShellActionCard(
            title: 'Open Chatbot',
            subtitle:
                'Chat with our AI assistant for quick help and information.',
            icon: Icons.support_agent_rounded,
            iconColor: const Color(0xFF5B34E6),
            iconBackground: const Color(0xFFEDE7FF),
            onTap: () => _replaceWith(context, const ChatbotScreen()),
          ),
          ShellActionCard(
            title: 'Request Volunteer Help',
            subtitle: 'Request help from nearby verified volunteers.',
            icon: Icons.volunteer_activism_rounded,
            iconColor: const Color(0xFFD9468B),
            iconBackground: const Color(0xFFFFEEF5),
            onTap: () => _requestVolunteerHelp(context),
          ),
          ShellActionCard(
            title: 'View Volunteer Profiles',
            subtitle: 'Browse verified volunteers who can assist you.',
            icon: Icons.groups_2_rounded,
            iconColor: const Color(0xFF169C63),
            iconBackground: const Color(0xFFE9F9F1),
            onTap: () => _replaceWith(context, const VolunteerProfilesScreen()),
          ),
          ShellActionCard(
            title: 'View My Help Requests',
            subtitle: 'Track the status of your help requests.',
            icon: Icons.assignment_outlined,
            iconColor: const Color(0xFF5B34E6),
            iconBackground: const Color(0xFFEDE7FF),
            onTap: () => _replaceWith(
              context,
              const HelpRequestsScreen(
                isVolunteer: false,
                title: 'My Help Requests',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
