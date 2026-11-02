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
- `image_picker` and Z.ai invoice extraction with one app-wide API key stored in Firestore

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

## Z.ai Invoice Scanning

Invoice extraction uses Z.ai's multimodal chat-completions API with `glm-5.3-flash` by default:

- API: https://docs.z.ai/api-reference/llm/chat-completion
- Image input: https://docs.z.ai/guides/vlm/glm-5.3-flash
- Endpoint: `https://api.z.ai/api/paas/v4/chat/completions`

All signed-in users use **one common key**, managed by the app owner. Create this document in Firebase console (or through a trusted Admin SDK):

```text
appConfig/invoiceAi
  apiKey: <common Z.ai standard model API key>
  model: glm-5.3-flash
  enabled: true
```

`model` defaults to `glm-5.3-flash` when omitted. Set `enabled` to `false` to pause invoice scanning for everyone. The API host is fixed in source. The app reads this document from the server for each scan so key/model changes do not require an app release. No actual key has been created or uploaded during implementation.

Merge `firestore/invoice-ai.rules.fragment` into the current Firestore rules' `/databases/{database}/documents` block. Preserve workspace rules, remove the older personal-key allow rule, and ensure no broader matching rule permits clients to write app configuration. Client access to the common document is read-only; changes are made through Firebase console/Admin SDK. No rules have been deployed automatically.

Users do not enter, replace, or remove keys in the app. Personal keys under `users/{uid}/private/invoiceAi` are no longer read; any previously saved keys can be removed through Firebase console. The common key is excluded from workspace backups and app logs. Because the Flutter client reads the key and calls Z.ai directly, signed-in users can retrieve the common key. This architecture does not hide a developer credential from clients; keep this exposure in mind when setting provider spending limits. No Cloud Functions are used.

Use **Camera** or **Choose image** on Add Expense. JPEG, PNG and WebP images up to 8 MB are supported. Review extracted expense details before saving. A configured replacement model must support image input and JSON output on Z.ai's standard model API. Browser use also depends on Z.ai allowing requests from the web app's origin. No live API request, app execution, tests, or build verification were performed during implementation.

## Languages (nemaCollection pattern)

The interface supports **English (en_US)** and **Arabic (ar_AE)** using the same GetX approach as `nema_collection`: separate translation maps, an English fallback, saved `languageCode` preference, device-language selection on first launch, and `Get.updateLocale` for switching without restarting the app.

- Switch using the language button on sign-in, **Profile → Language**, or the guest RSVP page.
- Arabic uses right-to-left layout and Flutter's localized Material/Cupertino controls and date picker.
- UI labels, form validation, snackbar messages, month names, planning summaries and scheduled notifications use the selected language. Currency names are translated in the picker and can be searched in Arabic.
- Arabic-Indic and Persian digits are normalized for amount and guest-count entry. Stored amounts remain numbers.
- Guest names, notes, contact details, workspace data, stored category/status codes, invoice extraction JSON, and API settings are not rewritten when switching languages.
- PDF/CSV exports retain their existing format and labels. Unknown UI phrases fall back to English. User-entered content is not machine-translated.

Implementation:

```text
lib/app/core/localization/translation_service.dart
lib/app/core/localization/en_us.dart
lib/app/core/localization/ar_ae.dart
lib/app/core/localization/localized_widgets.dart
lib/app/core/widgets/language_widget.dart
```

Use `LocalizedText` and `LocalizedInputDecoration` for presentation labels, `TranslationService.translate` for non-widget messages, and raw Flutter `Text` for user-entered content. Add matching keys to both language maps; named placeholders must be identical. Translation affects presentation only—keep repository models, filters, database queries, and exported records on their canonical values.
