import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import 'dashboard_screen.dart';
import '../../requests/presentation/admin_requests_screen.dart';
import '../../donors/presentation/admin_donors_screen.dart';
import '../../inventory/presentation/admin_inventory_screen.dart';

/// Admin portal shell with bottom navigation (Dashboard, Requests, Donors, Inventory) and Logout.
class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text('Are you sure you want to end your administrative session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                context.go('/');
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for automatic 401 session expiration
    ref.listen(sessionExpiredProvider, (previous, expired) {
      if (expired) {
        ref.read(sessionExpiredProvider.notifier).reset();
        ref.read(authProvider.notifier).forceLogout();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired after 8 hours. Please log in again.'),
            backgroundColor: AppColors.critical,
          ),
        );
        context.go('/login');
      }
    });

    final screens = const [
      DashboardScreen(),
      AdminRequestsScreen(),
      AdminDonorsScreen(),
      AdminInventoryScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Log Out',
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.emergency_outlined),
            selectedIcon: Icon(Icons.emergency_rounded, color: AppColors.primary),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded, color: AppColors.primary),
            label: 'Donors',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded, color: AppColors.primary),
            label: 'Inventory',
          ),
        ],
      ),
    );
  }
}
