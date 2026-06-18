// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:examace/view_model/nav_view_model.dart';

class AppBottomNavBar extends ConsumerWidget {
  const AppBottomNavBar({super.key});

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, label: 'HOME'),
    _NavItem(icon: Icons.menu_book_rounded, label: 'EXAMS'),
    _NavItem(icon: Icons.quiz_rounded, label: 'TEST'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'STATS'),
    _NavItem(icon: Icons.person_rounded, label: 'PROFILE'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(navIndexProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              height: 78 + bottomPadding,
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: bottomPadding > 0 ? bottomPadding : 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1B12).withOpacity(0.82),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0x33D8EE36)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(_items.length, (index) {
                  final item = _items[index];
                  final active = index == selected;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (selected == index) {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                          return;
                        }
                        // ✅ Only update state — MainScreen's IndexedStack
                        //    switches the page, no Navigator needed
                        ref.read(navIndexProvider.notifier).setTab(index);
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: active
                              ? LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFFD8EE36).withOpacity(0.22),
                                    const Color(0xFF5822B8).withOpacity(0.12),
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(18),
                          border: active
                              ? Border.all(color: const Color(0x55D8EE36))
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: active ? 1.15 : 1,
                              duration: const Duration(milliseconds: 250),
                              child: Icon(
                                item.icon,
                                size: 21,
                                color: active
                                    ? const Color(0xFFD8EE36)
                                    : const Color(0xFFC7C8AE).withOpacity(0.72),
                              ),
                            ),
                            const SizedBox(height: 5),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(
                                fontSize: active ? 10 : 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: active
                                    ? const Color(0xFFD8EE36)
                                    : const Color(0xFFC7C8AE).withOpacity(0.7),
                              ),
                              child: Text(item.label),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
