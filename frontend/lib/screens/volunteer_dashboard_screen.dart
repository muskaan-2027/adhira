import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/user_shell_layout.dart';
import 'chatbot_screen.dart';
import 'community_screen.dart';
import 'help_requests_screen.dart';
import 'profile_screen.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  State<VolunteerDashboardScreen> createState() =>
      _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  Future<void> _updateAvailability(bool active) async {
    try {
      await context
          .read<AuthService>()
          .updateVolunteerAvailability(active ? 'active' : 'inactive');
    } catch (err) {
      if (!mounted) return;
      NotificationService.showMessage(
        context,
        err.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void _replaceWith(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _showAvailabilityDialog(BuildContext context, bool isActive) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Availability'),
        content: Text(
            isActive ? 'Mark yourself inactive?' : 'Mark yourself active?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateAvailability(!isActive);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  List<UserNavItem> _navItems(BuildContext context, bool isActive) {
    return [
      UserNavItem(
        label: 'Dashboard',
        icon: Icons.home_outlined,
        section: UserNavSection.dashboard,
        onTap: () {},
      ),
      UserNavItem(
        label: 'Requests',
        icon: Icons.grid_view_rounded,
        section: UserNavSection.requests,
        onTap: () => _replaceWith(
          context,
          const HelpRequestsScreen(
            isVolunteer: true,
            statusFilter: 'pending',
            title: 'Pending Help Requests',
          ),
        ),
      ),
      UserNavItem(
        label: 'My Assignments',
        icon: Icons.playlist_add_check_rounded,
        section: UserNavSection.assignments,
        onTap: () => _replaceWith(
          context,
          const HelpRequestsScreen(
            isVolunteer: true,
            statusFilter: 'accepted',
            title: 'Assigned Requests',
          ),
        ),
      ),
      UserNavItem(
        label: 'Completed Work',
        icon: Icons.task_alt_rounded,
        section: UserNavSection.completedWork,
        onTap: () => _replaceWith(
          context,
          const HelpRequestsScreen(
            isVolunteer: true,
            statusFilter: 'completed',
            title: 'Completed Assistance',
          ),
        ),
      ),
      UserNavItem(
        label: 'Availability',
        icon: Icons.calendar_month_outlined,
        section: UserNavSection.availability,
        onTap: () => _showAvailabilityDialog(context, isActive),
      ),
      UserNavItem(
        label: 'Community',
        icon: Icons.group_outlined,
        section: UserNavSection.community,
        onTap: () => _replaceWith(context, const CommunityScreen()),
      ),
      UserNavItem(
        label: 'Chat Assistant',
        icon: Icons.smart_toy_outlined,
        section: UserNavSection.chatbot,
        onTap: () => _replaceWith(context, const ChatbotScreen()),
      ),
      UserNavItem(
        label: 'Profile',
        icon: Icons.person_outline_rounded,
        section: UserNavSection.profile,
        onTap: () => _replaceWith(context, const ProfileScreen()),
      ),
      UserNavItem(
        label: 'Settings',
        icon: Icons.settings_outlined,
        section: UserNavSection.settings,
        onTap: () => _showAvailabilityDialog(context, isActive),
      ),
    ];
  }

  void _showNotifications() {
    NotificationService.showMessage(context, 'No new notifications right now');
  }

  void _openProfile() {
    _replaceWith(context, const ProfileScreen());
  }

  Future<void> _logout() {
    return context.read<AuthService>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'vol';
    final isActive = user?.volunteerAvailability == 'active';
    final profileCompletion = _profileCompletion(user);

    return UserShellLayout(
      selectedSection: UserNavSection.dashboard,
      title: 'Welcome back, $userName! 👋',
      subtitle: 'Your dedication brings safety, support and hope to many.',
      userName: userName,
      accountRole: userName,
      statusText: 'Volunteer',
      supportHeadline: 'You Make a Difference',
      supportMessage: 'Every action counts towards\na safer society.',
      supportIcon: Icons.groups_rounded,
      onNotificationsTap: _showNotifications,
      onProfileTap: _openProfile,
      onLogout: _logout,
      navItems: _navItems(context, isActive),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;
              final profileCard = _profileSummaryCard(
                context: context,
                userName: userName,
                profileCompletion: profileCompletion,
                isActive: isActive,
              );
              final quickActions = _quickActionsCard(context);
              if (!wide) {
                return Column(
                  children: [
                    profileCard,
                    const SizedBox(height: 14),
                    quickActions,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: profileCard),
                  const SizedBox(width: 14),
                  Expanded(child: quickActions),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          _statsRow(),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;
              final left = Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _skillsCard(),
                    const SizedBox(height: 14),
                    _experienceCard(),
                  ],
                ),
              );
              final right = Expanded(child: _recentActivityCard());

              if (!wide) {
                return Column(
                  children: [
                    _skillsCard(),
                    const SizedBox(height: 14),
                    _experienceCard(),
                    const SizedBox(height: 14),
                    _recentActivityCard(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  left,
                  const SizedBox(width: 14),
                  right,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  int _profileCompletion(AppUser? user) {
    var score = 40;
    if (user == null) return score;
    if (user.name.trim().isNotEmpty) score += 20;
    if (user.voterIdVerified) score += 20;
    if (user.onboardingCompleted) score += 20;
    return score.clamp(0, 100);
  }

  Widget _profileSummaryCard({
    required BuildContext context,
    required String userName,
    required int profileCompletion,
    required bool isActive,
  }) {
    final progress = profileCompletion / 100;
    final identityCard = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFFEDE7FF),
              child: Text(
                userName.isEmpty ? 'V' : userName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  const Text(
                    'Volunteer',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text('VOL123456'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _statusChip(
              'Verified',
              const Color(0xFF188A56),
              const Color(0xFFEAF8F0),
            ),
            _statusChip(
              isActive ? 'Active' : 'Inactive',
              isActive ? const Color(0xFF188A56) : const Color(0xFFDC284C),
              isActive ? const Color(0xFFEAF8F0) : const Color(0xFFFFE9EE),
            ),
          ],
        ),
      ],
    );

    final completionCard = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Profile Completion'),
            Text(
              '$profileCompletion%',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Complete your profile to receive more opportunities.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _replaceWith(context, const ProfileScreen()),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Update Profile'),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 860;
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                identityCard,
                const SizedBox(height: 16),
                completionCard,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: identityCard),
              const SizedBox(width: 16),
              SizedBox(width: 320, child: completionCard),
            ],
          );
        },
      ),
    );
  }

  Widget _statusChip(String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 9, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
          ),
          const SizedBox(height: 10),
          _quickActionTile(
            title: 'Accept / Reject Requests',
            icon: Icons.fact_check_outlined,
            onTap: () => _replaceWith(
              context,
              const HelpRequestsScreen(
                isVolunteer: true,
                statusFilter: 'pending',
                title: 'Pending Help Requests',
              ),
            ),
          ),
          _quickActionTile(
            title: 'Provide Assistance',
            icon: Icons.volunteer_activism_outlined,
            onTap: () => _replaceWith(
              context,
              const HelpRequestsScreen(
                isVolunteer: true,
                statusFilter: 'accepted',
                title: 'Accepted Requests',
              ),
            ),
          ),
          _quickActionTile(
            title: 'Completed Work',
            icon: Icons.task_alt_rounded,
            onTap: () => _replaceWith(
              context,
              const HelpRequestsScreen(
                isVolunteer: true,
                statusFilter: 'completed',
                title: 'Completed Assistance',
              ),
            ),
          ),
          _quickActionTile(
            title: 'Community Section',
            icon: Icons.group_outlined,
            onTap: () => _replaceWith(context, const CommunityScreen()),
          ),
          _quickActionTile(
            title: 'Chatbot Assistant',
            icon: Icons.smart_toy_outlined,
            onTap: () => _replaceWith(context, const ChatbotScreen()),
          ),
        ],
      ),
    );
  }

  Widget _quickActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: const Color(0xFFFCFCFF),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(child: Text(title)),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statsRow() {
    final items = <({
      String title,
      String value,
      String subtitle,
      IconData icon,
      Color color,
    })>[
      (
        title: 'Total Hours',
        value: '48',
        subtitle: 'Hours Contributed',
        icon: Icons.access_time_rounded,
        color: const Color(0xFF5B34E6),
      ),
      (
        title: 'Rating',
        value: '4.8',
        subtitle: '★★★★★',
        icon: Icons.star_border_rounded,
        color: const Color(0xFF188A56),
      ),
      (
        title: 'Requests Completed',
        value: '18',
        subtitle: 'This Month',
        icon: Icons.shield_outlined,
        color: const Color(0xFF2166D8),
      ),
      (
        title: 'Community Impact',
        value: '56',
        subtitle: 'People Helped',
        icon: Icons.groups_2_outlined,
        color: const Color(0xFFEF7B1A),
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => Container(
              width: 180,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, color: item.color),
                  const SizedBox(height: 8),
                  Text(item.title,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  Text(
                    item.value,
                    style: const TextStyle(
                        fontSize: 34, fontWeight: FontWeight.w700),
                  ),
                  Text(item.subtitle,
                      style: const TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _skillsCard() {
    const skills = ['Communication', 'First Aid', 'Counselling', 'Teamwork'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.grid_view_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Skills',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Manage Skills',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: skills
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2EEFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _experienceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 92,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EEFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text(
                  '2+',
                  style: TextStyle(
                    fontSize: 30,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text('Years'),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Dedicated volunteer with experience in women safety awareness and community support.',
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentActivityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 12),
          _ActivityItem(
            title: 'Completed a request',
            subtitle: 'Helped in awareness program',
            time: '2h ago',
          ),
          Divider(height: 20),
          _ActivityItem(
            title: 'New message received',
            subtitle: 'From Neha Sharma',
            time: '5h ago',
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFF2EEFF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Text(time, style: const TextStyle(color: AppColors.textMuted)),
      ],
    );
  }
}
