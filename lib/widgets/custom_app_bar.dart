import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,
      actions: actions ?? [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // 알림 화면으로 이동
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // 설정 화면으로 이동
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}