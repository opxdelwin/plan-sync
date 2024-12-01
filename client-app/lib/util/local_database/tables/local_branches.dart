import 'package:plan_sync/backend/supabase_models/branches.dart';
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

  static Future<List<Branches>> queryAll(
    Database db, {
    String? programName,
  }) async {
    String whereClause = '';
    List<String> whereArgs = [];

    if (programName != null) {
      whereClause += 'program = ?';
      whereArgs.add(programName);
    }

    String sql = 'SELECT * FROM branches';
    if (whereClause.isNotEmpty) {
      sql += ' WHERE $whereClause';
    }
    // order by clause
    sql += ' ORDER BY branch_name asc';

    final response = await db.rawQuery(sql, whereArgs);

    List<Branches> branches =
        response.map((e) => Branches.fromJson(e)).toList();
    return branches;
  }

  static Future<void> clearAll(
    Database db, {
    String? programName,
  }) async {
    String whereClause = '';
    List<String> whereArgs = [];

    if (programName != null) {
      whereClause += 'program_name = ?';
      whereArgs.add(programName);
    }

    await db.delete(
      'branches',
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
        'branches',
        item,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    return;
  }
}
