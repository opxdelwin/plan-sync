import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/controllers/auth.dart';
import 'package:plan_sync/controllers/theme_controller.dart';
import 'package:provider/provider.dart';

class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key});

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  bool isLoggingOut = false;
  late Auth auth;

  @override
  void initState() {
    super.initState();
    auth = Provider.of<Auth>(context, listen: false);
  }

  void logout() async {
    setState(() {
      isLoggingOut = true;
    });
    await auth.logout();
    if (mounted) {
      setState(() {
        isLoggingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appTheme = Provider.of<AppThemeController>(context, listen: false);

    return ElevatedButton.icon(
      style: ButtonStyle(
        side: appTheme.isDarkMode
            ? WidgetStatePropertyAll(
                BorderSide(
                  color: colorScheme.error,
                ),
              )
            : null,
        elevation: const WidgetStatePropertyAll(0.0),
        backgroundColor: appTheme.isDarkMode
            ? const WidgetStatePropertyAll(Colors.transparent)
            : WidgetStatePropertyAll(colorScheme.error),
      ),
      onPressed: logout,
      icon: Icon(
        Icons.logout,
        color: appTheme.isDarkMode
            ? colorScheme.onSurfaceVariant
            : colorScheme.onError,
      ),
      label: isLoggingOut
          ? LoadingAnimationWidget.progressiveDots(
              color: appTheme.isDarkMode ? Colors.white : colorScheme.onError,
              size: 24,
            )
          : Text(
              "Logout",
              style: TextStyle(
                color: appTheme.isDarkMode ? Colors.white : colorScheme.onError,
              ),
            ),
    );
  }
}
