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
}
