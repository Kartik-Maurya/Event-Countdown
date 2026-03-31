import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import 'add_event_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late Event _event;
  Timer? _timer;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Color _getCategoryColor() {
    return Color(
      int.parse(_event.category.colorHex.replaceFirst('#', '0xFF')),
    );
  }

  String _getCountdownText() {
    final remaining = _event.timeRemaining;
    if (remaining.isNegative) {
      return 'Event has passed';
    }
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    return '${days}d ${hours}h ${minutes}m ${seconds}s';
  }

  List<String> _getCountdownParts() {
    final remaining = _event.timeRemaining;
    if (remaining.isNegative) {
      return ['00', '00', '00', '00'];
    }
    return [
      remaining.inDays.toString().padLeft(2, '0'),
      (remaining.inHours % 24).toString().padLeft(2, '0'),
      (remaining.inMinutes % 60).toString().padLeft(2, '0'),
      (remaining.inSeconds % 60).toString().padLeft(2, '0'),
    ];
  }

  void _editEvent() async {
    if (!mounted) return;
    final result = await Navigator.push<Event>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEventScreen(
          existingEvent: _event,
          onEventSaved: (e) {},
        ),
      ),
    );
    if (result != null) {
      setState(() => _event = result);
      if (mounted) {
        Navigator.pop(context, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoryColor = _getCategoryColor();
    final parts = _getCountdownParts();
    final labels = ['Days', 'Hours', 'Mins', 'Secs'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: _editEvent,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            onPressed: () => Navigator.pop(context, null),
            tooltip: 'Delete from Home',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconData(_event.category.iconCode,
                        fontFamily: 'MaterialIcons'),
                    color: categoryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _event.category.label,
                    style: TextStyle(
                      color: categoryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              _event.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Date & Time
            Text(
              DateFormat('EEEE, MMMM d, yyyy  ·  h:mm a')
                  .format(_event.dateTime),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Countdown display
            if (!_event.isOverdue) ...[
              Text(
                'Countdown',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _animController,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 72,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              parts[i],
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: categoryColor,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              labels[i],
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.warning_rounded,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'This event has passed',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCountdownText(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Description
            if (_event.description.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Description',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _event.description,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Info cards
            _buildInfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Date',
              value: DateFormat('MMM d, yyyy').format(_event.dateTime),
              theme: theme,
            ),
            _buildInfoRow(
              icon: Icons.access_time_rounded,
              label: 'Time',
              value: DateFormat('h:mm a').format(_event.dateTime),
              theme: theme,
            ),
            _buildInfoRow(
              icon: _event.reminderEnabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_outlined,
              label: 'Reminder',
              value: _event.reminderEnabled ? 'Enabled' : 'Disabled',
              theme: theme,
            ),
            if (_event.reminderEnabled)
              _buildInfoRow(
                icon: Icons.alarm_rounded,
                label: 'Remind',
                value: _formatReminderTime(_event.reminderMinutesBefore),
                theme: theme,
              ),
          ],
        ),
      ),
    );
  }

  String _formatReminderTime(int minutes) {
    if (minutes == 0) return 'At time of event';
    if (minutes < 60) return '$minutes minutes before';
    if (minutes < 1440) return '${minutes ~/ 60} hour(s) before';
    return '${minutes ~/ 1440} day(s) before';
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
