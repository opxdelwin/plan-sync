import 'package:plan_sync/util/local_database/tables/local_academic_years.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseWrapper {
  /// Instantiate all the tables, if they do
  /// not exist already
  static Future<void> createAllTables(Database db) async {
    await LocalAcademicYears.createTable(db);
  }
}
