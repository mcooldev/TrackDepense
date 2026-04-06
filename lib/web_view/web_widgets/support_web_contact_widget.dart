import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SupportWebContactWidget extends StatelessWidget {
  const SupportWebContactWidget({
    super.key, required this.iconData, required this.label, required this.content,
  });

  final List<List<dynamic>> iconData;
  final String label;
  final String content;


  @override
  Widget build(BuildContext context) {
    ///
    final theme = Theme.of(context);

    ///
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // icon phone
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.grey.shade100,
          child: HugeIcon(
            icon: iconData,
            color: Colors.grey.shade400,
            size: 32,
          ),
        ),
        const SizedBox(height: 12),

        // label
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        // agent name
        Text(
          content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
