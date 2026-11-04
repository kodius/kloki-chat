import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zulip/model/push_device.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Enable these checks.  See this property's doc, which is basically
  // an apology for the fact that (for historical reasons) it isn't
  // the default.
  WidgetController.hitTestWarningShouldBeFatal = true;

  // Konvo turns E2EE push off in the app (PushDeviceManager.debugE2eeEnabled);
  // upstream's tests cover that code path, so they run with it on.
  PushDeviceManager.debugE2eeEnabled = true;

  await testMain();
}
