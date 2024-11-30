import 'package:sqflite/sqflite.dart';

class LocalAllowedDomains {
  static Future<void> createTable(Database db) async {
    db.execute("""
    CREATE TABLE if not exists
    allowed_domains (
      id INTEGER PRIMARY KEY AUTOINCREMENT, -- Equivalent to SERIAL/identity in PostgreSQL
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Timestamp with default value
      domain_name TEXT NOT NULL UNIQUE -- Domain name with unique constraint
    );
    """);
  }
}
