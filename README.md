# Mini Chat Application

A modern, responsive Flutter chat application with exceptional UX, built with clean architecture patterns.

## Features

- **💬 Real-time Chat**: Send messages and receive auto-replies from API
- **👥 User Management**: Add and manage chat contacts
- **📖 Dictionary Lookup**: Tap any word to see its definition
- **🔊 Audio Pronunciation**: Listen to word pronunciations
- **🎨 Material Design 3**: Beautiful, modern UI with smooth animations
- **🌓 Dark Mode**: Automatic light/dark theme support
- **📱 Fully Responsive**: Works on all screen sizes

## Technical Stack

| Technology          | Purpose                  |
| ------------------- | ------------------------ |
| **Flutter 3.x**     | Cross-platform framework |
| **Provider**        | State management         |
| **Dio**             | HTTP networking          |
| **flutter_animate** | Declarative animations   |
| **audioplayers**    | Audio playback           |

## Architecture Highlights

- **Zero setState()**: All UI updates through Provider
- **Clean Architecture**: Layered separation of concerns
- **Declarative Animations**: No AnimationController usage
- **Comprehensive Tests**: Unit tests for all business logic

## Getting Started

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.0 or higher

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd chat_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── config/                # Configuration
├── models/                # Data models
├── providers/             # State management
├── services/              # API services
├── screens/               # UI screens
├── widgets/               # Reusable widgets
└── utils/                 # Utilities

docs/
└── system/               # Architecture documentation
    ├── architecture.md
    ├── state_management.md
    ├── networking.md
    ├── animations.md
    └── ui_components.md
```

## Key Features Explained

### Chat System

- Send messages instantly (local state)
- Receive auto-replies after 2 seconds (from DummyJSON API)
- Message timestamps and delivery indicators

### Dictionary Feature

- Tap any word in messages to look up definition
- View phonetics, meanings, and examples
- Play audio pronunciation (like Google Translate)

### Navigation

- Bottom navigation with 3 tabs (Home, Explore, Settings)
- Home tab with Users List / Chat History switcher
- Scroll position preserved when switching tabs

## API Endpoints

| API            | Endpoint                 | Purpose           |
| -------------- | ------------------------ | ----------------- |
| DummyJSON      | `GET /comments`          | Receiver messages |
| Dictionary API | `GET /entries/en/{word}` | Word definitions  |

## Documentation

Detailed system documentation is available in the `docs/system/` directory:

- [Architecture Overview](docs/system/architecture.md)
- [State Management](docs/system/state_management.md)
- [Networking](docs/system/networking.md)
- [Animation System](docs/system/animations.md)
- [UI Components](docs/system/ui_components.md)

## License

This project is for educational purposes.
