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
}
