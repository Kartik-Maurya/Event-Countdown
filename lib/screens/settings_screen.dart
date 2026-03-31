import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _defaultReminderMinutes = 1440;

  final List<Map<String, dynamic>> _reminderOptions = [
    {'label': 'At time of event', 'minutes': 0},
    {'label': '5 minutes before', 'minutes': 5},
    {'label': '15 minutes before', 'minutes': 15},
    {'label': '30 minutes before', 'minutes': 30},
    {'label': '1 hour before', 'minutes': 60},
    {'label': '2 hours before', 'minutes': 120},
    {'label': '1 day before', 'minutes': 1440},
    {'label': '2 days before', 'minutes': 2880},
    {'label': '1 week before', 'minutes': 10080},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final minutes = await StorageService.getDefaultReminderMinutes();
    setState(() => _defaultReminderMinutes = minutes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Appearance',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(widget.isDarkMode ? 'Dark theme' : 'Light theme'),
            secondary: Icon(
              widget.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            ),
            value: widget.isDarkMode,
            onChanged: (_) => widget.onToggleTheme(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Notifications',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Default Reminder Time'),
            subtitle: Text(
              _reminderOptions
                  .firstWhere(
                    (o) => o['minutes'] == _defaultReminderMinutes,
                    orElse: () => _reminderOptions.first,
                  )['label'],
            ),
            leading: const Icon(Icons.alarm_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<int>(
              initialValue: _defaultReminderMinutes,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _reminderOptions.map((opt) {
                return DropdownMenuItem(
                  value: opt['minutes'] as int,
                  child: Text(opt['label'] as String),
                );
              }).toList(),
              onChanged: (value) async {
                if (value != null) {
                  setState(() => _defaultReminderMinutes = value);
                  await StorageService.setDefaultReminderMinutes(value);
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'About',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Event Countdown & Reminder Board'),
            subtitle: const Text('Version 1.0.0'),
            leading: const Icon(Icons.info_outline_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          ListTile(
            title: const Text('Data stored locally'),
            subtitle: const Text('All events are saved on your device'),
            leading: const Icon(Icons.storage_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}
