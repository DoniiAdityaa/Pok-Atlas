import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utility/logger.dart';

/// Error handler terpusat untuk seluruh aplikasi PokéAtlas.
///
/// Menangkap:
/// - **Flutter Framework Errors** (rendering, layout, gesture)
/// - **Uncaught Async Errors** (unhandled Future / Zone error)
///
/// Debug → log ke console via [LoggerHelper].
/// Release → kirim ke Firebase Crashlytics.
///
/// ```dart
/// void main() {
///   GlobalErrorHandler.init(() async {
///     await setUpLocator();
///     runApp(const MyApp());
///   });
/// }
/// ```
class GlobalErrorHandler {
  GlobalErrorHandler._();

  static void init(Future<void> Function() appRunner) {
    // 1. Flutter Framework Errors
    FlutterError.onError = _handleFlutterError;

    // 2. Platform / async errors
    PlatformDispatcher.instance.onError = _handlePlatformError;

    // 3. Zone error — safety net terakhir
    runZonedGuarded(() async {
      WidgetsFlutterBinding.ensureInitialized();
      await appRunner();
    }, _handleZoneError);
  }

  // ─── Handlers ────────────────────────────────────────────

  static void _handleFlutterError(FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
    _reportError(
      details.exception,
      details.stack,
      reason: 'Flutter Framework Error',
      context: details.context?.toString(),
    );
  }

  static bool _handlePlatformError(Object error, StackTrace stack) {
    _reportError(error, stack, reason: 'Uncaught Platform Error');
    return true;
  }

  static void _handleZoneError(Object error, StackTrace stack) {
    _reportError(error, stack, reason: 'Uncaught Zone Error');
  }

  // ─── Reporting ───────────────────────────────────────────

  static void _reportError(
    Object error,
    StackTrace? stack, {
    String? reason,
    String? context,
  }) {
    final label = reason ?? 'Unknown Error';
    LoggerHelper.e(
      '[$label]${context != null ? ' ($context)' : ''}',
      error,
      stack,
    );

    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stack ?? StackTrace.current,
        reason: reason,
        fatal: false,
      );
    }
  }

  /// Report error manual dari mana saja di app.
  ///
  /// ```dart
  /// try {
  ///   // operasi berisiko
  /// } catch (e, stack) {
  ///   GlobalErrorHandler.reportError(e, stack, reason: 'Detail fetch');
  /// }
  /// ```
  static void reportError(Object error, StackTrace? stack, {String? reason}) {
    _reportError(error, stack, reason: reason ?? 'Manual Report');
  }
}
