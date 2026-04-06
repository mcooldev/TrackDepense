import 'package:flutter/material.dart';

class BuildStatCard extends StatelessWidget {
  const BuildStatCard({
    super.key,
    required this.cardTitle,
    required this.cardData,
  });

  final String cardTitle, cardData;

  @override
  Widget build(BuildContext context) {
    //
    final theme = Theme.of(context);
    //
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // card title
            Flexible(child: Text(cardTitle, style: theme.textTheme.bodyLarge)),
            const SizedBox(height: 4),
            // card data
            Flexible(
              child: Text(
                cardData,
                style: theme.textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
