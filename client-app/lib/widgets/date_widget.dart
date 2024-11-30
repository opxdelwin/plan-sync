import 'package:flutter/material.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/theme_controller.dart';
import 'package:plan_sync/util/enums.dart';
import 'package:provider/provider.dart';

class DateWidget extends StatelessWidget {
  const DateWidget({super.key});

  DateTime mostRecentSunday() {
    final date = DateTime.now();
    return DateTime(date.year, date.month, date.day - date.weekday % 7);
  }

  @override
  Widget build(BuildContext context) {
    final days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final colorScheme = Theme.of(context).colorScheme;
    final appTheme = Provider.of<AppThemeController>(context, listen: false);

    return Consumer<FilterController>(
      builder: (ctx, filterController, child) {
        return Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: appTheme.isDarkMode
                  ? BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : BorderSide.none,
            ),
            color: appTheme.isDarkMode
                ? null
                : Theme.of(context).colorScheme.primary.withOpacity(0.32),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              7,
              (index) => Column(
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    enableFeedback: true,
                    onTap: () =>
                        filterController.weekday = Weekday.fromIndex(index),
                    child: CircleAvatar(
                      backgroundColor:
                          filterController.weekday.weekdayIndex == index
                              ? colorScheme.secondary
                              : colorScheme.surface,
                      child: Text(
                        '${mostRecentSunday().add(Duration(days: index)).day}',
                        style: TextStyle(
                          color: filterController.weekday.weekdayIndex == index
                              ? colorScheme.onSecondary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
