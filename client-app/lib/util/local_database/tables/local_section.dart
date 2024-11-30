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
          UNIQUE (branch, semester_name, program, academic_year, authority), -- Composite unique constraint
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
}
