import 'package:plan_sync/backend/supabase_models/academic_years.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:sqflite/sqflite.dart';

class LocalAcademicYears {
  static Future<void> createTable(Database db) async {
    await db.execute("""
      create table if not exists
      academic_years (
      id INTEGER PRIMARY KEY AUTOINCREMENT, -- SQLite equivalent of SERIAL/identity columns
      created_at TEXT NOT NULL DEFAULT (datetime('now')), -- SQLite uses TEXT for timestamps with a default of the current time
      year TEXT NOT NULL UNIQUE -- UNIQUE constraint on the "year" column
      );

    """);
  }

  static Future<void> insertAll(Database db, List items) async {
    for (var item in items) {
      await db.insert('academic_years', item);
    }
    return;
  }

  static Future<List<AcademicYear>> queryAll(Database db) async {
    final res = await db.rawQuery(
      'select * from academic_years order by created_at desc',
    );
    List<AcademicYear> output = [];
    for (var item in res) {
      output.add(AcademicYear.fromJson(item));
    }
    return output;
  }

  static Future<void> clearAll(Database db) async {
    Logger.w('Clearing sqflite academic_years table!');
    await db.rawDelete('delete from academic_years;');
    return;
  }
}
