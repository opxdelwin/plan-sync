import 'package:plan_sync/backend/supabase_models/semesters.dart';
import 'package:sqflite/sqflite.dart';

class LocalSemesters {
  static Future<void> createTable(Database db) async {
    await db.execute("""
    CREATE TABLE if not exists
    semesters (
        id INTEGER PRIMARY KEY AUTOINCREMENT, -- Equivalent to SERIAL/identity in PostgreSQL
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Timestamp with default value
        semester_name TEXT NOT NULL,
        branch_name TEXT NOT NULL,
        program_name TEXT NOT NULL,
        academic_year TEXT NOT NULL,
        authority TEXT NOT NULL,
        
        -- Unique constraints
        UNIQUE (id, branch_name, program_name, academic_year),
        UNIQUE (semester_name, branch_name, program_name, academic_year, authority),
        
        -- Foreign key constraints
        FOREIGN KEY (academic_year) REFERENCES academic_years (year) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY (authority) REFERENCES allowed_domains (domain_name),
        FOREIGN KEY (branch_name, program_name) REFERENCES branches (branch_name, program) ON UPDATE CASCADE ON DELETE CASCADE
    );
    """);
    return;
  }

  static Future<List<Semesters>> queryAll(
    Database db, {
    String? programName,
    String? academicYear,
    String? branchName,
  }) async {
    String whereClause = '';
    List<String> whereArgs = [];

    if (programName != null) {
      whereClause += 'program_name = ?';
      whereArgs.add(programName);
    }

    if (academicYear != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'academic_year = ?';
      whereArgs.add(academicYear);
    }

    if (branchName != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'branch_name = ?';
      whereArgs.add(branchName);
    }

    String sql = 'SELECT * FROM semesters';
    if (whereClause.isNotEmpty) {
      sql += ' WHERE $whereClause';
    }
    // order by clause
    sql += ' ORDER BY created_at desc';

    final response = await db.rawQuery(sql, whereArgs);

    List<Semesters> semesters =
        response.map((e) => Semesters.fromJson(e)).toList();
    return semesters;
  }

  static Future<void> clearAll(
    Database db, {
    String? programName,
    String? academicYear,
    String? branchName,
  }) async {
    String whereClause = '';
    List<String> whereArgs = [];

    if (programName != null) {
      whereClause += 'program_name = ?';
      whereArgs.add(programName);
    }

    if (academicYear != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'academic_year = ?';
      whereArgs.add(academicYear);
    }

    if (branchName != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'branch_name = ?';
      whereArgs.add(branchName);
    }

    await db.delete(
      'semesters',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );
  }

  static Future<void> insertAll(
    Database db,
    List items,
  ) async {
    for (var item in items) {
      await db.insert(
        'semesters',
        item,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    return;
  }
}
