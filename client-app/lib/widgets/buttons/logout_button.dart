import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/controllers/auth.dart';

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
    auth = Get.find();
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
    return ElevatedButton.icon(
      style: ButtonStyle(
        elevation: const MaterialStatePropertyAll(0.0),
        backgroundColor: MaterialStatePropertyAll(colorScheme.error),
      ),
      onPressed: logout,
      icon: Icon(Icons.logout, color: colorScheme.onError),
      label: isLoggingOut
          ? LoadingAnimationWidget.prograssiveDots(
              color: colorScheme.onError,
              size: 24,
            )
          : Text(
              "Logout",
              style: TextStyle(color: colorScheme.onError),
            ),
    );
  }
}
