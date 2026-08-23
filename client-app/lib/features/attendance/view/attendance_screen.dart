import 'package:flutter/material.dart';
import 'package:plan_sync/features/attendance/view/widgets/attendance_error_state.dart';
import 'package:plan_sync/features/attendance/view/widgets/attendance_loading_state.dart';
import 'package:plan_sync/features/attendance/view/widgets/attendance_needs_credentials.dart';
import 'package:plan_sync/features/attendance/view/widgets/attendance_period_picker.dart';
import 'package:plan_sync/features/attendance/view/widgets/attendance_restoring_state.dart';
import 'package:plan_sync/features/attendance/view/widgets/attendance_preference_dialog.dart';
import 'package:plan_sync/features/attendance/view/widgets/attendance_success_state.dart';
import 'package:plan_sync/features/attendance/viewmodel/attendance_view_model.dart';
import 'package:provider/provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceViewModel>().ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.98),
        elevation: 0.0,
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        title: Text(
          'Plan Sync',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          Consumer<AttendanceViewModel>(
            builder: (context, viewModel, _) {
              final id = viewModel.registrationNumber;
              if (id == null || id.isEmpty) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The period selector belongs to attendance that's actually
                  // on screen; while the picker is up it would claim a period
                  // the body is still asking for. Fall back to the ID badge.
                  if (viewModel.status == AttendanceStatus.success &&
                      viewModel.result != null)
                    AttendancePreferenceButton(viewModel: viewModel)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ID · $id',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  IconButton(
                    tooltip: 'Log out of KIIT portal',
                    onPressed: () => _logoutSap(context, viewModel),
                    icon: Icon(Icons.logout_rounded, color: colorScheme.error),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AttendanceViewModel>(
        builder: (context, viewModel, _) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: KeyedSubtree(
            key: ValueKey('${viewModel.status.name}:${viewModel.result == null}'),
            child: _contentFor(viewModel),
          ),
        ),
      ),
    );
  }

  Future<void> _logoutSap(
    BuildContext context,
    AttendanceViewModel viewModel,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainerHighest,
        title: Text(
          'Log out of KIIT portal?',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          'Your saved registration number and password will be removed '
          'from this device.',
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Log out',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await viewModel.disconnect();
    }
  }

  Widget _contentFor(AttendanceViewModel viewModel) {
    switch (viewModel.status) {
      case AttendanceStatus.needsCredentials:
        return AttendanceNeedsCredentials(viewModel: viewModel);
      case AttendanceStatus.restoring:
        return AttendanceRestoringState(viewModel: viewModel);
      case AttendanceStatus.loading:
        return AttendanceLoadingState(viewModel: viewModel);
      case AttendanceStatus.error:
        return AttendanceErrorState(viewModel: viewModel);
      case AttendanceStatus.idle:
        // Connected but nothing fetched yet — let the user pick a period.
        return AttendancePeriodPicker(viewModel: viewModel);
      case AttendanceStatus.success:
        if (viewModel.result == null) {
          return AttendancePeriodPicker(viewModel: viewModel);
        }
        return AttendanceSuccessState(viewModel: viewModel);
    }
  }
}
