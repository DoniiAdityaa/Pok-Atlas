import 'package:flutter/material.dart';
import '../color.dart';
import '../typography.dart';
import 'monstra_mascot.dart';

/// Reusable empty/no-result state untuk PokéAtlas.
/// Digunakan di HomeScreen, RegionDetailScreen, CompareScreen, dll.
class PokemonEmptyState extends StatelessWidget {
  /// Emoji opsional. Null (default) = maskot Monstra yang celingukan.
  final String? emoji;

  /// Judul utama (default: 'No Pokémon Found')
  final String title;

  /// Deskripsi singkat di bawah judul
  final String subtitle;

  /// Teks tombol reset. Null = tidak tampilkan tombol.
  final String? resetLabel;

  /// Callback tombol reset
  final VoidCallback? onReset;

  /// Padding di sekeliling widget
  final EdgeInsetsGeometry padding;

  const PokemonEmptyState({
    super.key,
    this.emoji,
    this.title = 'No Pokémon Found',
    this.subtitle = 'Try adjusting your search or type filter.',
    this.resetLabel,
    this.onReset,
    this.padding = const EdgeInsets.symmetric(horizontal: 40, vertical: 56),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Maskot Monstra (atau emoji kustom bila diberikan)
            if (emoji == null)
              const MonstraConfused(size: 72)
            else
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: black100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(emoji!, style: const TextStyle(fontSize: 34)),
                ),
              ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: smBold.copyWith(
                color: textNeutralPrimary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: smRegular.copyWith(
                fontSize: 13,
                color: black500,
                height: 1.5,
              ),
            ),

            // Reset button (opsional)
            if (resetLabel != null && onReset != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(resetLabel!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textNeutralPrimary,
                  side: const BorderSide(color: borderNeutral, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
