import 'package:examace/view/exams/subject_detail_screen.dart';
import 'package:examace/view/mocktest/mock_test_screen.dart';
import 'package:examace/view/profile/profile_screen.dart';
import 'package:examace/view/stats/state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/home_screen.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../view_model/nav_view_model.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navIndexProvider);

    // ✅ Order MUST match _items in AppBottomNavBar:
    //    index 0 = HOME, 1 = EXAMS, 2 = TEST, 3 = STATS, 4 = PROFILE
    const pages = <Widget>[
      HomeScreen(),
      ExamScreen(),
      MockTestSetupScreen(),
      StatsScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF131409),
      // No AppBar — every screen owns its own top bar
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}
