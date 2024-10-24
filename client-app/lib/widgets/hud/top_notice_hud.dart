import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/backend/models/remote_config/hud_notices_model.dart';
import 'package:plan_sync/controllers/remote_config_controller.dart';
import 'package:plan_sync/controllers/version_controller.dart';
import 'package:plan_sync/widgets/hud/notice_carousel_widget.dart';
import 'package:plan_sync/widgets/version_check.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TopNoticeHud extends StatefulWidget {
  const TopNoticeHud({super.key});

  @override
  State<TopNoticeHud> createState() => _TopNoticeHudState();
}

class _TopNoticeHudState extends State<TopNoticeHud> {
  late VersionController versionController;
  late RemoteConfigController remoteConfig;
  late PageController pageController;

  bool isUpdateAvailable = false;
  List<HudNoticeModel> notices = [];

  @override
  void initState() {
    super.initState();
    versionController = Get.find();
    remoteConfig = Get.find();
    pageController = PageController();

    versionController.checkForUpdate().then((val) => setState(() {
          isUpdateAvailable = val;
        }));

    remoteConfig.getNotices().then((result) {
      result.removeWhere(
        (item) => !item.shouldShow(),
      );
      setState(() {
        notices = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    List<Widget> widgets = [
      if (isUpdateAvailable) const VersionCheckWidget(),
      if (notices.isNotEmpty)
        ...List.generate(
          notices.length,
          (index) => NoticeCarouselWidget(
            notice: notices[index],
            onDelete: () => setState(() {
              notices[index].dismissNotice();
              notices.removeAt(index);
            }),
          ),
        )
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
                      dotColor: colorScheme.onSurface.withValues(alpha: 0.48),
                      paintStyle: PaintingStyle.stroke,
                    ),
                    onDotClicked: (index) {
                      pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    },
                  )
                ],
                SizedBox(height: widgets.length > 1 ? 8 : 12),
              ],
            ),
    );
  }
}
