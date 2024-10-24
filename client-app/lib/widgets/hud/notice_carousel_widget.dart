import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/backend/models/remote_config/hud_notices_model.dart';

class NoticeCarouselWidget extends StatelessWidget {
  const NoticeCarouselWidget({
    super.key,
    required this.notice,
    required this.onDelete,
  });

  final HudNoticeModel notice;
  final Function onDelete;

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
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 8.0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    notice.title,
                    style: TextStyle(
                      color: Get.isDarkMode
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => onDelete.call(),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.cancel_outlined,
                      color: colorScheme.onSurface.withValues(alpha: 0.88),
                    ),
                  ),
                ),
              ],
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
