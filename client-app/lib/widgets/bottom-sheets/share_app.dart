import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plan_sync/controllers/theme_controller.dart';
import 'package:plan_sync/util/external_links.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShareAppSheet extends StatelessWidget {
  const ShareAppSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final appTheme = Provider.of<AppThemeController>(context, listen: false);

    return Padding(
      padding: EdgeInsets.only(
        left: size.width * 0.04,
        right: size.width * 0.04,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Get Plan Sync for Your Device",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          const Text("Scan this QR code to download our app :)"),
          QrImageView(
            data: 'https://plansync.in/',
            padding: const EdgeInsets.all(16),
            size: size.width * 0.48,
            dataModuleStyle: QrDataModuleStyle(
              color: colorScheme.onSurface.withValues(
                alpha: appTheme.isDarkMode ? 0.92 : 1,
              ),
              dataModuleShape: QrDataModuleShape.square,
            ),
            eyeStyle: QrEyeStyle(
              color: colorScheme.onSurface.withValues(
                alpha: appTheme.isDarkMode ? 0.92 : 1,
              ),
              eyeShape: QrEyeShape.square,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              SizedBox(width: 16),
              Expanded(child: Divider()),
              SizedBox(width: 8),
              Text("OR"),
              SizedBox(width: 8),
              Expanded(child: Divider()),
              SizedBox(width: 16),
            ],
          ),
          // const SizedBox(height: 8),
          ListTile(
            leading: const Icon(FontAwesomeIcons.share),
            title: const Text("Share via other apps"),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () {
              ExternalLinks.shareApp();
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
