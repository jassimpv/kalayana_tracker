# Kalyana Expense Tracker

A Flutter + Firebase wedding planning dashboard for tracking expenses, split payments, reminders, shopping items, and shared repayment status.

## Features

- Email/password and Google sign-in with Firebase Authentication.
- Firestore-backed dashboard data per signed-in user.
- Wedding expense tracking with total, paid, pending, due date, payer, and notes.
- Split and partial payment support for paying one expense in multiple installments.
- Payment activity timeline with amount, payer, date, notes, and remaining balance.
- Shared repayment tracking for bills paid by someone else.
- Upcoming payment and reminder views.
- Shopping list items that can be converted into expenses.
- CSV export for spreadsheet workflows.
- PDF expense report export, including payment history.
- Responsive Flutter UI for web, iOS, Android, macOS, Windows, and Linux.

## Tech Stack

- Flutter / Dart
- GetX for routing and state management
- Firebase Core, Firebase Auth, Cloud Firestore
- Google Sign-In
- `pdf` and `printing` for PDF export
- `image_picker` and Gemini invoice extraction support

## Project Structure

```text
lib/
  app/
    core/
      theme/
      utils/
    data/
      models/
      repositories/
    modules/
      auth/
      dashboard/
    routes/
  firebase_options.dart
  main.dart
web/
  index.html
.vscode/
  launch.json
```

## Setup

Install dependencies:

```bash
flutter pub get
```

Run static checks:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Firebase Setup

This app expects Firebase options in:

```text
lib/firebase_options.dart
```

The current project is configured for:

```text
expense-tracker-20653
```

Required Firebase products:

- Authentication
- Cloud Firestore

Enable these sign-in providers in Firebase Authentication:

- Email/Password
- Google

## Google Sign-In on Web

The web OAuth client ID is configured in:

```text
lib/app/modules/auth/auth_controller.dart
web/index.html
```

Current web client ID:

```text
1097547412500-kghp41ghv639fqkujrhc91vgpio1cro5.apps.googleusercontent.com
```

In Google Cloud Console, add your local and production URLs under **Authorized JavaScript origins**. For the current VS Code launch config, add:

```text
http://localhost:5001
```

If you use Firebase Hosting, also keep:

```text
https://expense-tracker-20653.firebaseapp.com
```

Do not put OAuth client secrets in Flutter or web code. Client secrets are for server-side OAuth flows only.

## Running Locally

The included VS Code launch config runs Flutter web on Chrome at port `5001`:

```bash
flutter run -d chrome --web-port 5001
```

Port `5000` may be occupied by macOS Control Center / AirPlay Receiver. If you prefer port `5000`, first free that port and add this origin in Google Cloud:

```text
http://localhost:5000
```

Then run:

```bash
flutter run -d chrome --web-port 5000
```

## PDF and CSV Export

The Expenses screen includes export actions:

- `CSV` copies expense data to the clipboard for Sheets or Excel.
- `PDF` opens the platform print/share flow and includes:
  - summary totals
  - expense table
  - due dates
  - statuses
  - split payment history

## Common OAuth Errors

`origin_mismatch` or `invalid_client` usually means the browser URL is not registered on the OAuth web client.

Example: if the app runs at:

```text
http://localhost:5001
```

Then this exact origin must be listed in Google Cloud Console:

```text
http://localhost:5001
```

Do not include a trailing slash.

## Useful Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 5001
flutter build web
```

## Notes

- Keep generated Firebase credentials and OAuth client IDs in sync between Firebase, Google Cloud Console, and app code.
- Rotate any OAuth client secret that was accidentally pasted into logs, screenshots, chat, or source control.
- The app stores dashboard data under the signed-in user's Firestore document.
