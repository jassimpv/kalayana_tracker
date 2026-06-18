import 'package:flutter/foundation.dart';

class PwaInstallService {
  PwaInstallService._();

  static final PwaInstallService instance = PwaInstallService._();

  final ValueNotifier<bool> canInstall = ValueNotifier<bool>(false);

  Future<bool> promptInstall() async => false;
}
