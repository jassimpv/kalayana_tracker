import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/language_widget.dart';
import 'package:kalayanaexpresstracker/app/core/localization/translation_service.dart';
import 'package:kalayanaexpresstracker/app/core/localization/localized_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/services/guest_rsvp_service.dart';
import 'package:kalayanaexpresstracker/app/data/models/rsvp_response.dart';

class PublicRsvpPage extends StatefulWidget {
  const PublicRsvpPage({super.key});
  @override
  State<PublicRsvpPage> createState() => _PublicRsvpPageState();
}

class _PublicRsvpPageState extends State<PublicRsvpPage> {
  final form = GlobalKey<FormState>();
  final count = TextEditingController(text: '1');
  final special = TextEditingController();
  String status = rsvpStatusConfirmed;
  bool busy = false;
  bool saved = false;
  late final String token =
      Get.parameters['token'] ??
      Uri.tryParse(Uri.base.fragment)?.queryParameters['token'] ??
      '';
  late final Future<DocumentSnapshot<Map<String, dynamic>>> invitation =
      _load();
  Future<DocumentSnapshot<Map<String, dynamic>>> _load() async {
    if (!RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(token)) {
      throw const FormatException('Invalid invitation.');
    }
    return GuestRsvpService.invitations
        .doc(token)
        .get(const GetOptions(source: Source.server));
  }

  @override
  void dispose() {
    count.dispose();
    special.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await GuestRsvpService.invitations.doc(token).update({
        'status': status,
        'attendeeCount': status == rsvpStatusDeclined
            ? 0
            : int.parse(normalizeNumberInput(count.text.trim())),
        'specialRequirements': special.text.trim(),
        'respondedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) setState(() => saved = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: LocalizedText(
              'Unable to save. The invitation may have expired or changed. Please contact your host.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const LocalizedText('Wedding360 RSVP'),
      actions: const [LanguageWidget()],
      automaticallyImplyLeading: false,
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: FutureBuilder(
          future: invitation,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }
            final data = snapshot.data?.data();
            final expiry = data?['expiresAt'];
            if (snapshot.hasError ||
                data == null ||
                expiry is! Timestamp ||
                expiry.toDate().isBefore(DateTime.now())) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: LocalizedText(
                  'This invitation is unavailable or expired. Please ask your host for a new link.',
                ),
              );
            }
            if (saved) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: LocalizedText('Thank you! Your RSVP has been saved.'),
              );
            }
            final maximum = (data['maxAttendees'] as num).toInt();
            return Form(
              key: form,
              child: ListView(
                padding: const EdgeInsets.all(24),
                shrinkWrap: true,
                children: [
                  Text(
                    data['eventName'] as String,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  LocalizedText(
                    'Hello ${data['guestName']}, please let us know whether you can attend.',
                  ),
                  Text(data['venue'] as String),
                  Text(
                    DateTime.tryParse(data['eventDate'] as String) == null
                        ? ''
                        : formatDisplayDate(
                            DateTime.parse(data['eventDate'] as String),
                          ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const LocalizedInputDecoration(
                      labelText: 'Your response',
                    ),
                    items:
                        [
                              rsvpStatusConfirmed,
                              rsvpStatusDeclined,
                              rsvpStatusMaybe,
                            ]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: LocalizedText(value),
                              ),
                            )
                            .toList(),
                    onChanged: busy
                        ? null
                        : (value) => setState(() => status = value!),
                  ),
                  if (status != rsvpStatusDeclined) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: count,
                      keyboardType: TextInputType.number,
                      decoration: LocalizedInputDecoration(
                        labelText: 'Number attending (up to $maximum)',
                      ),
                      validator: (value) {
                        final parsed = int.tryParse(
                          normalizeNumberInput(value?.trim() ?? ''),
                        );
                        return parsed == null || parsed < 1 || parsed > maximum
                            ? TranslationService.translate(
                                'Enter a number from 1 to $maximum',
                              )
                            : null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: special,
                    maxLength: 1000,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const LocalizedInputDecoration(
                      labelText: 'Dietary or accessibility requirements',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: busy ? null : _submit,
                    child: LocalizedText(busy ? 'Saving…' : 'Send RSVP'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}
