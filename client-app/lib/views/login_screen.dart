import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/controllers/theme_controller.dart';
import 'package:plan_sync/util/enums.dart';
import 'package:plan_sync/util/external_links.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../controllers/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Auth auth;
  bool isWorking = false;

  @override
  initState() {
    auth = Provider.of<Auth>(context, listen: false);
    super.initState();
  }

  Future<void> loginProcedure({required LoginProvider provider}) async {
    setState(() {
      isWorking = true;
    });

    switch (provider) {
      case LoginProvider.google:
        {
          await auth.loginWithGoogle(context);
          break;
        }
      case LoginProvider.apple:
        {
          await auth.loginWithApple(context);
          break;
        }
    }

    if (!mounted) return;
    setState(() {
      isWorking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final appTheme = Provider.of<AppThemeController>(context, listen: false);

    return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Stack(
            children: [
              //background doodle
              Opacity(
                opacity: appTheme.isDarkMode ? 1.0 : 0.24,
                child: SvgPicture.asset(
                  appTheme.isDarkMode
                      ? 'assets/login/background-dark.svg'
                      : 'assets/login/background-light.svg',
                  fit: BoxFit.cover,
                ),
              ),

              // main screen
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 7),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        "Synchronize,\nCollaborate,\nElevate.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          letterSpacing: 0.2,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 64),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                              elevation: const WidgetStatePropertyAll(0),
                              padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 24,
                                ),
                              ),
                              enableFeedback: true,
                              backgroundColor:
                                  WidgetStatePropertyAll(colorScheme.primary),
                            ),
                            onPressed: () => loginProcedure(
                              provider: LoginProvider.google,
                            ),
                            icon: Icon(
                              FontAwesomeIcons.google,
                              color: colorScheme.onPrimary,
                            ),
                            label: isWorking
                                ? Semantics(
                                    value: 'Loading',
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32.0,
                                      ),
                                      child: LoadingAnimationWidget
                                          .progressiveDots(
                                        color: colorScheme.onPrimary,
                                        size: 24,
                                      ),
                                    ),
                                  )
                                : Text(
                                    "Continue with Google",
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                              elevation: const WidgetStatePropertyAll(0),
                              padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 24,
                                ),
                              ),
                              enableFeedback: true,
                              side: WidgetStatePropertyAll(
                                BorderSide(color: colorScheme.onSurface),
                              ),
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.transparent.withOpacity(0.04),
                              ),
                            ),
                            onPressed: () => loginProcedure(
                              provider: LoginProvider.apple,
                            ),
                            icon: Icon(
                              FontAwesomeIcons.apple,
                              color: colorScheme.onSurface,
                            ),
                            label: isWorking
                                ? Semantics(
                                    value: 'Loading',
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32.0,
                                      ),
                                      child: LoadingAnimationWidget
                                          .progressiveDots(
                                        color: colorScheme.onSurface,
                                        size: 24,
                                      ),
                                    ),
                                  )
                                : Text(
                                    "Continue with Apple",
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  Column(
                    children: [
                      Text(
                        "Associate Tech Partner",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        enableFeedback: true,
                        onTap: () => ExternalLinks.cardlink(),
                        child: SizedBox(
                          height: 48,
                          child: Image.asset(
                            appTheme.isDarkMode
                                ? 'assets/logo-no-background-dark.png'
                                : 'assets/logo-no-background-light.png',
                            semanticLabel: 'Cardlink',
                          ),
                        ),
                      )
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.16),
                    child: Text(
                      "By continuing you agree Plan Sync's Terms of Service and Privacy Policy.",
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ));
  }
}
