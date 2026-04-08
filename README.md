# Bunny Wallet

A beautiful, offline-first expense tracker app built with Flutter.

## Features

- **Income & Expense Tracking** - Quick-add transactions with categories, notes, and date picker
- **Savings Goals** - Set targets, deposit/withdraw, track progress with visual indicators
- **Credit Card Management** - Track multiple cards, balances, utilization, and payment due dates
- **Payment Reminders** - Local notifications before credit card payments are due
- **Light & Dark Mode** - System-aware theming with smooth transitions
- **Offline-First** - All data stored locally with SQLite, no internet required

## Tech Stack

- Flutter 3.x / Dart
- Riverpod (state management)
- GoRouter (navigation)
- sqflite (local database)
- fl_chart (charts)
- flutter_local_notifications (reminders)
- Google Fonts (Poppins + Inter)
- Material 3

## Getting Started

```bash
# Clone and navigate
cd bunny_wallet

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```
lib/
  core/           # Theme, router, utils, constants, services
  data/           # Database, models, repositories, providers
  features/       # Feature modules (dashboard, transactions, savings, credit_cards, settings)
  widgets/        # Shared reusable widgets
  main.dart       # App entry point
```

## Architecture

Clean Architecture with feature-first organization:
- **Models** define data structures with serialization
- **Repositories** abstract database operations
- **Riverpod Providers** manage state reactively
- **Screens/Widgets** consume state and render UI
