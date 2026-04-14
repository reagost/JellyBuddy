# JellyBuddy

AI-powered gamified programming learning app built with Flutter.

## Features

- **3 Programming Courses** -- Python, JavaScript, and C++ curricula with structured lessons
- **4 Question Types** -- Multiple choice, fill-in-the-blank, drag-to-sort, and code writing
- **Local AI Tutor** -- On-device AI assistant powered by Gemma 4 via MLX/llama.cpp for private, offline help
- **Game Mechanics** -- XP progression, hearts/lives system, daily streaks, achievements, diamonds, and a leaderboard
- **Dark Mode** -- Full light and dark theme support
- **Internationalization** -- Chinese and English language support (i18n)
- **Offline-First** -- All learning content and progress stored locally; no account required
- **Privacy-Focused** -- AI inference runs entirely on-device

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Xcode 16+ (for iOS/macOS)
- Android Studio (for Android)

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd JellyBuddy

# Install dependencies
flutter pub get

# Run code generation (JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Running Tests

```bash
flutter test
```

## Architecture

JellyBuddy follows a **Clean Architecture** pattern with three layers:

```
lib/
  core/          # Theme, constants, router configuration
  data/          # Repositories and services (Hive storage, AI inference)
  domain/        # Entities and repository interfaces
  presentation/  # UI layer (screens, widgets, BLoC state management)
  l10n/          # Localization files
  packages/      # Local packages (jelly_llm for LLM inference)
```

**State Management**: Flutter BLoC for reactive state across game progress, lesson flow, and AI tutor conversations.

**Navigation**: GoRouter for declarative, deep-linkable routing.

**Storage**: Hive for local persistence of user progress, lesson results, and settings.

## License

MIT
