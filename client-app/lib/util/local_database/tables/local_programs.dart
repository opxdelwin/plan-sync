import 'package:plan_sync/backend/supabase_models/programs.dart';
import 'package:sqflite/sqflite.dart';

class LocalPrograms {
  static Future<void> createTable(Database db) async {
    db.execute("""
    CREATE TABLE if not exists
    programs (
      id INTEGER PRIMARY KEY AUTOINCREMENT, -- Equivalent to SERIAL/identity in PostgreSQL
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Timestamp with default value
      name TEXT NOT NULL UNIQUE, -- Unique constraint on the program name
      authority TEXT NOT NULL DEFAULT '', -- Default value for authority
      -- Foreign key constraint
      FOREIGN KEY (authority) REFERENCES allowed_domains (domain_name)
    );
    """);
    return;
  }

  /// query all items from the table.
  static Future<List<Program>> queryAll(Database db) async {
    final response = await db.rawQuery(
      'select * from programs order by created_at desc',
    );
    List<Program> output = [];
    for (var item in response) {
      output.add(Program.fromJson(item));
    }

    return output;
  }

  /// Delete all items from table.
  static Future<void> clearAll(Database db) async {
    await db.rawDelete('delete from programs;');
    return;
  }

  /// Insert all items into the table.
  /// This is a batch insert operation.
  static Future<void> insertAll(Database db, List items) async {
    for (var item in items) {
      await db.insert('programs', item);
    }
    return;
  }
}
