import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/expense_list_screen.dart';
import '../screens/add_edit_expense_screen.dart';
import '../screens/expense_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/premium_screen.dart';
import '../screens/portfolio_screen.dart';
import '../screens/add_edit_holding_screen.dart';
import '../screens/holding_detail_screen.dart';
import '../widgets/main_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Shell route for bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(
          currentIndex: navigationShell.currentIndex,
          child: navigationShell,
        );
      },
      branches: [
        // Home branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Expenses branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/expenses',
              name: 'expenses',
              builder: (context, state) => const ExpenseListScreen(),
            ),
          ],
        ),
        // Portfolio branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/portfolio',
              name: 'portfolio',
              builder: (context, state) => const PortfolioScreen(),
            ),
          ],
        ),
      ],
    ),

    // Routes without bottom navigation (detail/edit screens)
    GoRoute(
      path: '/expenses/add',
      name: 'add-expense',
      builder: (context, state) => const AddEditExpenseScreen(),
    ),
    GoRoute(
      path: '/expenses/:id',
      name: 'expense-detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ExpenseDetailScreen(expenseId: id);
      },
    ),
    GoRoute(
      path: '/expenses/:id/edit',
      name: 'edit-expense',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AddEditExpenseScreen(expenseId: id);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/premium',
      name: 'premium',
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: '/portfolio/add',
      name: 'add-holding',
      builder: (context, state) => const AddEditHoldingScreen(),
    ),
    GoRoute(
      path: '/portfolio/:id',
      name: 'holding-detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return HoldingDetailScreen(holdingId: id);
      },
    ),
    GoRoute(
      path: '/portfolio/:id/edit',
      name: 'edit-holding',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AddEditHoldingScreen(holdingId: id);
      },
    ),
  ],
);
