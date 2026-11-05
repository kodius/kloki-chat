import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:zulip/generated/l10n/zulip_localizations.dart';

void main() {
  final hr = lookupZulipLocalizations(const Locale('hr'));

  group('Croatian plurals', () {
    test('one, few, and other forms', () {
      check(hr.userActiveMinutesAgo(1)).equals('Aktivan prije 1 minutu');
      check(hr.userActiveMinutesAgo(3)).equals('Aktivan prije 3 minute');
      check(hr.userActiveMinutesAgo(5)).equals('Aktivan prije 5 minuta');
    });

    test('teens take the other form', () {
      check(hr.userActiveHoursAgo(12)).equals('Aktivan prije 12 sati');
    });

    test('21 takes the one form', () {
      check(hr.seeWhoReactedSheetEmojiNameWithVoteCount('smile', 21))
        .equals('smile: 21 glas');
    });

    test('mark-as-read confirmation', () {
      check(hr.markAsReadComplete(2))
        .equals('2 poruke označene su kao pročitane.');
    });
  });

  test('every string is translated, except the wildcard-mention keywords', () {
    final en = jsonDecode(File('assets/l10n/app_en.arb').readAsStringSync())
      as Map<String, dynamic>;
    final hrArb = jsonDecode(File('assets/l10n/app_hr.arb').readAsStringSync())
      as Map<String, dynamic>;
    final missing = en.keys
      .where((key) => !key.startsWith('@') && !hrArb.containsKey(key))
      .toList();
    // The server knows these mention keywords only in English.
    check(missing).unorderedEquals([
      'wildcardMentionAll',
      'wildcardMentionEveryone',
      'wildcardMentionChannel',
      'wildcardMentionStream',
      'wildcardMentionTopic',
    ]);
  });
}
