// lib/view/notifications/notifications_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:examace/const/app_responsive.dart';
import 'package:examace/model/model.dart';
import 'package:examace/view_model/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────
enum _NotifCategory { all, unread, archived }

enum _NotifType { examAlert, insight, reminder, community }

class _NotifItem {
  final String id;
  final _NotifType type;
  final String label;
  final String title;
  final String body;
  final String time;
  final bool isUnread;
  final bool archived;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color labelColor;
  final String? highlightWord;
  final Color? highlightColor;

  const _NotifItem({
    required this.id,
    required this.type,
    required this.label,
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
    required this.archived,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.labelColor,
    this.highlightWord,
    this.highlightColor,
  });

  factory _NotifItem.fromAppNotification(AppNotificationModel notification) {
    final style = _styleForType(notification.type);

    return _NotifItem(
      id: notification.id,
      type: style.type,
      label: style.label,
      title: notification.title,
      body: notification.body,
      time: notification.timeLabel,
      isUnread: !notification.isRead,
      archived: notification.archived,
      icon: style.icon,
      iconBg: style.iconBg,
      iconColor: style.iconColor,
      labelColor: style.labelColor,
      highlightWord: notification.data['highlightWord']?.toString(),
      highlightColor: style.highlightColor,
    );
  }
}

// ─────────────────────────────────────────────
//  PROVIDER
// ─────────────────────────────────────────────
final _notifCategoryProvider = StateProvider.autoDispose<_NotifCategory>((ref) {
  return _NotifCategory.all;
});

List<_NotifItem> _filterItems(List<_NotifItem> items, _NotifCategory category) {
  switch (category) {
    case _NotifCategory.unread:
      return items.where((n) => n.isUnread && !n.archived).toList();
    case _NotifCategory.archived:
      return items.where((n) => n.archived).toList();
    case _NotifCategory.all:
      return items.where((n) => !n.archived).toList();
  }
}

_NotifStyle _styleForType(String type) {
  switch (type) {
    case 'exam':
    case 'examAlert':
      return const _NotifStyle(
        type: _NotifType.examAlert,
        label: 'EXAM ALERT',
        icon: Icons.assignment_rounded,
        iconBg: Color(0x4D5822B8),
        iconColor: Color(0xFFD1BCFF),
        labelColor: Color(0xFFD8EE36),
        highlightColor: Color(0xFFD8EE36),
      );
    case 'insight':
      return const _NotifStyle(
        type: _NotifType.insight,
        label: 'INSIGHT',
        icon: Icons.trending_up_rounded,
        iconBg: Color(0xFF2A2B1F),
        iconColor: Color(0xFFE4E3D1),
        labelColor: Color(0xFF91937A),
        highlightColor: Color(0xFFD8EE36),
      );
    case 'reminder':
      return const _NotifStyle(
        type: _NotifType.reminder,
        label: 'REMINDER',
        icon: Icons.event_rounded,
        iconBg: Color(0x3393000A),
        iconColor: Color(0xFFFFB4AB),
        labelColor: Color(0xFFFFB4AB),
        highlightColor: Color(0xFFFFB4AB),
      );
    case 'community':
      return const _NotifStyle(
        type: _NotifType.community,
        label: 'COMMUNITY',
        icon: Icons.description_rounded,
        iconBg: Color(0xFF2A2B1F),
        iconColor: Color(0xFFE4E3D1),
        labelColor: Color(0xFF91937A),
      );
    default:
      return const _NotifStyle(
        type: _NotifType.reminder,
        label: 'UPDATE',
        icon: Icons.notifications_rounded,
        iconBg: Color(0xFF2A2B1F),
        iconColor: Color(0xFFE4E3D1),
        labelColor: Color(0xFFD8EE36),
        highlightColor: Color(0xFFD8EE36),
      );
  }
}

class _NotifStyle {
  final _NotifType type;
  final String label;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color labelColor;
  final Color? highlightColor;

