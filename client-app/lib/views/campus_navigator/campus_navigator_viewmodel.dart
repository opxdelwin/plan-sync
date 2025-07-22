import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:plan_sync/views/campus_navigator/models/campus_navigation_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CampusNavigatorViewModel extends ChangeNotifier {
  final List<CampusNavigationModel> _items = [];
  List<CampusNavigationModel> get items => _items;

  bool isLoading = false;
  bool hasMore = true;
  int _page = 0;
  String _search = '';
  static const int _limit = 20;

  CampusNavigatorViewModel() {
    fetchItems(reset: true);
  }

  void onSearchChanged(String value) {
    EasyDebounce.debounce(
      'campusNavigatorSearch',
      const Duration(milliseconds: 300),
      () {
        _search = value;
        fetchItems(reset: true);
      },
    );
  }

  Future<void> fetchItems({bool reset = false}) async {
    if (isLoading) return;
    isLoading = true;
    if (reset) {
      _items.clear();
      _page = 0;
      hasMore = true;
    }
    notifyListeners();
    final supabase = Supabase.instance.client;
    var queryBuilder = supabase.from('campus_navigation').select();

    if (_search.isNotEmpty) {
      queryBuilder = queryBuilder.ilike('title', '%$_search%');
    }

    final query = queryBuilder
        .order('title', ascending: true)
        .range(_page * _limit, (_page + 1) * _limit - 1);

    final data = await query;
    final List<CampusNavigationModel> fetched = (data as List)
        .map(
          (e) => CampusNavigationModel.fromJson(e),
        )
        .toList();
    if (fetched.length < _limit) {
      hasMore = false;
    }
    _items.addAll(fetched);
    isLoading = false;
    notifyListeners();
  }

  void fetchNextPage() {
    if (!hasMore || isLoading) return;
    _page++;
    fetchItems();
  }

  Future<void> launchMaps({
    String? url,
    required BuildContext context,
  }) async {
    if (url == null || url.isEmpty) {
      CustomSnackbar.error(
        'Navigation Launch Failed',
        'The nav link was not found.',
        context,
      );
      return;
    }
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }
}
