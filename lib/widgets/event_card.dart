import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onDelete,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _getCategoryColor() {
    return Color(
      int.parse(widget.event.category.colorHex.replaceFirst('#', '0xFF')),
    );
  }

  IconData _getCategoryIcon() {
    return IconData(widget.event.category.iconCode, fontFamily: 'MaterialIcons');
  }

  String _getCountdownText() {
    final remaining = widget.event.timeRemaining;
    if (remaining.isNegative) {
      final ago = -remaining;
      if (ago.inDays > 0) return '${ago.inDays}d ago';
      if (ago.inHours > 0) return '${ago.inHours}h ago';
      return '${ago.inMinutes}m ago';
    }
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h ${remaining.inMinutes % 60}m';
    }
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m ${remaining.inSeconds % 60}s';
    }
    return '${remaining.inMinutes}m ${remaining.inSeconds % 60}s';
  }

  String _getStatusLabel() {
    if (widget.event.isOverdue) return 'Overdue';
    if (widget.event.isToday) return 'Today';
    if (widget.event.isTomorrow) return 'Tomorrow';
    return '';
  }

  Color _getStatusColor() {
    if (widget.event.isOverdue) return Colors.red;
    if (widget.event.isToday) return Colors.orange;
    if (widget.event.isTomorrow) return Colors.blue;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoryColor = _getCategoryColor();
    final statusLabel = _getStatusLabel();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: categoryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.event.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: widget.event.isOverdue
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (statusLabel.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: _getStatusColor(),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.event.category.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          widget.event.isOverdue
                              ? Icons.warning_amber_rounded
                              : Icons.timer_outlined,
                          size: 14,
                          color: widget.event.isOverdue
                              ? Colors.red
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getCountdownText(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: widget.event.isOverdue
                                ? Colors.red
                                : (isDark ? Colors.grey[300] : Colors.grey[700]),
                            fontWeight: FontWeight.w500,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const Spacer(),
                        if (widget.event.reminderEnabled)
                          Icon(
                            Icons.notifications_active_outlined,
                            size: 16,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.onDelete != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: widget.onDelete,
                  splashRadius: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
