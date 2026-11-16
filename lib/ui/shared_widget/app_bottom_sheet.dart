import 'package:flutter/material.dart';
import '../../../ui/color.dart';
import '../../../ui/typography.dart';

/// Handle kecil di atas bottom sheet.
class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        width: 38,
        height: 4.5,
        decoration: BoxDecoration(
          color: black300,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

/// Header reusable untuk bottom sheet: judul + subtitle + tombol close.
class AppSheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leadingIcon;
  final Color? accentColor;
  final VoidCallback onClose;

  const AppSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.accentColor,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? primaryColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accent.withValues(alpha: 0.22),
                  width: 1.2,
                ),
              ),
              child: Center(child: leadingIcon),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: mdBold.copyWith(
                    color: textNeutralPrimary,
                    fontSize: 17,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: xxsRegular.copyWith(color: black500, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(18),
              splashColor: primaryColor50,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderNeutral.withValues(alpha: 0.8),
                    width: 1.1,
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 17,
                  color: black600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
