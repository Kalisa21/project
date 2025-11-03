import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import 'admin_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Get user info from Supabase
    final user = SupabaseService.currentUser;
    final bool loggedIn = SupabaseService.isAuthenticated;
    final name = user?.userMetadata?['name']?.toString() ?? 
                 user?.email?.split('@')[0] ?? 
                 'User';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
          child: loggedIn
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: Text(
                            name[0],
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'sign in as admin',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminScreen(),
                            ),
                          );
                        },
                        child: const AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'sign in',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ..._buildListTileOptions(context),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        await SupabaseService.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/signin');
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'SIGN OUT',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/signin'),
                    child: const Text('LOG IN OR SIGN UP'),
                  ),
                ),
        ),
      ),
    );
  }

  List<Widget> _buildListTileOptions(BuildContext context) {
    final items = [
      {
        'title': 'Privacy and safety',
        'body':
            'Manage your data, security, and visibility settings for a safer experience.',
      },
      {
        'title': 'Permissions',
        'body':
            'Control app permissions such as notifications, camera, and storage.',
      },
      {
        'title': 'Invite friends',
        'body':
            'Share the app with friends and colleagues to collaborate and learn together.',
      },
      {
        'title': 'Rate us',
        'body':
            'Tell us what you think. Your feedback helps improve the experience.',
      },
      {
        'title': 'Manage profile',
        'body':
            'Update your personal info, change password, and customize preferences.',
      },
    ];

    final theme = Theme.of(context).copyWith(
      dividerColor: Colors.transparent,
      splashColor: Colors.white12,
      highlightColor: Colors.white10,
    );

    return items
        .map(
          (e) => Theme(
            data: theme,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                collapsedIconColor: Colors.white70,
                iconColor: Colors.white70,
                textColor: Colors.white,
                collapsedTextColor: Colors.white70,
                title: Text(
                  e['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                children: [
                  Text(
                    e['body'] as String,
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }
}
