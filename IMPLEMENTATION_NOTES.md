# Wedding planning additions

No Cloud Functions or additional Dart dependencies are used. No app, tests, emulators or builds were executed.

## Where to find the features

- Overview: gift money totals, gift ledger shortcut, and Planning Tools shortcut.
- Profile: Gift Money Received and Wedding Planning.
- Wedding Planning: vendors, checklist templates and prerequisites, gift money, family contributions, linked documents, category budgets, partial repayments, payment trends, and workspace backup/restore.
- Expense add/edit: optional vendor association. Vendor records show linked bill totals and open the existing expense detail/payment history.
- Expense details: remaining repayment balance and a shortcut to repayment history.
- Shopping add/edit: optional due date. Pending shopping items, incomplete tasks, vendor follow-ups, and guest events join the existing local notification schedule.
- Guest details, per event: copy or revoke a guest RSVP link. Creating a new link revokes the previous link. Responses update the organizer's RSVP summary through Firestore streams. Revoking/rotating a link preserves its latest response in the private workspace.

## Firestore-only RSVP setup

Merge `firestore/rsvp.rules.fragment` into the existing deployed Firestore rules' `/databases/{database}/documents` block. The fragment deliberately does not replace existing workspace rules. Ensure no broader public allow rule overrides its restrictions. Keep the current workspace membership restrictions for private guest data and RSVP responses.

Public invitations are random 256-bit bearer capabilities. Guests can read only the invitation named by their link, cannot list invitations or access the private workspace, and can change only the response fields before expiry. Rules validate attendee counts against the original guest record. Deleted guests/events invalidate their public links.

The Flutter web source contains the guest response page at `/#/guest-rsvp?token=...`. The default hosting origin is `https://expense-tracker-20653.web.app`; change the `RSVP_WEB_ORIGIN` Dart environment value if using another hosting origin. Publish the updated web application and merge the Firestore rules before sharing guest links. No deployment was performed.

## Data and compatibility

New records use the existing workspace dashboard document and inherit its current access controls. Existing documents default to empty planning records and retain their expenses, purchases, reminders and repayment data. Monetary planning values use integer minor units, with two decimal places, consistent with the existing amount UI. Gifts and received contributions are separate from expense totals and budget limits; changing the profile currency does not convert amounts.

Dashboard saves merge changed records inside Firestore transactions. Changes to separate records are preserved; conflicting writes to the same record fail with a retry message. Linked-record, task dependency, repayment balance and storage-size checks run on the merged data. New-record editing forms preserve input after failed saves.

Documents store HTTPS receipt/contract links rather than uploading files. Access to the target files stays with the chosen provider. Backup exports include links, not file contents or live invitation tokens. Backups include the currency code and cannot be merged into a profile with a different currency. Restore adds missing records and preserves existing IDs; it requires the workspace owner and supports up to 450 guest/event/RSVP/repayment-person records per atomic import. Dashboard records are additionally bounded by Firestore's document size, with an early size check. The current storage layout does not provide unlimited archival capacity.

Backup JSON and CSV are copied to the clipboard for saving or pasting; PDF uses the existing print/share integration. CSV and PDF exports cover each planning ledger. The JSON export includes the latest public RSVP responses alongside private responses.

## Store listing

The source login and splash branding now matches Wedding360. Play Store screenshots and store metadata were not published or changed. Refresh screenshots manually with populated examples of guests/RSVP, vendors, gift money, contributions, collaboration, split payments, reports and checklists. The store's data-safety declarations need to reflect the app's actual Firebase, advertising and optional invoice-scanning data flows.

## Z.ai invoice scanning migration

Gemini has been replaced by `ZaiInvoiceService`. `InvoiceBillData` lives in its own model file. Both the existing expense dialog and the main expense form use Z.ai. The main form offers Camera/Choose Image scanning controls.

All signed-in users now use the common configuration at `appConfig/invoiceAi` (`apiKey`, optional `model`, optional `enabled`). Manage it through Firebase console/Admin SDK; the app has no key-editing screen or client write methods. Personal credentials are no longer read. Keys and configuration are excluded from workspace backups. Signed-in clients necessarily can retrieve the key because API requests are made directly from Flutter.

Merge `firestore/invoice-ai.rules.fragment` into the current deployed rules, remove the previous personal-key allow rule, and populate the common configuration before scanning. The API host is fixed in source and errors/logs do not include credentials. No Cloud Functions or additional dependencies were added. No live AI API request was made. See the README's Z.ai section for setup and provider documentation.

## English and Arabic localization

Adapted the local nemaCollection implementation: GetX translation maps, English fallback, device locale on first launch, a persisted language preference, and instant locale updates. Switch language on sign-in, in Profile, or on the guest RSVP page. Arabic has RTL direction and localized framework dialogs/date pickers. Notifications reschedule in the selected language when the dashboard is active.

Added `TranslationService`, `en_us.dart`, `ar_ae.dart`, const-friendly presentation wrappers, and `LanguageWidget`. Updated `main.dart`, Flutter localization SDK dependencies, forms, navigation, auth, guest/RSVP, planning, reports UI, legal/help screens, date/number utilities, notification text and controller messages. Raw user content and stored codes remain unchanged; PDF/CSV exports retain their existing output format. No language server, translation API, Cloud Functions, tests, app execution or build verification were used.
