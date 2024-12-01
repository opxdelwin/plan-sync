import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plan_sync/backend/supabase_models/academic_years.dart';
import 'package:plan_sync/backend/supabase_models/branches.dart';
import 'package:plan_sync/backend/supabase_models/programs.dart';
import 'package:plan_sync/backend/supabase_models/section.dart';
import 'package:plan_sync/backend/supabase_models/semesters.dart';
import 'package:plan_sync/backend/supabase_models/student_schedule.dart';
import 'package:plan_sync/controllers/auth.dart';
import 'package:plan_sync/util/local_database/db_wrapper.dart';
import 'package:plan_sync/util/local_database/tables/local_academic_years.dart';
import 'package:plan_sync/util/local_database/tables/local_branches.dart';
import 'package:plan_sync/util/local_database/tables/local_programs.dart';
import 'package:plan_sync/util/local_database/tables/local_section.dart';
import 'package:plan_sync/util/local_database/tables/local_semesters.dart';
import 'package:plan_sync/util/local_database/tables/local_student_schedule.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

Future _onConfigure(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');
}

class LocalDatabaseProvider extends ChangeNotifier {
  Database? _localDb;
  set localDb(Database? db) {
    _localDb = db;
    notifyListeners();
  }

  Database? get localDb => _localDb;

  // Basically initialize the database for current user.
  Future<void> setupDatabase(BuildContext context) async {
    if (localDb != null) {
      await localDb!.close();
      localDb = null;
    }

    final auth = Provider.of<Auth>(context, listen: false);
    if (auth.activeUser == null) {
      return;
    }

    localDb = await openDatabase(
      'plansync-local-db-v2.db',
      onConfigure: _onConfigure,
    );
    await LocalDatabaseWrapper.createAllTables(localDb!);
    notifyListeners();
  }

  void close() async {
    await localDb?.close();
    localDb = null;
  }

  /// Get academic programs from client db.
  Future<List<Program>> getProgramsFromLocal() async {
    if (localDb == null) {
      return [];
    }

    return await LocalPrograms.queryAll(localDb!);
  }

  /// inserts all programs into sqlite db
  Future<void> insertProgramsToLocal(List<Program> programs) async {
    if (localDb == null) {
      return;
    }

    // convert all to json
    List<Map> jsonPrograms = [];
    for (var item in programs) {
      jsonPrograms.add(item.toJson());
    }

    await LocalPrograms.clearAll(localDb!);
    await LocalPrograms.insertAll(localDb!, jsonPrograms);
  }

  /// Get academic years from sqlite client db.
  /// Creates the table as well if it doesn't exists.
  Future<List<AcademicYear>> getYearsFromLocal() async {
    if (localDb == null) {
      return [];
    }

    return await LocalAcademicYears.queryAll(localDb!);
  }

  /// inserts all academic years into sqlite db
  Future<void> insertYearsToLocal(List<AcademicYear> academicYears) async {
    if (localDb == null) {
      return;
    }

    // convert all to json
    List<Map> jsonYears = [];
    for (var item in academicYears) {
      jsonYears.add(item.toJson());
    }

    await LocalAcademicYears.clearAll(localDb!);
    await LocalAcademicYears.insertAll(localDb!, jsonYears);
  }

  /// Get academic programs from client db.
  Future<List<Semesters>> getSemestersFromLocal({
    required String academicYear,
    required String programName,
    required String branchName,
  }) async {
    if (localDb == null) {
      return [];
    }

    return await LocalSemesters.queryAll(
      localDb!,
      academicYear: academicYear,
      programName: programName,
      branchName: branchName,
    );
  }

  /// inserts all programs into sqlite db
  /// TODO: add branch to query
  Future<void> insertSemestersToLocal(
    List<Semesters> semesters, {
    required String programName,
    required String academicYear,
    required String branchName,
  }) async {
    if (localDb == null) {
      return;
    }

    // convert all to json
    List<Map> jsonSemesters = [];
    for (var item in semesters) {
      jsonSemesters.add(item.toJson());
    }

    await LocalSemesters.clearAll(
      localDb!,
      programName: programName,
      academicYear: academicYear,
      branchName: branchName,
    );
    await LocalSemesters.insertAll(localDb!, jsonSemesters);
  }

  /// Get academic programs from client db.
  Future<List<Section>> getSectionsFromLocal({
    required String academicYear,
    required String programName,
    required String branch,
    required String semester,
  }) async {
    if (localDb == null) {
      return [];
    }

    return await LocalSection.queryAll(
      localDb!,
      academicYear: academicYear,
      program: programName,
      branch: branch,
      semester: semester,
    );
  }

  /// inserts all programs into sqlite db
  Future<void> insertSectionsToLocal(
    List<Section> sections, {
    required String academicYear,
    required String programName,
    required String branch,
    required String semester,
  }) async {
    if (localDb == null) {
      return;
    }

    // convert all to json
    List<Map> jsonSections = [];
    for (var item in sections) {
      jsonSections.add(item.toJson());
    }

    // await LocalSection.clearAll(
    //   localDb!,
    //   // program: programName,
    //   // academicYear: academicYear,
    //   // branch: branch,
    //   // semester: semester,
    // );
    await LocalSection.insertAll(localDb!, jsonSections);
  }

  /// Get academic programs from client db.
  Future<List<Branches>> getBranchesFromLocal({
    required String programName,
  }) async {
    if (localDb == null) {
      return [];
    }

    return await LocalBranches.queryAll(
      localDb!,
      programName: programName,
    );
  }

  /// inserts all programs into sqlite db
  Future<void> insertBranchesToLocal(List<Branches> branches) async {
    if (localDb == null) {
      return;
    }

    // convert all to json
    List<Map> jsonBranches = [];
    for (var item in branches) {
      jsonBranches.add(item.toJson());
    }

    await LocalBranches.insertAll(localDb!, jsonBranches);
  }

  /// Fetch available schedule from local.
  Future<List<StudentSchedule>> getStudentScheduleFromLocal({
    required String programName,
    required String academicYear,
    required String branch,
    required String semester,
    required String section,
  }) async {
    if (localDb == null) {
      return [];
    }

    return await LocalStudentSchedule.queryAll(
      localDb!,
      program: programName,
      academicYear: academicYear,
      branch: branch,
      semester: semester,
      section: section,
    );
  }

  ///
  Future<void> insertStudentScheduleToLocal(
    List<StudentSchedule> schedule, {
    required String programName,
    required String academicYear,
    required String branch,
    required String semester,
    required String section,
  }) async {
    if (localDb == null) {
      return;
    }

    await LocalStudentSchedule.clearAll(
      localDb!,
      program: programName,
      academicYear: academicYear,
      branch: branch,
      semester: semester,
      section: section,
    );

    List<Map<String, dynamic>> jsonSchedule = [];
    for (var item in schedule) {
      jsonSchedule.add(item.toJson());
    }

    await LocalStudentSchedule.insertAll(localDb!, jsonSchedule);
  }
}
