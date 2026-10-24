import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/presentation/public_shell.dart';
import '../../features/requests/presentation/request_success_screen.dart';
import '../../features/dashboard/presentation/admin_shell.dart';
import '../../features/tracking/presentation/live_tracking_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isAdminRoute = state.matchedLocation.startsWith('/admin');

      // If user tries to access /admin while unauthenticated, redirect to /login
      if (isAdminRoute && !authState.isAuthenticated) {
        return '/login';
      }

      // If already logged in and at /login, forward to /admin
      if (isLoggingIn && authState.isAuthenticated) {
        return '/admin';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const PublicShell(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminShell(),
      ),
      GoRoute(
        path: '/request-success',
        name: 'request-success',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return RequestSuccessScreen(
            referenceId: extra['referenceId'] as String? ?? 'REQ-0000',
            patientName: extra['patientName'] as String? ?? 'Patient',
            bloodGroup: extra['bloodGroup'] as String? ?? 'O+',
            quantity: extra['quantity'] as int? ?? 1,
            hospital: extra['hospital'] as String? ?? 'Hospital',
          );
        },
      ),
      GoRoute(
        path: '/tracking',
        name: 'tracking',
        builder: (context, state) {
          final extra = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : <String, dynamic>{};
          final q = state.uri.queryParameters;

          final referenceId = extra['referenceId'] as String? ?? q['referenceId'] ?? 'REQ-SEED01';
          final patientName = extra['patientName'] as String? ?? q['patientName'] ?? 'Priya Menon';
          final hospital = extra['hospital'] as String? ?? q['hospital'] ?? 'Apollo Hospital';
          final bloodGroup = extra['bloodGroup'] as String? ?? q['bloodGroup'] ?? 'O+';
          final quantity = (extra['quantity'] is int)
              ? extra['quantity'] as int
              : int.tryParse(q['quantity'] ?? '') ?? 2;

          return LiveTrackingScreen(
            referenceId: referenceId,
            patientName: patientName,
            hospital: hospital,
            bloodGroup: bloodGroup,
            quantity: quantity,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
