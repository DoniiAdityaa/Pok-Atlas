import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../color.dart';
import '../typography.dart';

/// Buka bottom sheet dengan gaya standar PokéAtlas
/// (sama seperti sheet "Surprise Pokémon" di Home).
///
/// ```dart
/// showAppSheet(
///   context: context,
///   builder: (sheetContext) => AppSheet(
///     overline: 'GEN I • KANTO',
///     title: 'Kanto Map',
///     child: ...,
///   ),
/// );
/// ```
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  HapticFeedback.lightImpact();
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: builder,
  );
}

/// Kerangka bottom sheet: putih, sudut 32, handle, judul + tombol close.
///
/// Tingginya mengikuti isi (maksimal [maxHeightFactor] layar). Untuk isi yang
/// bisa panjang (list), bungkus dengan [Flexible] + `shrinkWrap: true`.
class AppSheet extends StatelessWidget {
  const AppSheet({
    super.key,
    required this.title,
    required this.child,
    this.overline,
    this.overlineColor = primaryColor,
    this.maxHeightFactor = 0.88,
  });

  final String title;
  final String? overline;
  final Color overlineColor;
  final Widget child;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: media.size.height * maxHeightFactor,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: bgLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          28 + media.viewPadding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 18),
            _SheetTitle(
              title: title,
              overline: overline,
              overlineColor: overlineColor,
            ),
            const SizedBox(height: 16),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4.5,
        decoration: BoxDecoration(
          color: black300,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle({
    required this.title,
    required this.overline,
    required this.overlineColor,
  });

  final String title;
  final String? overline;
  final Color overlineColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (overline != null)
                Text(
                  overline!,
                  style: xsBold.copyWith(
                    color: overlineColor,
                    fontSize: 13,
                    letterSpacing: 0.6,
                  ),
                ),
              Text(
                title,
                style: lBold.copyWith(
                  color: textNeutralPrimary,
                  fontSize: 24,
                  letterSpacing: -0.4,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded, size: 22, color: black400),
          onPressed: () => Navigator.maybePop(context),
        ),
      ],
    );
  }
}
