import 'package:flutter/widgets.dart';

/// Motion tokens PokéAtlas.
///
/// Prinsip: gerakan pendek, kurva "decelerate" (cepat di awal, halus di akhir),
/// jarak kecil (12–24px). Animasi menuntun mata, bukan mencuri perhatian.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 560);

  /// Jeda antar elemen pada entrance berurutan (stagger).
  static const Duration stagger = Duration(milliseconds: 60);

  /// Kurva utama untuk elemen yang masuk ke layar (Material 3 emphasized decelerate).
  static const Curve enter = Cubic(0.05, 0.7, 0.1, 1.0);

  /// Kurva standar untuk perubahan state (warna, ukuran).
  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Hormati setting "Reduce Motion" / "Remove animations" di device.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Delay stagger berdasarkan urutan, dibatasi agar item ke-20 tidak menunggu lama.
  static Duration staggerAt(int index, {int maxSteps = 8}) =>
      stagger * (index.clamp(0, maxSteps));
}
