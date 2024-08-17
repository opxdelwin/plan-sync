import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/backend/models/remote_config/hud_notices_model.dart';

class NoticeCarouselWidget extends StatelessWidget {
  const NoticeCarouselWidget({super.key, required this.notice});

  final HudNoticeModel notice;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: Get.isDarkMode
              ? BorderSide.none
              : BorderSide(
                  color: colorScheme.onSurfaceVariant,
                ),
        ),
        color: Get.isDarkMode
            ? colorScheme.surface
            : colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ListTile(
            title: Text(
              notice.title,
              style: TextStyle(
                color: Get.isDarkMode
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            subtitle: Text(
              notice.description,
              style: TextStyle(
                color: Get.isDarkMode
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            leading: const Icon(
              Icons.notifications_active_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
