// lib/view/profile/profile_screen.dart

// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:ui';
import 'package:examace/const/app_responsive.dart';
import 'package:examace/model/model.dart';
import 'package:examace/view_model/auth_view_model.dart';
import 'package:examace/view_model/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../const/const.dart';

// ─────────────────────────────────────────────
//  PROFILE VIEW MODEL  (stats only — user data comes from currentUserProvider)
// ─────────────────────────────────────────────
class ProfileState {
  final int testsTaken;
  final int streakDays;
  final int bestScore;
  final int totalSolved;
  final bool isDark;

  const ProfileState({
    this.testsTaken = 42,
    this.streakDays = 7,
    this.bestScore = 91,
    this.totalSolved = 2340,
    this.isDark = true,
  });

  ProfileState copyWith({
    int? testsTaken,
    int? streakDays,
    int? bestScore,
    int? totalSolved,
    bool? isDark,
  }) => ProfileState(
    testsTaken: testsTaken ?? this.testsTaken,
    streakDays: streakDays ?? this.streakDays,
    bestScore: bestScore ?? this.bestScore,
    totalSolved: totalSolved ?? this.totalSolved,
    isDark: isDark ?? this.isDark,
  );
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());
  void toggleTheme() => state = state.copyWith(isDark: !state.isDark);
}

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = AppResponsive(context);
    final profile = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    // ── Real user from Firestore ──────────────
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFF131409),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(
            top: -r.h100,
            left: -r.w100,
            child: _GlowBlob(color: const Color(0xFFD8EE36), size: r.wp(80)),
          ),
          Positioned(
            bottom: -r.h100,
            right: -r.w100,
            child: _GlowBlob(color: const Color(0xFF5822B8), size: r.wp(70)),
          ),
          Column(
            children: [
              _TopBar(r: r, user: user),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(r.sp20, r.h20, r.sp20, r.h100),
                  child: Column(
                    children: [
                      _ProfileHero(r: r, profile: profile, user: user),
                      SizedBox(height: r.h20),
                      _StatsBentoGrid(r: r, profile: profile),
                      SizedBox(height: r.h20),
                      _ProfileMenu(
                        r: r,
                        isDark: profile.isDark,
                        onToggleTheme: notifier.toggleTheme,
                        onLogout: () => _handleLogout(context, ref),
                        onDeleteAccount: () =>
                            _handleDeleteAccount(context, ref),
                      ),
                      SizedBox(height: r.h20),
                      _AiInsightCard(r: r),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => _LogoutDialog(
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
    );
    if (confirm == true && context.mounted) {
      await ref.read(authViewModelProvider.notifier).signOut();
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1F2015),
        title: const Text(
          'Delete account?',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently deletes your profile, progress, notifications, and account. Enter your password to confirm.',
              style: TextStyle(color: Color(0xFFC7C8AE)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Color(0xFFC7C8AE)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = passwordController.text;
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: const Text(
              'Delete permanently',
              style: TextStyle(color: Color(0xFFFFB4AB)),
            ),
          ),
        ],
      ),
    );
    passwordController.dispose();

    if (password == null || !context.mounted) return;
    final deleted = await ref
        .read(authViewModelProvider.notifier)
        .deleteAccount(password);
    if (!context.mounted) return;

    if (deleted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
      return;
    }

    final message = ref.read(authViewModelProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'Could not delete account')),
    );
  }
}

