import 'package:kalayanaexpresstracker/app/core/localization/translation_service.dart';
import 'package:kalayanaexpresstracker/app/data/models/planning_entry.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:kalayanaexpresstracker/app/core/config.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_data.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules local "due tomorrow" / "due today" notifications for reminders
/// and pending expenses. Reschedules the full set on every sync rather than
/// tracking incremental diffs — simple, and cheap at this app's scale.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _channelId = 'wedding_reminders';
  static const _channelName = 'Reminders & Due Dates';
  static const _slotReminderDayBefore = 0;
  static const _slotReminderSameDay = 1;
  static const _slotExpenseDayBefore = 2;
  static const _slotExpenseSameDay = 3;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  List<WeddingEvent> _events = const [];
  Future<void> _scheduleQueue = Future.value();

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    if (kIsWeb) return;

    tz_data.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (error) {
      debugPrint('NotificationService: failed to resolve timezone: $error');
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        _channelId,
        TranslationService.translate(_channelName),
        description: 'Upcoming reminders and pending payment due dates',
      ),
    );
  }

  Future<void> requestPermission() async {
    if (kIsWeb) return;
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> cancelAll() {
    _events = const [];
    if (kIsWeb) return Future.value();
    return _plugin.cancelAll();
  }

  Future<void> syncSchedule(
    WeddingData data, {
    required bool enabled,
    List<WeddingEvent>? events,
  }) {
    if (events != null) _events = List.of(events);
    final eventSnapshot = List<WeddingEvent>.of(_events);
    final operation = _scheduleQueue.then(
      (_) => _syncSchedule(data, enabled: enabled, events: eventSnapshot),
    );
    _scheduleQueue = operation.catchError((Object error) {
      debugPrint('Notification scheduling failed: $error');
    });
    return _scheduleQueue;
  }

  Future<void> _syncSchedule(
    WeddingData data, {
    required bool enabled,
    required List<WeddingEvent> events,
  }) async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
    if (!enabled) return;

    for (final reminder in data.reminders) {
      if (reminder.isDone) continue;
      await _scheduleSlots(
        itemId: 'reminder:${reminder.id}',
        dueDate: reminder.dueDate,
        dayBeforeSlot: _slotReminderDayBefore,
        sameDaySlot: _slotReminderSameDay,
        title: 'Reminder: ${reminder.title}',
        body: '${reminder.category} reminder is due.',
      );
    }

    for (final purchase in data.purchases) {
      if (purchase.dueDate == null ||
          purchase.status == 'Purchased' ||
          purchase.status == 'Cancelled') {
        continue;
      }
      await _scheduleSlots(
        itemId: 'purchase:${purchase.id}',
        dueDate: purchase.dueDate!,
        dayBeforeSlot: 0,
        sameDaySlot: 1,
        title: 'Shopping due: ${purchase.name}',
        body: purchase.category,
      );
    }
    for (final entry in data.planning) {
      if (entry.date == null ||
          entry.isDone ||
          (entry.kind != PlanningKind.task &&
              entry.kind != PlanningKind.vendor)) {
        continue;
      }
      await _scheduleSlots(
        itemId: '${entry.kind.name}:${entry.id}',
        dueDate: entry.date!,
        dayBeforeSlot: 0,
        sameDaySlot: 1,
        title:
            '${entry.kind == PlanningKind.task ? 'Task' : 'Vendor follow-up'}: ${entry.name}',
        body: entry.notes,
      );
    }
    for (final event in events) {
      if (event.date == null) continue;
      await _scheduleSlots(
        itemId: 'event:${event.id}',
        dueDate: event.date!,
        dayBeforeSlot: 0,
        sameDaySlot: 1,
        title: 'Wedding event: ${event.name}',
        body: event.venue,
      );
    }

    for (final expense in data.expenses) {
      if (expense.isPaid) continue;
      final dueDate = expense.dueDate;
      if (dueDate == null) continue;
      await _scheduleSlots(
        itemId: 'expense:${expense.id}',
        dueDate: dueDate,
        dayBeforeSlot: _slotExpenseDayBefore,
        sameDaySlot: _slotExpenseSameDay,
        title: 'Payment due: ${expense.name}',
        body:
            '${AppConfig.appCurrency}${formatMoney(expense.pendingForSummary)} pending.',
      );
    }
  }

  Future<void> _scheduleSlots({
    required String itemId,
    required DateTime dueDate,
    required int dayBeforeSlot,
    required int sameDaySlot,
    required String title,
    required String body,
  }) async {
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    await _scheduleAt(
      id: _idFor(itemId, dayBeforeSlot),
      when: DateTime(dueDay.year, dueDay.month, dueDay.day - 1, 9),
      title: title,
      body: body,
    );
    await _scheduleAt(
      id: _idFor(itemId, sameDaySlot),
      when: DateTime(dueDay.year, dueDay.month, dueDay.day, 9),
      title: title,
      body: body,
    );
  }

  Future<void> _scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    if (when.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id: id,
      title: TranslationService.translate(title),
      body: TranslationService.translate(body),
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(_channelId, _channelName),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  int _idFor(String itemId, int slot) {
    var hash = 2166136261;
    for (final unit in '$itemId:$slot'.codeUnits) {
      hash = ((hash ^ unit) * 16777619) & 0x7fffffff;
    }
    return hash;
  }
}
