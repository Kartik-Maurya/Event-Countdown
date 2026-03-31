<h1 align="center">Event Countdown & Reminder Board</h1>

<p align="center">
  A personal milestone tracking app built with Flutter — runs as a <strong>mobile Android APK</strong> and an <strong>installable PWA</strong> with offline support.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.41.5-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.11.3-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Material-Design%203-6750A4?logo=materialdesign" alt="Material 3">
  <img src="https://img.shields.io/badge/PWA-Ready-5A0FC8" alt="PWA Ready">
  <img src="https://img.shields.io/badge/Offline-First-green" alt="Offline First">
</p>

---

## Features

- **Event Management** — Add, edit, delete events with title, description, date/time, category, and reminders
- **Live Countdown Timers** — Real-time seconds-level countdown updates on all cards and detail views
- **Category Filtering** — Filter by Birthday, Work, Exam, Personal, Travel, or Other
- **Status Badges** — Visual indicators for *Today*, *Tomorrow*, and *Overdue*
- **Local Notifications** — Scheduled reminders before events (Android/iOS)
- **Offline-First Storage** — All data persisted locally via `SharedPreferences`
- **PWA Support** — Service worker with cache-first strategy, installable to home screen
- **Dark/Light Theme** — Toggle with persistence across sessions
- **Material Design 3** — Rounded cards, FAB, color-coded categories

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | [Flutter](https://flutter.dev) 3.41.5 (Dart 3.11.3) |
| State Management | `setState` (built-in) |
| Local Storage | `shared_preferences` |
| Notifications | `flutter_local_notifications` + `timezone` |
| Date Formatting | `intl` |
| Unique IDs | `uuid` |
| Fonts | `google_fonts` |
| PWA | Service Worker + Web App Manifest |

---

## Project Structure

```
lib/
├── main.dart                          # App entry, theme config, routing
├── models/
│   └── event.dart                     # Event model with JSON serialization
├── screens/
│   ├── home_screen.dart               # Dashboard with countdown cards
│   ├── add_event_screen.dart          # Add/Edit event form
│   ├── event_detail_screen.dart       # Event details with countdown display
│   └── settings_screen.dart           # Theme toggle, default reminder
├── services/
│   ├── storage_service.dart           # SharedPreferences persistence
│   └── notification_service.dart      # Local notification scheduling
└── widgets/
    └── event_card.dart                # Event card with live countdown timer

web/
├── index.html                         # PWA entry with service worker registration
├── manifest.json                      # PWA manifest (name, icons, theme)
├── service-worker.js                  # Offline caching + push notification handler
└── icons/                             # PWA icons (192px, 512px, maskable)
```

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x+
- [Chrome](https://www.google.com/chrome/) (for web/PWA testing)
- Android SDK (for APK builds)
- Android device or emulator

Verify your setup:

```bash
flutter doctor
```

---

## Getting Started

```bash
cd event_countdown
flutter pub get
flutter run -d chrome
```

---

## Run & Build

### Web (Debug)

```bash
flutter run -d chrome
```

### PWA (Release Build)

```bash
flutter build web --release --no-tree-shake-icons
```

Output: `build/web/`

### Serve Locally

```bash
cd build/web
npx serve .
```

Open `http://localhost:3000` in Chrome.

<details>
<summary><strong>PWA Install & Offline Test</strong></summary>

1. Open the served URL in Chrome
2. Click the install icon in the address bar (or Menu → Install Event Countdown)
3. The app opens in standalone mode — no browser UI
4. Open **DevTools → Application → Service Workers** — verify `service-worker.js` is active
5. Toggle **DevTools → Network → Offline**
6. Refresh — the app still loads and works
7. Add/edit/delete events — changes persist via `localStorage`

</details>

<details>
<summary><strong>Deploy to GitHub Pages</strong></summary>

```bash
flutter build web --release --base-href "/<repo-name>/" --no-tree-shake-icons
```

Push `build/web/` contents to the `gh-pages` branch.

</details>

### Android (Debug)

```bash
flutter run
```

### Android (Release APK)

```bash
flutter build apk --release --no-tree-shake-icons
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Install on Device

```bash
flutter install
```

Or transfer the APK manually.

---

## App Usage

### Home Screen

- All events displayed as cards with **live countdown timers**
- Filter chips to filter by category
- Stats bar: **Total**, **Upcoming**, **Today**, **Overdue**
- Tap **+ Add Event** FAB to create a new event
- Tap any card to view/edit details
- Tap the delete icon to remove an event

### Add / Edit Event

| Field | Description |
|-------|-------------|
| Title | Required event name |
| Description | Optional details |
| Date & Time | Date/time pickers, or tap ⚡ for "now" |
| Category | Birthday, Work, Exam, Personal, Travel, Other |
| Reminder | Toggle on/off, choose timing (5 min → 1 week before) |

### Event Detail

- Full countdown display (Days / Hours / Minutes / Seconds)
- Category badge with color coding
- Edit button to modify
- Info rows for date, time, reminder status

### Settings

- Toggle dark/light theme
- Set default reminder time for new events

---

## Data Model

```json
{
  "id": "uuid-v4-string",
  "title": "Birthday Party",
  "description": "Surprise party at home",
  "dateTime": "2026-04-15T18:00:00.000",
  "category": "birthday",
  "reminderEnabled": true,
  "reminderMinutesBefore": 1440
}
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Unique UUID v4 |
| `title` | String | Event name |
| `description` | String | Optional details |
| `dateTime` | ISO 8601 | Event date and time |
| `category` | Enum | `birthday` `work` `exam` `personal` `travel` `other` |
| `reminderEnabled` | bool | Schedule a notification |
| `reminderMinutesBefore` | int | `0` `5` `15` `30` `60` `120` `1440` `2880` `10080` |

---

## PWA Details

### Service Worker (`web/service-worker.js`)

| Event | Behavior |
|-------|----------|
| `install` | Caches app shell and static assets |
| `activate` | Clears old caches on version update |
| `fetch` | Cache-first → network fallback → caches response |
| `push` | Handles push notifications (future server integration) |
| `notificationclick` | Opens app when notification is tapped |

### Web App Manifest (`web/manifest.json`)

- **Name:** Event Countdown & Reminder Board
- **Display:** `standalone` (no browser UI)
- **Theme Color:** `#673AB7` (deep purple)
- **Icons:** 192px, 512px, maskable variants

### Offline Behavior

- App shell loads from cache without network
- Event data persists in `localStorage`
- Full CRUD operations work offline

---

## Category Colors

| Category | Hex |
|----------|-----|
| Birthday | `#E91E63` Pink |
| Work | `#2196F3` Blue |
| Exam | `#F44336` Red |
| Personal | `#4CAF50` Green |
| Travel | `#FF9800` Orange |
| Other | `#9C27B0` Purple |

---

## Dependencies

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.8              # iOS-style icons
  shared_preferences: ^2.5.3           # Local key-value storage
  flutter_local_notifications: ^19.1.0 # Scheduled notifications
  intl: ^0.20.2                        # Date formatting
  uuid: ^4.5.1                         # Unique ID generation
  provider: ^6.1.2                     # State management (available)
  google_fonts: ^6.2.1                 # Typography
  timezone: ^0.10.1                    # Timezone-aware scheduling
```

---

## Troubleshooting

<details>
<summary><code>--no-tree-shake-icons</code> flag required</summary>

The app uses dynamic `IconData` constructors based on category icon codes. This breaks Flutter's tree shaking. Always pass `--no-tree-shake-icons` for release builds.

```bash
flutter build web --release --no-tree-shake-icons
flutter build apk --release --no-tree-shake-icons
```

</details>

<details>
<summary>Android desugaring error</summary>

`flutter_local_notifications` requires core library desugaring. Already configured in `android/app/build.gradle.kts`:

```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

</details>

<details>
<summary>Notifications on Android 13+</summary>

The app requests `POST_NOTIFICATIONS` permission in `AndroidManifest.xml`. On Android 13+, the user must grant notification permission at runtime.

</details>

---

## License

This project is for educational purposes.
