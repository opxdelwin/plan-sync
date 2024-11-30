import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plan_sync/backend/models/supabase_models/academic_years.dart';
import 'package:plan_sync/controllers/auth.dart';
import 'package:plan_sync/util/local_database/db_wrapper.dart';
import 'package:plan_sync/util/local_database/tables/local_academic_years.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseProvider extends ChangeNotifier {
  Database? _localDb;
  set localDb(Database? db) {
    _localDb = db;
    notifyListeners();
  }

  Database? get localDb => _localDb;

  // Basically initialize the database for current user.
  Future<void> setupDatabase(BuildContext context) async {
    if (localDb != null) {
      await localDb!.close();
      localDb = null;
    }

    final auth = Provider.of<Auth>(context, listen: false);
    if (auth.activeUser == null) {
      return;
    }

    localDb = await openDatabase('plansync-local-db.db');
    await LocalDatabaseWrapper.createAllTables(localDb!);
    notifyListeners();
  }

  void close() async {
    await localDb?.close();
    localDb = null;
  }

  /// Get academic years from sqlite client db.
  /// Creates the table as well if it doesn't exists.
  Future<List<AcademicYear>> getYearsFromLocal() async {
    if (localDb == null) {
      return [];
    }

    return await LocalAcademicYears.queryAll(localDb!);
  }

  /// inserts all academic years into sqlite db
  Future<void> insertYearsToLocal(List<AcademicYear> academicYears) async {
    if (localDb == null) {
      return;
    }

    // convert all to json
    List<Map> jsonYears = [];
    for (var item in academicYears) {
      jsonYears.add(item.toJson());
    }

    await LocalAcademicYears.clearAll(localDb!);
    await LocalAcademicYears.insertAll(localDb!, jsonYears);
  }
}
