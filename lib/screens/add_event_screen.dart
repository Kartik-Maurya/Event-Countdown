import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';
import '../services/storage_service.dart';

class AddEventScreen extends StatefulWidget {
  final Event? existingEvent;
  final void Function(Event) onEventSaved;

  const AddEventScreen({
    super.key,
    this.existingEvent,
    required this.onEventSaved,
  });

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  EventCategory _selectedCategory = EventCategory.personal;
  bool _reminderEnabled = true;
  int _reminderMinutes = 1440;

  bool get _isEditing => widget.existingEvent != null;

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
    _initWithExistingEvent();
  }

  Future<void> _initWithExistingEvent() async {
    if (_isEditing) {
      final event = widget.existingEvent!;
      _titleController.text = event.title;
      _descriptionController.text = event.description;
      _selectedDate = event.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(event.dateTime);
      _selectedCategory = event.category;
      _reminderEnabled = event.reminderEnabled;
      _reminderMinutes = event.reminderMinutesBefore;
    } else {
      _reminderMinutes = await StorageService.getDefaultReminderMinutes();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) return;

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final event = Event(
      id: _isEditing ? widget.existingEvent!.id : const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dateTime: dateTime,
      category: _selectedCategory,
      reminderEnabled: _reminderEnabled,
      reminderMinutesBefore: _reminderMinutes,
    );

    widget.onEventSaved(event);
    Navigator.pop(context, event);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatted = DateFormat('EEE, MMM d, yyyy').format(_selectedDate);
    final timeFormatted = _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Event' : 'Add Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  hintText: 'e.g., Birthday Party',
                  prefixIcon: Icon(Icons.title_rounded),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add some details...',
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),

              // Date & Time Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(dateFormatted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          prefixIcon: Icon(Icons.access_time_rounded),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(timeFormatted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton.filled(
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime.now();
                          _selectedTime = TimeOfDay.now();
                        });
                      },
                      icon: const Icon(Icons.bolt_rounded),
                      tooltip: 'Set to Now',
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Category
              DropdownButtonFormField<EventCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: EventCategory.values.map((cat) {
                  final color = Color(
                    int.parse(cat.colorHex.replaceFirst('#', '0xFF')),
                  );
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(
                          IconData(cat.iconCode, fontFamily: 'MaterialIcons'),
                          color: color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(cat.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 20),

              // Reminder
              SwitchListTile(
                title: const Text('Enable Reminder'),
                subtitle: Text(
                  _reminderEnabled
                      ? _reminderOptions
                          .firstWhere(
                            (o) => o['minutes'] == _reminderMinutes,
                            orElse: () => _reminderOptions.first,
                          )['label']
                      : 'Disabled',
                ),
                secondary: Icon(
                  _reminderEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_outlined,
                ),
                value: _reminderEnabled,
                onChanged: (value) {
                  setState(() => _reminderEnabled = value);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
              if (_reminderEnabled) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _reminderMinutes,
                  decoration: const InputDecoration(
                    labelText: 'Remind me',
                    prefixIcon: Icon(Icons.alarm_rounded),
                    border: OutlineInputBorder(),
                  ),
                  items: _reminderOptions.map((opt) {
                    return DropdownMenuItem(
                      value: opt['minutes'] as int,
                      child: Text(opt['label'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _reminderMinutes = value);
                  },
                ),
              ],
              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: _saveEvent,
                icon: Icon(_isEditing ? Icons.check : Icons.add),
                label: Text(_isEditing ? 'Save Changes' : 'Add Event'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
