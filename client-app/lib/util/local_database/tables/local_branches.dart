import 'package:sqflite/sqflite.dart';

class LocalBranches {
  static Future<void> createTable(Database db) async {
    db.execute("""
    CREATE TABLE if not exists
    branches (
        id INTEGER PRIMARY KEY AUTOINCREMENT, -- Equivalent to SERIAL/identity in PostgreSQL
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Timestamp with default value
        branch_name TEXT NOT NULL, -- Name of the branch
        program TEXT NOT NULL, -- Program associated with the branch
        authority TEXT NOT NULL, -- Authority associated with the branch
        -- Unique constraint on branch_name and program
        UNIQUE (branch_name, program),
        -- Foreign key constraints
        FOREIGN KEY (authority) REFERENCES allowed_domains (domain_name),
        FOREIGN KEY (program) REFERENCES programs (name) ON UPDATE CASCADE ON DELETE CASCADE
    );
""");
    return;
  }
}
