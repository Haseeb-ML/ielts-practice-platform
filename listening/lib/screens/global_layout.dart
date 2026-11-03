import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'dashboard_screen.dart';
import 'practice_tests_screen.dart';

class GlobalLayout extends StatefulWidget {
  const GlobalLayout({super.key});

  @override
  State<GlobalLayout> createState() => _GlobalLayoutState();
}

class _GlobalLayoutState extends State<GlobalLayout> {
  bool isSidebarCollapsed = false;
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const PracticeTestsScreen(moduleType: 'listening', title: 'Listening Practice'),
    const PracticeTestsScreen(moduleType: 'reading', title: 'Reading Practice'),
    const PracticeTestsScreen(moduleType: 'writing', title: 'Writing Practice'),
    const Center(child: Text("Saved Tests")), // Placeholder
    const Center(child: Text("Analytics")), // Placeholder
    const Center(child: Text("Settings")), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSidebarCollapsed ? 72 : 240,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                right: BorderSide(color: AppColors.border),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Row(
                    children: [
                      const Icon(Icons.headphones, color: AppColors.primaryNavy),
                      if (!isSidebarCollapsed) ...[
                        const SizedBox(width: AppSpacing.s8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "IELTS Master",
                                style: Theme.of(context).textTheme.titleLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "All-in-One Practice",
                                style: Theme.of(context).textTheme.labelSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                    children: [
                      _buildNavItem(Icons.dashboard_outlined, "Dashboard", 0),
                      _buildNavItem(Icons.headset_outlined, "Listening Test", 1),
                      _buildNavItem(Icons.menu_book_outlined, "Reading Practice", 2),
                      _buildNavItem(Icons.edit_note_outlined, "Writing Practice", 3),
                      _buildNavItem(Icons.bookmark_outline, "Saved Tests", 4),
                      _buildNavItem(Icons.analytics_outlined, "Analytics", 5),
                      _buildNavItem(Icons.settings_outlined, "Settings", 6),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primaryNavy,
                        radius: 16,
                        child: Text("S", style: TextStyle(color: AppColors.surface)),
                      ),
                      if (!isSidebarCollapsed) ...[
                        const SizedBox(width: AppSpacing.s8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Student", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Text("IELTS Practice", style: Theme.of(context).textTheme.labelSmall),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(isSidebarCollapsed ? Icons.chevron_right : Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      isSidebarCollapsed = !isSidebarCollapsed;
                    });
                  },
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    return Container(
      color: isActive ? AppColors.accentLight.withOpacity(0.5) : Colors.transparent,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: isActive ? AppColors.accentTeal : AppColors.secondaryText),
          title: isSidebarCollapsed
              ? null
              : Text(
                  label,
                  style: TextStyle(
                    color: isActive ? AppColors.accentTeal : AppColors.primaryText,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
