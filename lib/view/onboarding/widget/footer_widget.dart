import 'package:examace/const/app_colors.dart';
import 'package:examace/const/app_responsive.dart';
import 'package:flutter/material.dart';

class FooterCTA extends StatelessWidget {
  final String btnTitle;
  final AppResponsive r;
  final bool enabled;
  final Future<void> Function()? onTap;

  const FooterCTA({
    super.key,
    required this.r,
    required this.btnTitle,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFF131409), Color(0xFF131409), Colors.transparent],
          stops: [0, 0.0, 0],
        ),
      ),
      padding: EdgeInsets.fromLTRB(r.sp20, r.h30, r.sp20, r.h30),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: r.h50 * 1.1,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: enabled
                    ? AppColors.yellow
                    : const Color(0xFF353629),
                foregroundColor: enabled
                    ? const Color(0xFF191E00)
                    : const Color(0xFF91937A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r.sp12 + 2),
                ),
                elevation: 0,
                textStyle: TextStyle(
                  fontSize: r.fs18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: enabled ? () async => await onTap?.call() : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(btnTitle, style: TextStyle(fontSize: r.fs18)),
                  SizedBox(width: r.w10 * 0.8),
                  Icon(Icons.rocket_launch_rounded, size: r.fs20),
                ],
              ),
            ),
          ),

          SizedBox(height: r.h10),

          Text(
            'Change your target later in Profile Settings',
            style: TextStyle(
              fontSize: r.fs11,
              letterSpacing: 0.8,
              color: const Color(0x99C7C8AE),
            ),
          ),
        ],
      ),
    );
  }
}
