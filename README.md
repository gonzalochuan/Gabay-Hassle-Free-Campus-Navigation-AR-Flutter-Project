# Gabay

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
Gabay-Hassle-Free-Campus-Navigation-AR-Flutter-Project


to run this in real phone

flutter run -d 10620253BL005996

## Environment Configuration

This app uses `flutter_dotenv` and expects a `.env` file at the project root. The `.env` file is intentionally ignored by Git to avoid committing secrets.

- Copy `.env.example` to `.env` and fill in your own values:

```
cp .env.example .env
# Then edit .env and set your keys
```

- Required variables:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`

The Flutter app loads these with `flutter_dotenv`. See `lib/core/env.dart` for how they are accessed.

## Running the app

After creating your `.env` file:

```
flutter pub get
flutter run