import 'package:flutter/material.dart';

class SubjectTile extends StatelessWidget {
  const SubjectTile({
    super.key,
    required this.subject,
    required this.location,
    required this.time,
  });

  final String subject;
  final String location;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(strokeAlign: 2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined),
                    const SizedBox(width: 8),
                    Text(location),
                  ],
                )
              ],
            ),
            const Spacer(),
            Text(time),
          ],
        ),
      ),
    );
  }
}
