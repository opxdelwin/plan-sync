import 'package:flutter/material.dart';
import 'package:plan_sync/views/campus_navigator/models/campus_navigation_model.dart';

class CampusLocationCard extends StatelessWidget {
  final CampusNavigationModel item;
  final ColorScheme colorScheme;
  final VoidCallback onLaunch;

  const CampusLocationCard({
    super.key,
    required this.item,
    required this.colorScheme,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline,
          width: 1.5,
        ),
      ),
      leading: item.imagePath != null
          ? Image.network(
              item.imagePath!,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            )
          : Icon(
              Icons.location_on,
              color: colorScheme.primary,
            ),
      title: Text(
        item.title ?? 'No Title',
        style: TextStyle(color: colorScheme.onSurface),
      ),
      trailing: IconButton(
        icon: Icon(Icons.launch, color: colorScheme.secondary),
        onPressed: onLaunch,
      ),
    );
  }
}
