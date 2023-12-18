import 'package:flutter/material.dart';
import 'package:plan_sync/util/colors.dart';
import 'package:plan_sync/widgets/semester_bar.dart';
import '../widgets/filters_bar.dart';
import '../widgets/time_table.dart';
import '../widgets/version_check.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: black,
          elevation: 0.0,
          toolbarHeight: 80,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(32),
          )),
          title: const Text(
            "Plan Sync - KIIT",
            style: TextStyle(
              color: white,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  VersionCheckWidget(),
                  SizedBox(height: 40),
                  Text(
                    "Time Sheet",
                    style: TextStyle(
                      color: black,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SemesterBar(),
                        SizedBox(width: 16),
                        FiltersBar(),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  TimeTableWidget()
                ],
              ),
              SizedBox(height: 60)
            ],
          ),
        ));
  }
}
