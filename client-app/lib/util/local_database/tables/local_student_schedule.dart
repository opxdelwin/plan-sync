import 'package:plan_sync/backend/supabase_models/student_schedule.dart';
import 'package:sqflite/sqflite.dart';

class LocalStudentSchedule {
  static Future<void> createTable(Database db) async {
    db.execute("""
        CREATE TABLE if not exists
        student_schedule (
            id INTEGER PRIMARY KEY AUTOINCREMENT, -- Equivalent to SERIAL/identity in PostgreSQL
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Timestamp with default value
            branch TEXT NOT NULL, -- Branch
            program TEXT NOT NULL, -- Program
            academic_year TEXT NOT NULL DEFAULT '', -- Academic year
            subject TEXT, -- Subject (nullable)
            start_time TEXT, -- Time (stored as TEXT in SQLite to handle "time without time zone")
            end_time TEXT, -- Time (stored as TEXT in SQLite to handle "time without time zone")
            classroom TEXT, -- Classroom (nullable)
            semester TEXT NOT NULL, -- Semester
            day TEXT NOT NULL, -- Day (can store `week_day` enum equivalent as TEXT in SQLite)
            authority TEXT NOT NULL, -- Authority
            section TEXT, -- Section (nullable),
            
            -- Foreign key constraints
            FOREIGN KEY (authority) REFERENCES allowed_domains (domain_name),
            FOREIGN KEY (
                section,
                branch,
                semester,
                program,
                academic_year,
                authority
            ) REFERENCES section (
                section_name,
                branch,
                semester_name,
                program,
                academic_year,
                authority
            ) ON UPDATE CASCADE ON DELETE CASCADE
        );
""");
    return;
  }

  static Future<List<StudentSchedule>> queryAll(
    Database db, {
    String? program,
    String? academicYear,
    String? branch,
    String? semester,
    String? section,
  }) async {
    String whereClause = 'WHERE 1=1';
    List<String> whereArgs = [];

    if (program != null) {
      whereClause += ' AND program = ?';
      whereArgs.add(program);
    }

    if (section != null) {
      whereClause += ' AND section = ?';
      whereArgs.add(section);
    }

    if (academicYear != null) {
      whereClause += ' AND academic_year = ?';
      whereArgs.add(academicYear);
    }

    if (branch != null) {
      whereClause += ' AND branch = ?';
      whereArgs.add(branch);
    }

    if (semester != null) {
      whereClause += ' AND semester = ?';
      whereArgs.add(semester);
    }

    String sql = 'SELECT * FROM student_schedule';
    if (whereClause.isNotEmpty) {
      sql += ' $whereClause';
    }
    sql += ' ORDER BY start_time asc';

    final response = await db.rawQuery(sql, whereArgs);
    return response.map((item) => StudentSchedule.fromJson(item)).toList();
  }

  static Future<void> clearAll(
    Database db, {
    String? program,
    String? academicYear,
    String? branch,
    String? semester,
    String? section,
  }) async {
    String whereClause = ' 1=1';
    List<String> whereArgs = [];

    if (program != null) {
      whereClause += ' AND program = ?';
      whereArgs.add(program);
    }

    if (academicYear != null) {
      whereClause += ' AND academic_year = ?';
      whereArgs.add(academicYear);
    }

    if (branch != null) {
      whereClause += ' AND branch = ?';
      whereArgs.add(branch);
    }

    if (section != null) {
      whereClause += ' AND section = ?';
      whereArgs.add(section);
    }

    if (semester != null) {
      whereClause += ' AND semester = ?';
      whereArgs.add(semester);
    }

    await db.delete(
      'student_schedule',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );
    return;
  }

  static Future<void> insertAll(
    Database db,
    List<Map<String, dynamic>> items,
  ) async {
    for (var item in items) {
      await db.insert(
        'student_schedule',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    // // TODO: removeme
    // db.rawQuery('select * from section').then((v) {
    //   print("DATA");
    //   print(v);
    //   print(v.length);
    // });
    return;
  }
}
