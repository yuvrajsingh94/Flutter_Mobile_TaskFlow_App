import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/logo.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:taskflow_flutter/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:taskflow_flutter/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:taskflow_flutter/features/dashboard/presentation/screens/employee_dashboard_screen.dart';
import 'package:taskflow_flutter/features/employees/presentation/screens/employee_management_screen.dart';
import 'package:taskflow_flutter/features/leaves/presentation/screens/admin_leave_management_screen.dart';
import 'package:taskflow_flutter/features/leaves/presentation/screens/my_leaves_screen.dart';
import 'package:taskflow_flutter/features/profile/presentation/screens/profile_screen.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/admin_task_management_screen.dart';
import 'package:taskflow_flutter/core/navigation/navigator_service.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/my_tasks_screen.dart';
import 'package:taskflow_flutter/features/navigation/presentation/admin_more_screen.dart';

class RootNavigation extends ConsumerStatefulWidget {
  const RootNavigation({super.key});

  @override
  ConsumerState<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends ConsumerState<RootNavigation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;
  bool _hasBootstrapped = false;
  Widget? _cachedShell;

  final _adminShellKey = GlobalKey<_AdminShellState>();
  final _employeeShellKey = GlobalKey<_EmployeeShellState>();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        if (mounted) {
          setState(() {
            _cachedShell = null;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for authentication state transitions to trigger smooth horizontal animations
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        // LOGOUT (POP): Pop all pushed sub-routes and slide the authenticated shell out to the right (LEFT → RIGHT)
        popToRoot();
        _animController.reverse(from: 1.0);
      } else if (previous?.isAuthenticated == false && next.isAuthenticated) {
        // LOGIN (PUSH): Slide the authenticated shell in from the right (RIGHT → LEFT)
        _animController.forward(from: 0.0);
      }
    });

    final authState = ref.watch(authNotifierProvider);

    // Initial Splash / Token bootstrap check
    if (!authState.isInitialized) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBgPrimary : AppColors.canvas,
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Logo(size: 64),
              SizedBox(height: 24),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Set initial position once bootstrapped without animating cold launch
    if (!_hasBootstrapped) {
      _hasBootstrapped = true;
      _animController.value = authState.isAuthenticated ? 1.0 : 0.0;
    }

    // Determine current or cached authenticated shell
    Widget? activeShell;
    if (authState.isAuthenticated) {
      activeShell = authState.isAdmin
          ? AdminShell(key: _adminShellKey)
          : EmployeeShell(key: _employeeShellKey);
      _cachedShell = activeShell;
    } else if (_animController.isAnimating && _cachedShell != null) {
      activeShell = _cachedShell;
    }

    // If completely unauthenticated and animation finished, render just LoginScreen
    if (!authState.isAuthenticated && !_animController.isAnimating) {
      return const LoginScreen();
    }

    // During authenticated session or transitions, maintain the Stack:
    // Base layer: LoginScreen sitting underneath (only rendered during unauthenticated/animating states)
    // Top layer: Active shell sliding in from the right (PUSH) or out to the right (POP)
    return Stack(
      fit: StackFit.expand,
      children: [
        if (!authState.isAuthenticated || _animController.isAnimating)
          const LoginScreen(),
        if (activeShell != null)
          SlideTransition(
            key: const ValueKey('auth_shell_slide_transition'),
            position: _slideAnimation,
            child: IgnorePointer(
              ignoring: !authState.isAuthenticated,
              child: activeShell,
            ),
          ),
      ],
    );
  }
}

// ── Admin Shell ─────────────────────────────────────────────────────────────

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAuthenticated = ref.watch(authNotifierProvider).isAuthenticated;

    const screens = [
      AdminDashboardScreen(),
      AdminTaskManagementScreen(),
      EmployeeManagementScreen(),
      AdminLeaveManagementScreen(),
      AdminMoreScreen(),
    ];

    return Scaffold(
      body: PopScope(
        canPop: _currentIndex == 0 || !isAuthenticated,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          // Only switch back to Dashboard on Android Back if user is still authenticated
          if (!ref.read(authNotifierProvider).isAuthenticated) return;
          if (_currentIndex != 0) {
            setState(() => _currentIndex = 0);
          }
        },
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: isDark ? AppColors.darkBgCard : AppColors.lightTabBarBg,
        selectedItemColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTabBarActive,
        unselectedItemColor: isDark ? AppColors.darkTextDisabled : AppColors.lightTabBarInactive,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            activeIcon: Icon(Icons.check_box_rounded),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded),
            activeIcon: Icon(Icons.people_rounded),
            label: 'Employees',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            activeIcon: Icon(Icons.event_note_rounded),
            label: 'Leaves',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_outlined),
            activeIcon: Icon(Icons.more_horiz_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

// ── Employee Shell ──────────────────────────────────────────────────────────

class EmployeeShell extends ConsumerStatefulWidget {
  const EmployeeShell({super.key});

  @override
  ConsumerState<EmployeeShell> createState() => _EmployeeShellState();
}

class _EmployeeShellState extends ConsumerState<EmployeeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAuthenticated = ref.watch(authNotifierProvider).isAuthenticated;

    const screens = [
      EmployeeDashboardScreen(),
      MyTasksScreen(),
      CalendarScreen(),
      MyLeavesScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: PopScope(
        canPop: _currentIndex == 0 || !isAuthenticated,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          // Only switch back to Dashboard on Android Back if user is still authenticated
          if (!ref.read(authNotifierProvider).isAuthenticated) return;
          if (_currentIndex != 0) {
            setState(() => _currentIndex = 0);
          }
        },
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: isDark ? AppColors.darkBgCard : AppColors.lightTabBarBg,
        selectedItemColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTabBarActive,
        unselectedItemColor: isDark ? AppColors.darkTextDisabled : AppColors.lightTabBarInactive,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            activeIcon: Icon(Icons.check_box_rounded),
            label: 'My Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_takeoff_outlined),
            activeIcon: Icon(Icons.flight_takeoff_rounded),
            label: 'Leaves',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

