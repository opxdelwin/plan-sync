import 'package:plan_sync/backend/supabase_models/section.dart';
import 'package:sqflite/sqflite.dart';

class LocalSection {
  static Future<void> createTable(Database db) async {
    db.execute("""
      CREATE TABLE if not exists
      section (
          id INTEGER PRIMARY KEY AUTOINCREMENT, -- Equivalent to SERIAL/identity in PostgreSQL
          created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Timestamp with default value
          section_name TEXT NOT NULL, -- Section name
          semester_name TEXT NOT NULL, -- Semester name
          branch TEXT NOT NULL, -- Branch
          program TEXT NOT NULL, -- Program
          academic_year TEXT NOT NULL, -- Academic year
          authority TEXT, -- Authority (nullable)
          
          -- Composite unique constraints

          -- Removed on unique condition as postgres can enforce
          -- multiple unique conditions on overlapping columns,
          -- but SQLite can't.
          
          UNIQUE (section_name, branch, semester_name, program, academic_year, authority), -- Composite unique constraint
          
          -- Foreign key constraint
          FOREIGN KEY (
              semester_name,
              branch,
              program,
              academic_year,
              authority
          ) REFERENCES semesters (
              semester_name,
              branch_name,
              program_name,
              academic_year,
              authority
          ) ON UPDATE CASCADE ON DELETE CASCADE
      );
  """);
    return;
  }

  /// Query all items from the table based on the given parameters.
  static Future<List<Section>> queryAll(
    Database db, {
    String? program,
    String? branch,
    String? semester,
    String? academicYear,
  }) async {
    String query = 'SELECT * FROM section WHERE 1=1';
    List<String> params = [];

    if (program != null) {
      query += ' AND program = ?';
      params.add(program);
    }
    if (branch != null) {
      query += ' AND branch = ?';
      params.add(branch);
    }
    if (semester != null) {
      query += ' AND semester_name = ?';
      params.add(semester);
    }
    if (academicYear != null) {
      query += ' AND academic_year = ?';
      params.add(academicYear);
    }

    query += ' ORDER BY section_name ASC';

    final response = await db.rawQuery(query, params);
    List<Section> output = [];
    for (var item in response) {
      output.add(Section.fromJson(item));
    }
    return output;
  }

  /// Delete all items from the table based on the given parameters.
  static Future<void> clearAll(
    Database db, {
    String? program,
    String? branch,
    String? semester,
    String? academicYear,
  }) async {
    String query = 'DELETE FROM section WHERE 1=1';
    List<dynamic> params = [];

    if (program != null) {
      query += ' AND program = ?';
      params.add(program);
    }
    if (branch != null) {
      query += ' AND branch = ?';
      params.add(branch);
    }
    if (semester != null) {
      query += ' AND semester_name = ?';
      params.add(semester);
    }
    if (academicYear != null) {
      query += ' AND academic_year = ?';
      params.add(academicYear);
    }

    await db.rawDelete(query, params);
    return;
  }

  /// Insert all items into the table.
  /// This is a batch insert operation.
  static Future<void> insertAll(
    Database db,
    List items,
  ) async {
    for (var item in items) {
      await db.insert(
        'section',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return;
  }
}
