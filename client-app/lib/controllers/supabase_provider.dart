import 'package:flutter/material.dart';
import 'package:plan_sync/backend/models/supabase_models/academic_years.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProvider extends ChangeNotifier {
  Supabase? insatnce;

  Future<void> onInit() async {
    insatnce = Supabase.instance;
  }

  /// Fetch available academic years from supabase.
  Future<List<AcademicYear>> getYearsFromRemote() async {
    if (insatnce == null) {
      Logger.e('getYearsFromRemote called without a valid supabase instance');
      return [];
    }

    final remoteResponse = await insatnce!.client.rest
        .from('academic_years')
        .select()
        .order('created_at');

    List<AcademicYear> output = [];
    for (var year in remoteResponse) {
      output.add(AcademicYear.fromJson(year));
    }
    return output;
  }
}
