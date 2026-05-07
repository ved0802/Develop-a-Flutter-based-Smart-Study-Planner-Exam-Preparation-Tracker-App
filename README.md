# StudyMate — Smart Study Planner & Exam Preparation Tracker

A complete, offline-first Flutter application for planning study schedules, tracking subject-wise and topic-wise progress, and analyzing preparation status.

**Developer:** Vansh  
**Built with:** Flutter + Provider + Hive  

---

## Features

- **Subject & Topic Management** — Add subjects and organize topics with estimated study times
- **Study Scheduling** — Schedule study sessions with date, time, and duration
- **Progress Tracking** — Mark topics as Not Started / In Progress / Completed
- **Dashboard** — Visual stats, weekly chart, today's sessions, subject completion bars
- **Search & Filter** — Search topics by name, filter by subject or status
- **Priority Engine** — Suggests next topics based on lowest completion subjects
- **Offline-First** — All data stored locally with Hive, works without internet

## Architecture

```
lib/
├── core/               # Theme, constants, utilities
│   ├── theme.dart
│   ├── constants.dart
│   └── utils/priority_engine.dart
├── modules/
│   ├── subject/        # Subject & Topic management
│   ├── schedule/       # Study session scheduling
│   ├── progress/       # Progress tracking screen
│   ├── dashboard/      # Dashboard with charts
│   └── search/         # Search & filter
├── widgets/            # Reusable UI components
└── main.dart           # Entry point
```

## Tech Stack

| Concern | Choice |
|---------|--------|
| Framework | Flutter (latest stable) |
| State Management | Provider |
| Local Storage | Hive (offline-first) |
| Charts | fl_chart |
| Architecture | Modular (MVVM) |

## Setup & Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

## Screens

1. **Dashboard** — Greeting, stats grid, weekly bar chart, today's sessions
2. **Subject Management** — Expandable subject cards with topic lists
3. **Study Scheduling** — Date-grouped sessions with completion checkboxes
4. **Study Progress** — Overall progress ring, suggested topics, per-subject breakdown
5. **Search & Filter** — Real-time search with subject and status filters
