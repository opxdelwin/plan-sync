import 'package:flutter/material.dart';
import 'package:plan_sync/views/campus_navigator/widgets/empty_campus_widget.dart';
import 'package:plan_sync/views/campus_navigator/widgets/tile.dart';
import 'package:provider/provider.dart';
import 'campus_navigator_viewmodel.dart';

class CampusNavigatorView extends StatelessWidget {
  const CampusNavigatorView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ChangeNotifierProvider(
      create: (_) => CampusNavigatorViewModel(),
      child: Consumer<CampusNavigatorViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: colorScheme.surfaceContainerHighest,
              elevation: 0.0,
              toolbarHeight: 80,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              title: Text(
                "Campus Navigator",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              centerTitle: false,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent &&
                            !viewModel.isLoading &&
                            viewModel.hasMore) {
                          viewModel.fetchNextPage();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        itemCount: 1 +
                            (viewModel.items.isEmpty && !viewModel.isLoading
                                ? 1
                                : viewModel.items.length) +
                            (viewModel.isLoading ? 1 : 0),
                        separatorBuilder: (context, index) {
                          // Don't show separator after search bar or after last item
                          if (index == viewModel.items.length) {
                            return const SizedBox.shrink();
                          }
                          return const SizedBox(height: 12);
                        },
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Container(
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: colorScheme.outline.withAlpha(128),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.only(
                                top: 8,
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Search Campus Locations',
                                  hintStyle: TextStyle(
                                    color: colorScheme.onSurface,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: colorScheme.onSurface,
                                  ),
                                  border: InputBorder.none,
                                ),
                                onChanged: viewModel.onSearchChanged,
                              ),
                            );
                          }
                          if (viewModel.items.isEmpty &&
                              !viewModel.isLoading &&
                              index == 1) {
                            return Column(
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                ),
                                EmptyCampusWidget(),
                              ],
                            );
                          }
                          if (viewModel.isLoading &&
                              index ==
                                  (1 +
                                      (viewModel.items.isEmpty &&
                                              !viewModel.isLoading
                                          ? 1
                                          : viewModel.items.length))) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (index > 0 && index <= viewModel.items.length) {
                            final item = viewModel.items[index - 1];
                            return CampusLocationCard(
                              item: item,
                              colorScheme: colorScheme,
                              onLaunch: () => viewModel.launchMaps(
                                url: item.mapsLink,
                                context: context,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