// ─────────────────────────────────────────────
//  TOP BAR
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final AppResponsive r;
  final UserModel? user;
  const _TopBar({required this.r, required this.user});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final initials = user?.initials ?? '?';

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(r.sp20, top + r.sp12, r.sp20, r.sp12),
          decoration: BoxDecoration(
            color: const Color(0xFF131409).withOpacity(0.80),
            border: const Border(bottom: BorderSide(color: Color(0x4D464834))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ExamAce',
                style: TextStyle(
                  fontSize: r.fs22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD8EE36),
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: r.w40,
                    height: r.w40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(
                        color: const Color(0xFF464834).withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: r.w10),
                  // Avatar with real initials
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD8EE36),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191E00),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PROFILE HERO
// ─────────────────────────────────────────────
class _ProfileHero extends StatelessWidget {
  final AppResponsive r;
  final ProfileState profile;
  final UserModel? user;
  const _ProfileHero({
    required this.r,
    required this.profile,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final initials = user?.initials ?? '?';

    // Prefer fullName (set during onboarding) → fall back to displayName (from auth)
    final displayName = (user?.fullName.isNotEmpty == true)
        ? user!.fullName
        : (user?.displayName ?? '—');

    // Show selected exam as target label
    final targetLabel = (user?.selectedExam.isNotEmpty == true)
        ? 'Target: ${user!.selectedExam}'
        : 'Target: —';

    return Column(
      children: [
        SizedBox(height: r.h10),

        // Avatar
        Stack(
          children: [
            Container(
              width: r.w50 * 1.92,
              height: r.w50 * 1.92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD8EE36),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD8EE36).withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: r.fs36,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF191E00),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1F2015),
                  border: Border.all(color: const Color(0xFF464834), width: 2),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 14,
                  color: Color(0xFFD8EE36),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: r.h20 * 0.8),

        // Real name
        Text(
          displayName,
          style: TextStyle(
            fontSize: r.fs24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: r.h10 * 0.4),

        // Real exam target
        Text(
          targetLabel,
          style: TextStyle(
            fontSize: r.fs12,
            letterSpacing: 1,
            color: const Color(0xFFC7C8AE),
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: r.h10),

        // Badges
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Badge(
              label: 'PRO MEMBER',
              bgColor: const Color(0xFF5822B8).withOpacity(0.2),
              borderColor: const Color(0xFF5822B8).withOpacity(0.5),
              textColor: const Color(0xFFD1BCFF),
              r: r,
            ),
            SizedBox(width: r.w10 * 0.8),
            _Badge(
              label: 'TOP 5%',
              bgColor: const Color(0xFFD8EE36).withOpacity(0.1),
              borderColor: const Color(0xFFD8EE36).withOpacity(0.3),
              textColor: const Color(0xFFD8EE36),
              r: r,
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  BADGE  (top-level — must NOT be inside _ProfileHero)
// ─────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final AppResponsive r;

  const _Badge({
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.sp12, vertical: r.sp4),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: r.fs10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: textColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STATS BENTO GRID
// ─────────────────────────────────────────────
class _StatsBentoGrid extends StatelessWidget {
  final AppResponsive r;
  final ProfileState profile;
  const _StatsBentoGrid({required this.r, required this.profile});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem(
        label: 'TESTS TAKEN',
        value: '${profile.testsTaken}',
        icon: Icons.auto_graph_rounded,
      ),
      _StatItem(
        label: 'STREAK',
        value: '${profile.streakDays}',
        suffix: 'days',
        icon: Icons.local_fire_department_rounded,
        iconColor: const Color(0xFFFFA726),
      ),
      _StatItem(
        label: 'BEST SCORE',
        value: '${profile.bestScore}%',
        icon: Icons.verified_rounded,
      ),
      _StatItem(
        label: 'SOLVED',
        value: _formatNumber(profile.totalSolved),
        icon: Icons.task_alt_rounded,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (_, i) => _StatCard(r: r, item: stats[i]),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
    }
    return '$n';
  }
}

class _StatItem {
  final String label;
  final String value;
  final String? suffix;
  final IconData icon;
  final Color iconColor;

  const _StatItem({
    required this.label,
    required this.value,
    this.suffix,
    required this.icon,
    this.iconColor = const Color(0xFFD8EE36),
  });
}

class _StatCard extends StatelessWidget {
  final AppResponsive r;
  final _StatItem item;
  const _StatCard({required this.r, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.sp16),
      decoration: BoxDecoration(
        color: const Color(0xCC13131A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E1E2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.label,
            style: TextStyle(
              fontSize: r.fs10,
              letterSpacing: 1.2,
              color: const Color(0xFFC7C8AE),
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.value,
                style: TextStyle(
                  fontSize: r.fs28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              if (item.suffix != null) ...[
                SizedBox(width: r.w10 * 0.4),
                Padding(
                  padding: EdgeInsets.only(bottom: r.sp4 * 0.5),
                  child: Text(
                    item.suffix!,
                    style: TextStyle(
                      fontSize: r.fs11,
                      color: const Color(0xFFC7C8AE),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Icon(item.icon, color: item.iconColor, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PROFILE MENU
// ─────────────────────────────────────────────
class _ProfileMenu extends StatelessWidget {
  final AppResponsive r;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  const _ProfileMenu({
    required this.r,
    required this.isDark,
    required this.onToggleTheme,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: r.sp8, bottom: r.h10),
          child: Text(
            'ACCOUNT SETTINGS',
            style: TextStyle(
              fontSize: r.fs11,
              letterSpacing: 1.5,
              color: const Color(0xFFC7C8AE),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xCC13131A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E1E2E)),
          ),
          child: Column(
            children: [
              _MenuItem(
                r: r,
                icon: Icons.bookmark_rounded,
                label: 'Saved Questions',
                onTap: () {},
                isFirst: true,
              ),
              _Divider(),
              _MenuItem(
                r: r,
                icon: Icons.analytics_rounded,
                label: 'Detailed Report Card',
                onTap: () => Navigator.pushNamed(context, AppRoutes.reportCard),
              ),
              _Divider(),
              _MenuItem(
                r: r,
                icon: Icons.notifications_active_rounded,
                label: 'Notifications',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.notifications),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD8EE36),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFC7C8AE),
                      size: 20,
                    ),
                  ],
                ),
              ),
              _Divider(),
              _MenuItem(
                r: r,
                icon: Icons.dark_mode_rounded,
                label: 'Dark / Light Mode',
                onTap: onToggleTheme,
                trailing: _ToggleSwitch(isDark: isDark, r: r),
                isLast: true,
              ),
            ],
          ),
        ),
        SizedBox(height: r.h20),

        // Logout button
        GestureDetector(
          onTap: onLogout,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: r.sp16),
            decoration: BoxDecoration(
              color: const Color(0xCC13131A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE53935).withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFFFB4AB),
                  size: 20,
                ),
                SizedBox(width: r.w10),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: r.fs16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFB4AB),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: r.h10),
        GestureDetector(
          onTap: onDeleteAccount,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: r.sp16),
            child: Text(
              'Delete account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.fs14,
                color: const Color(0xFFFFB4AB),
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFFFFB4AB),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFF1E1E2E),
      indent: 0,
      endIndent: 0,
    );
  }
}

class _MenuItem extends StatelessWidget {
  final AppResponsive r;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isFirst;
  final bool isLast;

  const _MenuItem({
    required this.r,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        splashColor: const Color(0xFFD8EE36).withOpacity(0.05),
        highlightColor: const Color(0xFFD8EE36).withOpacity(0.03),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: r.sp16, vertical: r.sp16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFD8EE36), size: 22),
              SizedBox(width: r.w10 + 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: r.fs15,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFC7C8AE),
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  final bool isDark;
  final AppResponsive r;
  const _ToggleSwitch({required this.isDark, required this.r});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 24,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFFD8EE36) : const Color(0xFF353629),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(3),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF191E00)
                    : const Color(0xFFC7C8AE),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AI INSIGHT CARD
// ─────────────────────────────────────────────
class _AiInsightCard extends StatelessWidget {
  final AppResponsive r;
  const _AiInsightCard({required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.sp16),
      decoration: BoxDecoration(
        color: const Color(0xCC13131A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8EE36).withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -16,
            right: -16,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD8EE36).withOpacity(0.05),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(r.sp8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8EE36).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: const Color(0xFFD8EE36),
                  size: r.fs20,
                ),
              ),
              SizedBox(width: r.w10 + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Performance Insight',
                      style: TextStyle(
                        fontSize: r.fs15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: r.h10 * 0.4),
                    Text(
                      "You're performing 14% better in 'Islamic Studies' this week. Focus on 'Current Affairs' to maintain your SST target ranking.",
                      style: TextStyle(
                        fontSize: r.fs13,
                        color: const Color(0xFFC7C8AE),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  LOGOUT DIALOG
// ─────────────────────────────────────────────
class _LogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  const _LogoutDialog({required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2015),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF464834)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE53935).withOpacity(0.1),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFFFB4AB),
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Logout?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You will need to sign in again to access your account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFC7C8AE),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF464834)),
                        color: const Color(0xFF2A2B1F),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFE53935).withOpacity(0.15),
                        border: Border.all(
                          color: const Color(0xFFE53935).withOpacity(0.4),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFB4AB),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────
class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.05),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
