import 'dart:convert';

enum EventCategory {
  birthday,
  work,
  exam,
  personal,
  travel,
  other;

  String get label {
    switch (this) {
      case EventCategory.birthday:
        return 'Birthday';
      case EventCategory.work:
        return 'Work';
      case EventCategory.exam:
        return 'Exam';
      case EventCategory.personal:
        return 'Personal';
      case EventCategory.travel:
        return 'Travel';
      case EventCategory.other:
        return 'Other';
    }
  }

  int get iconCode {
    switch (this) {
      case EventCategory.birthday:
        return 0xe079; // cake
      case EventCategory.work:
        return 0xe1a7; // work
      case EventCategory.exam:
        return 0xe885; // school
      case EventCategory.personal:
        return 0xe87d; // favorite
      case EventCategory.travel:
        return 0xe539; // flight
      case EventCategory.other:
        return 0xe88f; // event
    }
  }

  String get colorHex {
    switch (this) {
      case EventCategory.birthday:
        return '#E91E63'; // Pink
      case EventCategory.work:
        return '#2196F3'; // Blue
      case EventCategory.exam:
        return '#F44336'; // Red
      case EventCategory.personal:
        return '#4CAF50'; // Green
      case EventCategory.travel:
        return '#FF9800'; // Orange
      case EventCategory.other:
        return '#9C27B0'; // Purple
    }
  }
}

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final EventCategory category;
  final bool reminderEnabled;
  final int reminderMinutesBefore;

  Event({
    required this.id,
    required this.title,
    this.description = '',
    required this.dateTime,
    required this.category,
    this.reminderEnabled = true,
    this.reminderMinutesBefore = 1440, // 1 day before
  });

  Duration get timeRemaining => dateTime.difference(DateTime.now());

  bool get isOverdue => dateTime.isBefore(DateTime.now());

  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    EventCategory? category,
    bool? reminderEnabled,
    int? reminderMinutesBefore,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      category: category ?? this.category,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'category': category.name,
      'reminderEnabled': reminderEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dateTime: DateTime.parse(json['dateTime'] as String),
      category: EventCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => EventCategory.other,
      ),
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      reminderMinutesBefore: json['reminderMinutesBefore'] as int? ?? 1440,
    );
  }

  static String encodeList(List<Event> events) {
    return jsonEncode(events.map((e) => e.toJson()).toList());
  }

  static List<Event> decodeList(String jsonString) {
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
  }
}
