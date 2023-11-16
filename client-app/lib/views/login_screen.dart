import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/util/colors.dart';
import 'package:plan_sync/util/external_links.dart';

import '../controllers/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Auth auth = Get.find();
  bool isWorking = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: white,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              const Column(
                children: [
                  Text(
                    "Plan Sync - KIIT",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 0.2),
                  ),
                  SizedBox(height: 16),
                  Text("Sync Your College Life with Ease,"),
                  Text("Advanced, straight to point.")
                ],
              ),
              const Spacer(flex: 4),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: const ButtonStyle(
                        padding: MaterialStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        ),
                        enableFeedback: true,
                        side:
                            MaterialStatePropertyAll(BorderSide(color: border)),
                        backgroundColor: MaterialStatePropertyAll(primary)),
                    onPressed: () async {
                      setState(() {
                        isWorking = true;
                      });
                      await auth.loginWithGoogle();
                      if (!mounted) return;
                      setState(() {
                        isWorking = false;
                      });
                    },
                    icon: const Icon(FontAwesomeIcons.google, color: white),
                    label: isWorking
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: LoadingAnimationWidget.prograssiveDots(
                                color: white, size: 24),
                          )
                        : const Text(
                            "Continue with Google",
                            style: TextStyle(color: white),
                          ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              Column(
                children: [
                  const Text(
                    "Associate Tech Partner",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    enableFeedback: true,
                    onTap: () => ExternalLinks.cardlink(),
                    child: SizedBox(
                        height: 48,
                        child: Image.asset('assets/logo-no-background.png')),
                  )
                ],
              ),
              const Spacer(),
            ],
          ),
        ));
  }
}
