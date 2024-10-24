import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/backend/models/remote_config/hud_notices_model.dart';
import 'package:url_launcher/url_launcher.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          if (notice.action != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => launchUrl(
                  Uri.parse(
                    Platform.isAndroid
                        ? notice.action!.androidUrl
                        : notice.action!.iosUrl,
                  ),
                ),
                style: ButtonStyle(
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16),
                  ),
                  backgroundColor: WidgetStatePropertyAll(
                    Get.isDarkMode
                        ? Colors.transparent
                        : colorScheme.primaryContainer,
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Get.isDarkMode
                              ? colorScheme.primaryContainer
                              : Colors.transparent,
                        )),
                  ),
                ),
                child: Text(
                  notice.action!.label,
                  style: TextStyle(
                    color: Get.isDarkMode
                        ? colorScheme.onSurface
                        : colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
