import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/util/enums.dart';

class DateWidget extends StatelessWidget {
  const DateWidget({super.key});

  DateTime mostRecentSunday() {
    final date = DateTime.now();
    return DateTime(date.year, date.month, date.day - date.weekday % 7);
  }

  @override
  Widget build(BuildContext context) {
    final days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return GetBuilder<FilterController>(
      builder: (controller) {
        return Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Theme.of(context).colorScheme.primary,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              7,
              (index) => Column(
                children: [
                  Text(days[index]),
                  const SizedBox(height: 8),
                  InkWell(
                    enableFeedback: true,
                    onTap: () => controller.weekday = Weekday.fromIndex(index),
                    child: CircleAvatar(
                      backgroundColor: controller.weekday.weekdayIndex == index
                          ? Colors.red
                          : Theme.of(context).colorScheme.surface,
                      child: Text(
                        '${mostRecentSunday().add(Duration(days: index)).day}',
                        style: TextStyle(
                          color: controller.weekday.weekdayIndex == index
                              ? Colors.white
                              : Colors.black,
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
