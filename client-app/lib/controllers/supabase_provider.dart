import 'package:flutter/material.dart';
import 'package:plan_sync/backend/supabase_models/academic_years.dart';
import 'package:plan_sync/backend/supabase_models/branches.dart';
import 'package:plan_sync/backend/supabase_models/programs.dart';
import 'package:plan_sync/backend/supabase_models/section.dart';
import 'package:plan_sync/backend/supabase_models/semesters.dart';
import 'package:plan_sync/backend/supabase_models/student_schedule.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:plan_sync/util/wait_for_connectivity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProvider extends ChangeNotifier {
  Supabase? insatnce;

  Future<void> onInit() async {
    insatnce = Supabase.instance;
  }

  /// Fetch available academic years from supabase.
  Future<List<AcademicYear>?> getYearsFromRemote({
    bool exitIfNoInternet = false,
  }) async {
    if (insatnce == null) {
      Logger.e('getYearsFromRemote called without a valid supabase instance');
      return null;
    }

    bool hasInternet = await hasInternetConnection();

    if (!hasInternet && exitIfNoInternet) {
      return null;
    }

    await waitForInternetConnectivity();

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

  /// Fetch available programs from supabase.
  Future<List<Program>?> getProgramsFromRemote({
    bool exitIfNoInternet = false,
  }) async {
    if (insatnce == null) {
      Logger.e(
        'getProgramsFromRemote called without a valid supabase instance',
      );
      return null;
    }

    bool hasInternet = await hasInternetConnection();

    if (!hasInternet && exitIfNoInternet) {
      return null;
    }

    await waitForInternetConnectivity();

    final remoteResponse = await insatnce!.client.rest
        .from('programs')
        .select()
        .order('created_at');

    List<Program> output = [];
    for (var year in remoteResponse) {
      output.add(Program.fromJson(year));
    }
    return output;
  }

  /// Fetch available programs from supabase.
  Future<List<Branches>?> getBranchesFromRemote({
    required String programName,
    bool exitIfNoInternet = false,
  }) async {
    if (insatnce == null) {
      Logger.e(
          'getProgramsFromRemote called without a valid supabase instance');
      return null;
    }

    bool hasInternet = await hasInternetConnection();

    if (!hasInternet && exitIfNoInternet) {
      return null;
    }

    await waitForInternetConnectivity();

    final remoteResponse = await insatnce!.client.rest
        .from('branches')
        .select()
        .eq('program', programName)
        .order('branch_name');

    List<Branches> output = [];
    for (var year in remoteResponse) {
      output.add(Branches.fromJson(year));
    }
    return output;
  }

  /// Fetch available semesters from supabase.
  /// [programName] and [academicYear] are required to filter the semesters.
  Future<List<Semesters>?> getSemestersFromRemote({
    required String programName,
    required String academicYear,
    required String branchName,
    bool exitIfNoInternet = false,
  }) async {
    if (insatnce == null) {
      Logger.e(
          'getSemestersFromRemote called without a valid supabase instance');
      return null;
    }

    bool hasInternet = await hasInternetConnection();

    if (!hasInternet && exitIfNoInternet) {
      return null;
    }

    await waitForInternetConnectivity();

    final remoteResponse = await insatnce!.client.rest
        .from('semesters')
        .select()
        .eq('program_name', programName)
        .eq('academic_year', academicYear)
        .eq('branch_name', branchName)
        .order('created_at');

    List<Semesters> output = [];
    for (var semester in remoteResponse) {
      output.add(Semesters.fromJson(semester));
    }
    return output;
  }

  Future<List<Section>?> getSectionsFromRemote({
    required String programName,
    required String academicYear,
    required String branch,
    required String semester,
    bool exitIfNoInternet = false,
  }) async {
    if (insatnce == null) {
      Logger.e(
          'getSectionsFromRemote called without a valid supabase instance');
      return null;
    }

    bool hasInternet = await hasInternetConnection();

    if (!hasInternet && exitIfNoInternet) {
      return null;
    }

    await waitForInternetConnectivity();

    final remoteResponse = await insatnce!.client.rest
        .from('section')
        .select()
        .eq('program', programName)
        .eq('academic_year', academicYear)
        .eq('branch', branch)
        .eq('semester_name', semester)
        .order('section_name');

    List<Section> output = [];
    for (var section in remoteResponse) {
      output.add(Section.fromJson(section));
    }
    return output;
  }

  Future<List<StudentSchedule>?> getStudentSchedulesFromRemote({
    required String programName,
    required String academicYear,
    required String branch,
    required String semester,
    required String section,
    bool exitIfNoInternet = false,
  }) async {
    if (insatnce == null) {
      Logger.e(
        'getSchedulesFromRemote called without a valid supabase instance',
      );
      return null;
    }

    bool hasInternet = await hasInternetConnection();

    if (!hasInternet && exitIfNoInternet) {
      return null;
    }

    await waitForInternetConnectivity();

    final remoteResponse = await insatnce!.client.rest
        .from('student_schedule')
        .select()
        .eq('program', programName)
        .eq('academic_year', academicYear)
        .eq('branch', branch)
        .eq('semester', semester)
        .eq('section', section)
        .order('start_time', ascending: true);

    List<StudentSchedule> output = [];
    for (var schedule in remoteResponse) {
      output.add(StudentSchedule.fromJson(schedule));
    }
    return output;
  }
}
