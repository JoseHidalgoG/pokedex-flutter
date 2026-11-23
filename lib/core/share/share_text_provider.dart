import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

typedef ShareText = Future<void> Function(
  String text, {
  required String subject,
  Rect? origin,
});

final shareTextProvider = Provider<ShareText>(
  (ref) => (text, {required subject, origin}) async {
    await SharePlus.instance.share(
      ShareParams(text: text, subject: subject, sharePositionOrigin: origin),
    );
  },
);
