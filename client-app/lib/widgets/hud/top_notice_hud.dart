import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/backend/models/remote_config/hud_notices_model.dart';
import 'package:plan_sync/controllers/remote_config_controller.dart';
import 'package:plan_sync/controllers/version_controller.dart';
import 'package:plan_sync/widgets/hud/notice_carousel_widget.dart';
import 'package:plan_sync/widgets/version_check.dart';

class TopNoticeHud extends StatefulWidget {
  const TopNoticeHud({super.key});

  @override
  State<TopNoticeHud> createState() => _TopNoticeHudState();
}

class _TopNoticeHudState extends State<TopNoticeHud> {
  late VersionController versionController;
  late RemoteConfigController remoteConfig;

  bool isUpdateAvailable = false;
  List<HudNoticeModel> notices = [];

  @override
  void initState() {
    super.initState();
    versionController = Get.find();
    remoteConfig = Get.find();

    versionController.checkForUpdate().then((val) => setState(() {
          isUpdateAvailable = val;
        }));
    remoteConfig.getNotices().then((result) => setState(() {
          notices = result;
        }));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      if (isUpdateAvailable) const VersionCheckWidget(),
      if (notices.isNotEmpty)
        ...List.generate(
          notices.length,
          (index) => NoticeCarouselWidget(notice: notices[index]),
        )
    ];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
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
          : ExpandablePageView(
              children: widgets,
            ),
    );
  }
}
