import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:bunny_wallet/core/extensions/context_extensions.dart';
import 'package:bunny_wallet/data/models/credit_card_model.dart';
import 'package:bunny_wallet/data/models/payment_reminder_model.dart';
import 'package:bunny_wallet/data/providers/providers.dart';
import 'package:bunny_wallet/core/services/notification_service.dart';

final _remindersProvider =
    FutureProvider.family<List<PaymentReminderModel>, String>((ref, cardId) {
  ref.watch(creditCardRefreshProvider);
  return ref.read(creditCardRepoProvider).getReminders(cardId);
});

class ReminderSheet extends ConsumerStatefulWidget {
  final CreditCardModel card;

  const ReminderSheet({super.key, required this.card});

  @override
  ConsumerState<ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends ConsumerState<ReminderSheet> {
  static const _options = [1, 3, 5, 7];

  @override
  Widget build(BuildContext context) {
    final remindersAsync =
        ref.watch(_remindersProvider(widget.card.id));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Payment Reminders',
            style: context.textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Get notified before your payment is due (day ${widget.card.dueDay})',
            style: context.textTheme.bodySmall,
          ),
          const SizedBox(height: 20),

          remindersAsync.when(
            data: (reminders) {
              return Column(
                children: _options.map((days) {
                  final existing = reminders
                      .where((r) => r.daysBefore == days)
                      .toList();
                  final isEnabled =
                      existing.isNotEmpty && existing.first.isEnabled;
                  final reminder =
                      existing.isNotEmpty ? existing.first : null;

                  return Card(
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      title: Text(
                        '$days ${days == 1 ? 'day' : 'days'} before',
                        style: context.textTheme.titleSmall,
                      ),
                      subtitle: Text(
                        'Remind on day ${_reminderDay(widget.card.dueDay, days)}',
                        style: context.textTheme.bodySmall,
                      ),
                      secondary: Icon(
                        Icons.notifications_active_rounded,
                        color: isEnabled
                            ? context.colorScheme.primary
                            : context.colorScheme.onSurfaceVariant,
                      ),
                      value: isEnabled,
                      onChanged: (value) =>
                          _toggleReminder(days, value, reminder),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  int _reminderDay(int dueDay, int daysBefore) {
    int day = dueDay - daysBefore;
    if (day <= 0) day += 30;
    return day;
  }

  Future<void> _toggleReminder(
      int daysBefore, bool enable, PaymentReminderModel? existing) async {
    final repo = ref.read(creditCardRepoProvider);

    if (existing != null) {
      await repo.updateReminder(existing.copyWith(isEnabled: enable));
    } else {
      final reminder = PaymentReminderModel(
        id: const Uuid().v4(),
        creditCardId: widget.card.id,
        daysBefore: daysBefore,
        isEnabled: enable,
      );
      await repo.insertReminder(reminder);
    }

    if (enable) {
      await NotificationService.instance
          .schedulePaymentReminder(widget.card, daysBefore);
    } else {
      await NotificationService.instance
          .cancelReminder(widget.card.id.hashCode + daysBefore);
    }

    refreshCreditCards(ref);
    ref.invalidate(_remindersProvider(widget.card.id));
  }
}
