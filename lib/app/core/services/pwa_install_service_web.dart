import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

extension type _PwaInstallState._(JSObject _) implements JSObject {
  external bool get canInstall;
}

@JS('flutterPwaInstall')
external _PwaInstallState get _state;

@JS('flutterPwaPromptInstall')
external JSPromise<JSBoolean> _promptInstallJS();

@JS('flutterPwaIsStandalone')
external bool _isStandaloneJS();

class PwaInstallService {
  PwaInstallService._() {
    canInstall = ValueNotifier<bool>(_readCanInstall());
    web.window.addEventListener('flutter-pwa-can-install', _onStateChanged);
  }

  static final PwaInstallService instance = PwaInstallService._();

  late final ValueNotifier<bool> canInstall;

  late final JSFunction _onStateChanged = ((web.Event _) {
    canInstall.value = _readCanInstall();
  }).toJS;

  bool _readCanInstall() => !_isStandaloneJS() && _state.canInstall;

  Future<bool> promptInstall() async {
    if (!canInstall.value) return false;
    final accepted = (await _promptInstallJS().toDart).toDart;
    canInstall.value = false;
    return accepted;
  }
}
