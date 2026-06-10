import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_typography.dart';

enum TimelineNodeState { paid, due, active }

class PaymentTimelineEntry {
  const PaymentTimelineEntry({
    required this.title,
    this.subtitle,
    this.trailing,
    this.state = TimelineNodeState.due,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final TimelineNodeState state;
}

/// Vertical payment timeline (`.tl`): nodes joined by a hairline,
/// filled for paid, outlined for due, brand ring for active.
class PaymentTimeline extends StatelessWidget {
  const PaymentTimeline({super.key, required this.entries});

  final List<PaymentTimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineRow(
            entry: entries[i],
            isLast: i == entries.length - 1,
            colors: colors,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.entry,
    required this.isLast,
    required this.colors,
  });

  final PaymentTimelineEntry entry;
  final bool isLast;
  final AbragColors colors;

  @override
  Widget build(BuildContext context) {
    final (Color fill, Color ring) = switch (entry.state) {
      TimelineNodeState.paid => (colors.ok, colors.ok),
      TimelineNodeState.due => (Colors.transparent, colors.ink3),
      TimelineNodeState.active => (colors.surface, colors.brand),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: fill,
                    shape: BoxShape.circle,
                    border: Border.all(color: ring, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: colors.border),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style:
                              AppTextStyles.title.copyWith(color: colors.ink),
                        ),
                        if (entry.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            entry.subtitle!,
                            style: AppTextStyles.caption
                                .copyWith(color: colors.ink3),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (entry.trailing != null) entry.trailing!,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
