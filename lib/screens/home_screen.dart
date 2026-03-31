import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/event_card.dart';
import 'add_event_screen.dart';
import 'event_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Event> _events = [];
  EventCategory? _selectedCategory;
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sortEvents();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final events = await StorageService.loadEvents();
    setState(() {
      _events = events;
      _isLoading = false;
    });
    _sortEvents();
  }

  void _sortEvents() {
    setState(() {
      _events.sort((a, b) {
        // Overdue items that are closest to now come first, then upcoming
        if (a.isOverdue && !b.isOverdue) return 1;
        if (!a.isOverdue && b.isOverdue) return -1;
        return a.dateTime.compareTo(b.dateTime);
      });
    });
  }

  List<Event> get _filteredEvents {
    if (_selectedCategory == null) return _events;
    return _events.where((e) => e.category == _selectedCategory).toList();
  }

  Future<void> _navigateToAddEvent() async {
    final result = await Navigator.push<Event>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEventScreen(
          onEventSaved: (event) {},
        ),
      ),
    );
    if (result != null) {
      setState(() => _events.add(result));
      _sortEvents();
      await StorageService.saveEvents(_events);
      if (result.reminderEnabled) {
        await NotificationService.scheduleEventReminder(result);
      }
    }
  }

  Future<void> _navigateToEditEvent(Event event) async {
    final result = await Navigator.push<Event>(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(event: event),
      ),
    );
    if (result != null) {
      final index = _events.indexWhere((e) => e.id == result.id);
      if (index != -1) {
        setState(() => _events[index] = result);
      }
      _sortEvents();
      await StorageService.saveEvents(_events);
      await NotificationService.cancelReminder(result.id);
      if (result.reminderEnabled) {
        await NotificationService.scheduleEventReminder(result);
      }
    }
  }

  Future<void> _deleteEvent(Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _events.removeWhere((e) => e.id == event.id));
      await StorageService.saveEvents(_events);
      await NotificationService.cancelReminder(event.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${event.title}" deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _filteredEvents;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Countdown',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    isDarkMode: widget.isDarkMode,
                    onToggleTheme: widget.onToggleTheme,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCategoryFilter(),
                _buildStatsRow(),
                Expanded(
                  child: filteredEvents.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadEvents,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 80),
                            itemCount: filteredEvents.length,
                            itemBuilder: (context, index) {
                              final event = filteredEvents[index];
                              return EventCard(
                                event: event,
                                onTap: () => _navigateToEditEvent(event),
                                onDelete: () => _deleteEvent(event),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddEvent,
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
        elevation: 4,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildFilterChip(null, 'All', Icons.grid_view_rounded),
          ...EventCategory.values.map(
            (cat) => _buildFilterChip(
              cat,
              cat.label,
              IconData(cat.iconCode, fontFamily: 'MaterialIcons'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(EventCategory? category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    final color = category != null
        ? Color(int.parse(category.colorHex.replaceFirst('#', '0xFF')))
        : Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        onSelected: (_) {
          setState(() {
            _selectedCategory = isSelected ? null : category;
          });
        },
        selectedColor: color,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final total = _events.length;
    final upcoming = _events.where((e) => !e.isOverdue).length;
    final overdue = _events.where((e) => e.isOverdue).length;
    final today = _events.where((e) => e.isToday).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatChip('$total', 'Total', Colors.blue),
          _buildStatChip('$upcoming', 'Upcoming', Colors.green),
          _buildStatChip('$today', 'Today', Colors.orange),
          if (overdue > 0) _buildStatChip('$overdue', 'Overdue', Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedCategory != null
                ? 'No ${_selectedCategory!.label} events'
                : 'No events yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first event',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}
