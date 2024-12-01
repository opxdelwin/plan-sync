import 'package:plan_sync/util/local_database/tables/local_academic_years.dart';
import 'package:plan_sync/util/local_database/tables/local_allowed_domains.dart';
import 'package:plan_sync/util/local_database/tables/local_branches.dart';
import 'package:plan_sync/util/local_database/tables/local_programs.dart';
import 'package:plan_sync/util/local_database/tables/local_section.dart';
import 'package:plan_sync/util/local_database/tables/local_semesters.dart';
import 'package:plan_sync/util/local_database/tables/local_student_schedule.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseWrapper {
  /// Instantiate all the tables, if they do
  /// not exist already
  static Future<void> createAllTables(Database db) async {
    await LocalAllowedDomains.createTable(db);
    await LocalPrograms.createTable(db);
    await LocalBranches.createTable(db);
    await LocalSemesters.createTable(db);
    await LocalSection.createTable(db);
    await LocalStudentSchedule.createTable(db);
    await LocalAcademicYears.createTable(db);
    await insertUserDomainToAllowedDomains(db);
  }

  static Future<void> insertUserDomainToAllowedDomains(Database db) async {
    await db.rawQuery(
      'INSERT INTO allowed_domains (domain_name) VALUES ("kiit.ac.in") on conflict do nothing',
    );
  }
}
