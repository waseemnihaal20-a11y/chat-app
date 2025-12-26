# Mini Chat Application - System Architecture

## Overview

The Mini Chat Application is a modern Flutter chat application built with a clean architecture pattern, utilizing Provider for state management, Dio for networking, and flutter_animate for animations.

## Architecture Pattern

The application follows a **layered architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  (Screens, Widgets, UI Components)                          │
├─────────────────────────────────────────────────────────────┤
│                      State Management                        │
│  (Providers - ChangeNotifier)                               │
├─────────────────────────────────────────────────────────────┤
│                      Business Logic                          │
│  (Services - API calls, data processing)                    │
├─────────────────────────────────────────────────────────────┤
│                      Data Layer                              │
│  (Models - Data structures)                                 │
├─────────────────────────────────────────────────────────────┤
│                      Configuration                           │
│  (Global config, constants)                                 │
└─────────────────────────────────────────────────────────────┘
```

## Key Architectural Decisions

### 1. Zero setState() Policy

The application enforces a strict **zero `setState()` policy**. All UI updates are driven by Provider notifiers:

- `ChangeNotifierProvider` wraps all state classes
- `Consumer` widgets listen for state changes
- `notifyListeners()` triggers UI rebuilds

This approach ensures:

- Predictable state changes
- Easier debugging
- Better testability
- Separation of UI and business logic

### 2. Provider-based State Management

Four main providers manage application state:

| Provider             | Responsibility             |
| -------------------- | -------------------------- |
| `UserProvider`       | User list CRUD operations  |
| `ChatProvider`       | Chat sessions and messages |
| `NavigationProvider` | Tab and navigation state   |
| `DictionaryProvider` | Word lookups and audio     |

### 3. Service Layer

Services handle external communication:

- **ApiService**: Dio-based HTTP client for DummyJSON API
- **DictionaryService**: Dictionary API integration

All services:

- Use configured timeouts from `GlobalConfig`
- Include error handling
- Support dependency injection for testing

### 4. Animation Strategy

All animations use **flutter_animate** exclusively:

- No `AnimationController` usage
- Declarative animation chains
- Consistent timing and curves

## Data Flow

```
User Action → Widget → Provider → Service → API
                ↓
            notifyListeners()
                ↓
            Consumer rebuilds UI
```

## Folder Structure

```
lib/
├── main.dart                 # App entry point, Provider setup
├── config/
│   └── global.dart           # API URLs, timeouts
├── models/
│   ├── user_model.dart       # User data structure
│   ├── message_model.dart    # Message data structure
│   ├── chat_session_model.dart
│   └── dictionary_model.dart
├── providers/
│   ├── user_provider.dart
│   ├── chat_provider.dart
│   ├── navigation_provider.dart
│   └── dictionary_provider.dart
├── services/
│   ├── api_service.dart
│   └── dictionary_service.dart
├── screens/
│   ├── main_screen.dart
│   ├── home_screen.dart
│   ├── users_list_screen.dart
│   ├── chat_history_screen.dart
│   ├── chat_screen.dart
│   └── placeholder_screen.dart
├── widgets/
│   ├── avatar_widget.dart
│   ├── user_card.dart
│   ├── chat_card.dart
│   ├── message_bubble.dart
│   ├── tappable_text.dart
│   ├── dictionary_bottom_sheet.dart
│   ├── custom_app_bar_switcher.dart
│   └── add_user_bottom_sheet.dart
└── utils/
    ├── date_formatter.dart
    └── avatar_helper.dart
```

## Dependencies

| Package         | Purpose          |
| --------------- | ---------------- |
| provider        | State management |
| dio             | HTTP client      |
| flutter_animate | Animations       |
| audioplayers    | Audio playback   |

## Testing Strategy

Tests are organized by layer:

- `test/models/` - Model unit tests
- `test/providers/` - Provider unit tests
- `test/services/` - Service/config tests
- `test/utils/` - Utility function tests
- `test/widget_test.dart` - Widget integration tests