  const _NotifStyle({
    required this.type,
    required this.label,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.labelColor,
    this.highlightColor,
  });
}

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = AppResponsive(context);
    final category = ref.watch(_notifCategoryProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final firebaseUser = ref.watch(authStateProvider).valueOrNull;
    final notifications = firebaseUser == null
        ? const AsyncValue<List<AppNotificationModel>>.data([])
        : ref.watch(userNotificationsProvider(firebaseUser.uid));
    final initials = user?.initials ?? '?';

    return Scaffold(
      backgroundColor: const Color(0xFF131409),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          // Glow blobs
          Positioned(
            top: -100,
            left: -80,
            child: _GlowBlob(color: const Color(0xFFD8EE36), size: r.wp(60)),
          ),

          Column(
            children: [
              _TopBar(r: r, initials: initials),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    r.sp20,
                    r.h20,
                    r.sp20,
                    r.h100 + r.h20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Heading ──────────────────────
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: r.fs36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: r.h20),

                      // ── Category Chips ───────────────
                      _CategoryChips(
                        r: r,
                        selected: category,
                        onSelect: (value) {
                          ref.read(_notifCategoryProvider.notifier).state =
                              value;
                        },
                      ),
                      SizedBox(height: r.h20),

                      // ── Notification Feed ────────────
                      notifications.when(
                        data: (items) {
                          final filtered = _filterItems(
                            items
                                .map(_NotifItem.fromAppNotification)
                                .toList(growable: false),
                            category,
                          );

                          if (filtered.isEmpty) {
                            return _EmptyNotificationsCard(r: r);
                          }

                          return Column(
                            children: filtered
                                .map(
                                  (n) => Padding(
                                    padding: EdgeInsets.only(bottom: r.sp12),
                                    child: _NotifCard(
                                      r: r,
                                      item: n,
                                      onTap: () {
                                        final uid = firebaseUser?.uid;
                                        if (uid == null) return;
                                        ref
                                            .read(
                                              notificationRepositoryProvider,
                                            )
                                            .markRead(uid, n.id);
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                        loading: () => _LoadingNotifications(r: r),
                        error: (_, _) => _NotificationErrorCard(r: r),
                      ),

                      // ── AI Sparkle Card ──────────────
                      SizedBox(height: r.sp4),
                      _AiSparkleCard(r: r),
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
}

// ─────────────────────────────────────────────
//  TOP BAR
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final AppResponsive r;
  final String initials;
  const _TopBar({required this.r, required this.initials});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(r.sp16, top + r.sp12, r.sp20, r.sp12),
      decoration: BoxDecoration(
        color: const Color(0xFF131409).withOpacity(0.85),
        border: const Border(bottom: BorderSide(color: Color(0x4D464834))),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5822B8),
              border: Border.all(
                color: const Color(0xFF464834).withOpacity(0.4),
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD8EE36),
                ),
              ),
            ),
          ),
          SizedBox(width: r.w10),

          // Brand
          Text(
            'ExamAce',
            style: TextStyle(
              fontSize: r.fs22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFD8EE36),
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),

          // Active notification bell
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD8EE36).withOpacity(0.1),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Color(0xFFD8EE36),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotificationsCard extends StatelessWidget {
  final AppResponsive r;

  const _EmptyNotificationsCard({required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.sp20),
      decoration: BoxDecoration(
        color: const Color(0xCC13131A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E1E2E)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: const Color(0xFFC7C8AE).withOpacity(.7),
            size: r.fs32,
          ),
          SizedBox(height: r.sp8),
          Text(
            'No notifications yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: r.fs15,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: r.sp4),
          Text(
            'Exam alerts, reminders, and insights will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFC7C8AE),
              fontSize: r.fs13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingNotifications extends StatelessWidget {
  final AppResponsive r;

  const _LoadingNotifications({required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.sp20),
      decoration: BoxDecoration(
        color: const Color(0xCC13131A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E1E2E)),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFFD8EE36)),
      ),
    );
  }
}

class _NotificationErrorCard extends StatelessWidget {
  final AppResponsive r;

  const _NotificationErrorCard({required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.sp16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B120B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6A2B17)),
      ),
      child: Text(
        'Unable to load notifications right now.',
        style: TextStyle(
          color: const Color(0xFFE6B7AF),
          fontSize: r.fs13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CATEGORY CHIPS
// ─────────────────────────────────────────────
class _CategoryChips extends StatelessWidget {
  final AppResponsive r;
  final _NotifCategory selected;
  final void Function(_NotifCategory) onSelect;

  const _CategoryChips({
    required this.r,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final chips = [
      (_NotifCategory.all, 'All'),
      (_NotifCategory.unread, 'Unread'),
      (_NotifCategory.archived, 'Archived'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((chip) {
          final isSelected = selected == chip.$1;
          return Padding(
            padding: EdgeInsets.only(right: r.sp8),
            child: GestureDetector(
              onTap: () => onSelect(chip.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: r.sp20,
                  vertical: r.sp8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFD8EE36)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFD8EE36)
                        : const Color(0xFF464834),
                  ),
                ),
                child: Text(
                  chip.$2,
                  style: TextStyle(
                    fontSize: r.fs12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: isSelected
                        ? const Color(0xFF191E00)
                        : const Color(0xFFC7C8AE),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NOTIFICATION CARD
// ─────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final AppResponsive r;
  final _NotifItem item;
  final VoidCallback onTap;

  const _NotifCard({required this.r, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(r.sp16),
        decoration: BoxDecoration(
          color: item.isUnread
              ? const Color(0xFF1F2015)
              : const Color(0xCC13131A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isUnread
                ? const Color(0xFF464834)
                : const Color(0xFF1E1E2E),
          ),
        ),
        child: Stack(
          children: [
            // Unread dot
            if (item.isUnread)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD8EE36),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD8EE36).withOpacity(0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 22),
                ),
                SizedBox(width: r.sp12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label + time row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: r.fs10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                              color: item.labelColor,
                            ),
                          ),
                          Text(
                            item.time,
                            style: TextStyle(
                              fontSize: r.fs12,
                              color: const Color(0xFFC7C8AE).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: r.sp4),

                      // Title
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: r.fs15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: r.sp4),

                      // Body with optional highlight
                      _HighlightText(
                        r: r,
                        text: item.body,
                        highlight: item.highlightWord,
                        highlightColor: item.highlightColor,
                      ),
                    ],
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
//  HIGHLIGHT TEXT
// ─────────────────────────────────────────────
class _HighlightText extends StatelessWidget {
  final AppResponsive r;
  final String text;
  final String? highlight;
  final Color? highlightColor;

  const _HighlightText({
    required this.r,
    required this.text,
    this.highlight,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (highlight == null || !text.contains(highlight!)) {
      return Text(
        text,
        style: TextStyle(
          fontSize: r.fs13,
          color: const Color(0xFFC7C8AE),
          height: 1.5,
        ),
      );
    }

    final parts = text.split(highlight!);
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: r.fs13,
          color: const Color(0xFFC7C8AE),
          height: 1.5,
        ),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: highlight,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: highlightColor,
            ),
          ),
          TextSpan(text: parts.sublist(1).join(highlight!)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AI SPARKLE CARD
// ─────────────────────────────────────────────
class _AiSparkleCard extends StatelessWidget {
  final AppResponsive r;
  const _AiSparkleCard({required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.sp16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C11),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8EE36).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row with animated sparkle
          Row(
            children: [
              _SparkleIcon(),
              SizedBox(width: r.sp8),
              Text(
                'AI RECOMMENDED',
                style: TextStyle(
                  fontSize: r.fs10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD8EE36),
                ),
              ),
            ],
          ),
          SizedBox(height: r.sp8),

          Text(
            'Optimize your study schedule',
            style: TextStyle(
              fontSize: r.fs16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: r.sp8),

          Text(
            "Based on your recent performance, we suggest focusing 20% more on 'Analytical Reasoning' this week.",
            style: TextStyle(
              fontSize: r.fs13,
              color: const Color(0xFFC7C8AE),
              height: 1.6,
            ),
          ),
          SizedBox(height: r.sp16),

          // CTA button
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.sp16,
                vertical: r.sp8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFD8EE36),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Adjust Schedule',
                style: TextStyle(
                  fontSize: r.fs12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: const Color(0xFF191E00),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated sparkle star icon
class _SparkleIcon extends StatefulWidget {
  @override
  State<_SparkleIcon> createState() => _SparkleIconState();
}

class _SparkleIconState extends State<_SparkleIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFFE8FF47), Color(0xFFBC93FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white,
          size: 20,
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
        color: color.withOpacity(0.04),
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
