# Chatbot Frontend

A modern, responsive chat interface built with Flutter, featuring real-time AI streaming, Markdown rendering, model selection, and profile management.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version recommended)
- [Dart SDK](https://dart.dev/get-dart)

## Environment Configuration

This project uses environment-specific JSON files for configuration, located in the `env/` directory.

- `env/dev.json` - Used for local development.
- `env/prod.json` - Used for production builds.

## Running the Project Locally

To run the project in development mode (e.g., on Chrome) with a specific port, use the following command:

```bash
flutter run -d chrome --web-port=3000 --dart-define-from-file=env/dev.json
```

## Code Generation (build_runner)

This project uses packages like `freezed` and `json_serializable` that require code generation. If you change models or data classes, you need to run the `build_runner`:

To build generated files once:
```bash
dart run build_runner build --delete-conflicting-outputs
```

To watch for changes and generate files continuously during development:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Building for Production

To create an optimized production build for the web, run:

```bash
flutter build web --dart-define-from-file=env/prod.json
```

The compiled web assets will be generated in the `build/web/` directory, ready to be hosted on services like Vercel, Firebase Hosting, or Nginx.

## Troubleshooting & Resolving Package Conflicts

If you run into package version conflicts, `pubspec.lock` issues, or build errors, follow these steps to reset and clean your environment:

1. **Clean the project build directory:**
   ```bash
   flutter clean
   ```

2. **Clear the global pub cache (optional but recommended for stubborn issues):**
   ```bash
   flutter pub cache clean
   ```
   *(Press 'Y' when prompted)*

3. **Re-fetch all dependencies:**
   ```bash
   flutter pub get
   ```

4. **Identify Outdated Packages (if conflicts persist):**
   ```bash
   flutter pub outdated
   ```
   
5. **Upgrade dependencies (if you need to force updates):**
   ```bash
   flutter pub upgrade
   ```
