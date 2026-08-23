import 'package:flutter/material.dart';
import 'package:plan_sync/features/attendance/viewmodel/attendance_view_model.dart';

/// Shown once the KIIT portal is connected but nothing has been fetched yet
/// (status == idle, result == null). The user picks the academic year and
/// session here and taps "Load attendance" to trigger the scrape — nothing is
/// fetched automatically.
class AttendancePeriodPicker extends StatefulWidget {
  const AttendancePeriodPicker({super.key, required this.viewModel});

  final AttendanceViewModel viewModel;

  @override
  State<AttendancePeriodPicker> createState() => _AttendancePeriodPickerState();
}

class _AttendancePeriodPickerState extends State<AttendancePeriodPicker> {
  late String _year = widget.viewModel.academicYear;
  late String _session = widget.viewModel.session;
  String? _error;

  /// Acknowledges the tap in the same frame; the view model's state change
  /// lands a frame later.
  bool _busy = false;

  Future<void> _load() async {
    if (_busy) return;
    // Block future periods (e.g. 2027-2028, or Spring of the current year
    // before January) — there can be no attendance for a session that hasn't
    // begun. Past/current periods pass through.
    if (!AttendanceViewModel.periodHasStarted(_year, _session)) {
      setState(() => _error =
          "The $_session $_year session hasn't started yet. "
          'Pick an earlier year or session.');
      return;
    }
    setState(() => _busy = true);
    widget.viewModel.changeSelection(year: _year, session: _session);
    try {
      await widget.viewModel.applySelection();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final id = widget.viewModel.registrationNumber;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 112),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 64,
              color: colorScheme.primary.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 18),
            Text(
              'Pick a period',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              id != null && id.isNotEmpty
                  ? 'Choose the academic year and session, then load your '
                      'attendance for $id.'
                  : 'Choose the academic year and session, then load your '
                      'attendance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            _PickerRow(
              icon: Icons.calendar_today_outlined,
              label: 'Academic Year',
              colorScheme: colorScheme,
              child: _PillDropdown<String>(
                value: _year,
                items: widget.viewModel.yearOptions,
                colorScheme: colorScheme,
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _year = v;
                      _error = null;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            _PickerRow(
              icon: Icons.wb_sunny_outlined,
              label: 'Session',
              colorScheme: colorScheme,
              child: _PillDropdown<String>(
                value: _session,
                items: widget.viewModel.sessionOptions,
                colorScheme: colorScheme,
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _session = v;
                      _error = null;
                    });
                  }
                },
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _load,
                icon: _busy
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.download_rounded),
                label: Text(_busy ? 'Checking saved copy…' : 'Load attendance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.45),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A copy saved on this device loads instantly. Otherwise we '
                    'sign in to the KIIT portal, which can take up to a minute.',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.icon,
    required this.label,
    required this.child,
    required this.colorScheme,
  });

  final IconData icon;
  final String label;
  final Widget child;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: colorScheme.onSurface, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: colorScheme.onSurface),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        child,
      ],
    );
  }
}

class _PillDropdown<T> extends StatelessWidget {
  const _PillDropdown({
    required this.value,
    required this.items,
    required this.colorScheme,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final ColorScheme colorScheme;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: colorScheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: 136,
        height: 44,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            elevation: 0,
            style: TextStyle(color: colorScheme.surface, fontSize: 13),
            icon: Icon(Icons.arrow_drop_down, color: colorScheme.surface),
            value: value,
            dropdownColor: colorScheme.onSurface,
            menuMaxHeight: 280,
            items: items
                .map((e) => DropdownMenuItem<T>(
                      value: e,
                      child: Text(
                        e.toString(),
                        style: TextStyle(color: colorScheme.surface),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
