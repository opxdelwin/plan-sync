import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:plan_sync/backend/models/remote_config/hud_notices_model.dart';
import 'package:plan_sync/controllers/remote_config_controller.dart';
import 'package:plan_sync/controllers/version_controller.dart';
import 'package:plan_sync/widgets/hud/notice_carousel_widget.dart';
import 'package:plan_sync/widgets/version_check.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TopNoticeHud extends StatefulWidget {
  const TopNoticeHud({super.key});

  @override
  State<TopNoticeHud> createState() => _TopNoticeHudState();
}

class _TopNoticeHudState extends State<TopNoticeHud> {
  late PageController pageController;

  // for remote notifications on HUD
  List<HudNoticeModel> notices = [];

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    final remoteConfig =
        Provider.of<RemoteConfigController>(context, listen: false);
    final result = await remoteConfig.getNotices();
    // Remove items that should not be shown
    result.removeWhere((item) => !item.shouldShow(context));
    // Update the state
    setState(() {
      notices = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Selector<VersionController, bool>(
      selector: (context, versionController) =>
          versionController.isUpdateAvailable,
      builder: (context, isUpdateAvailable, _) {
        List<Widget> widgets = [
          if (isUpdateAvailable) const VersionCheckWidget(),
          if (notices.isNotEmpty)
            ...List.generate(
              notices.length,
              (index) => NoticeCarouselWidget(
                notice: notices[index],
                onDelete: () {
                  setState(() {
                    notices[index].dismissNotice(context);
                    notices.removeAt(index);
                  });
                },
              ),
            ),
        ];

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            Animation<Offset> tween = Tween<Offset>(
              begin: const Offset(-1.0, 0),
              end: const Offset(0.0, 0),
            ).animate(animation);
            return SlideTransition(
              position: tween,
              child: child,
            );
          },
          child: widgets.isEmpty
              ? const SizedBox()
              : Column(
                  children: [
                    ExpandablePageView(
                      controller: pageController,
                      children: widgets,
                    ),
                    if (widgets.length > 1) ...[
                      const SizedBox(height: 8),
                      SmoothPageIndicator(
                        controller: pageController,
                        count: widgets.length,
                        effect: WormEffect(
                          dotHeight: 6,
                          dotWidth: 6,
                          activeDotColor: colorScheme.secondary,
                          dotColor: colorScheme.onSurface.withOpacity(0.48),
                          paintStyle: PaintingStyle.stroke,
                        ),
                        onDotClicked: (index) {
                          pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ],
                    SizedBox(height: widgets.length > 1 ? 8 : 12),
                  ],
                ),
        );
      },
    );
  }
}
