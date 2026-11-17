import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/pokemon_list_model.dart';
import '../color.dart';
import '../motion/motion.dart';
import '../typography.dart';

/// Gaya tampilan [PokemonCard].
enum PokemonCardStyle {
  /// Kartu kotak untuk grid 2 kolom.
  grid,

  /// Kartu panjang horizontal untuk list 1 kolom.
  list,
}

/// Kartu Pokémon standar PokéAtlas — dipakai di Home, Region Detail, dll.
///
/// Artwork "nyembul" keluar dari bingkai kartu, warna & badge mengikuti tipe
/// asli Pokémon (dari PokemonTypeCubit). Selama tipe belum termuat, kartu
/// menampilkan tag generasi sebagai fallback.
///
/// ```dart
/// PokemonCard(
///   pokemon: item,
///   style: isGrid ? PokemonCardStyle.grid : PokemonCardStyle.list,
///   isFavorite: favorites.contains(item.id),
///   onFavoriteToggle: () => toggleFavorite(item.id),
///   onTap: () => openDetail(item),
/// )
/// ```
class PokemonCard extends StatelessWidget {
  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onTap,
    this.style = PokemonCardStyle.grid,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.types,
  });

  final PokemonListItemModel pokemon;
  final PokemonCardStyle style;
  final VoidCallback onTap;
  final bool isFavorite;

  /// Kalau null, tombol love tidak ditampilkan.
  final VoidCallback? onFavoriteToggle;

  /// Tipe Pokémon. Default: diambil dari indeks tipe asli jika sudah termuat.
  final List<String>? types;

  /// Jarak artwork menyembul di atas kartu grid.
  static const double gridPopOut = 22;

  /// Label generasi (GEN I – GEN IX) berdasarkan nomor Pokédex.
  static String generationTagFor(int? id) {
    if (id == null || id <= 151) return 'GEN I';
    if (id <= 251) return 'GEN II';
    if (id <= 386) return 'GEN III';
    if (id <= 493) return 'GEN IV';
    if (id <= 649) return 'GEN V';
    if (id <= 721) return 'GEN VI';
    if (id <= 809) return 'GEN VII';
    if (id <= 905) return 'GEN VIII';
    return 'GEN IX';
  }

  List<String>? get _resolvedTypes {
    if (types != null && types!.isNotEmpty) return types;
    final id = pokemon.id;
    return PokemonTypeColors.hasRealTypes(id)
        ? PokemonTypeColors.getTypesById(id)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTypes = _resolvedTypes;
    final typeColor = resolvedTypes != null
        ? PokemonTypeColors.getColor(resolvedTypes.first)
        : PokemonTypeColors.getColorById(pokemon.id ?? 1);

    // Warna transisi halus saat tipe asli selesai dimuat
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: typeColor),
      duration: AppMotion.slow,
      curve: AppMotion.standard,
      builder: (context, color, _) {
        final c = color ?? typeColor;
        return Pressable(
          onTap: onTap,
          pressedScale: style == PokemonCardStyle.grid ? 0.96 : 0.975,
          semanticLabel: '${pokemon.capitalizedName}, ${pokemon.formattedId}',
          child: style == PokemonCardStyle.grid
              ? _buildGrid(c, resolvedTypes)
              : _buildList(c, resolvedTypes),
        );
      },
    );
  }

  BoxDecoration _bodyDecoration(Color c, {required double radius}) =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(c.withValues(alpha: 0.16), bgLight),
            Color.alphaBlend(c.withValues(alpha: 0.03), bgLight),
          ],
        ),
        border: Border.all(color: c.withValues(alpha: 0.22), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      );

  Widget _typeRow(Color c, List<String>? resolvedTypes, {double gap = 5}) {
    if (resolvedTypes == null) {
      return _Tag(label: generationTagFor(pokemon.id), color: c);
    }
    return Wrap(
      spacing: gap,
      runSpacing: 4,
      children: [for (final t in resolvedTypes) PokemonTypeBadge(type: t)],
    );
  }

  // ==========================================================================
  // STYLE 1: GRID (kotak, artwork menyembul ke atas)
  // ==========================================================================
  Widget _buildGrid(Color c, List<String>? resolvedTypes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final artSize = constraints.maxWidth * 0.78;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Badan kartu (dimulai sedikit di bawah agar artwork menyembul)
            Positioned.fill(
              top: gridPopOut,
              child: Container(
                decoration: _bodyDecoration(c, radius: 22),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Watermark Pokéball di belakang artwork
                    Positioned(
                      top: -artSize * 0.18,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: PokeballWatermark(
                          size: artSize * 0.95,
                          color: c.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    // Nama, nomor, tipe
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pokemon.formattedId,
                            style: xxsBold.copyWith(
                              fontSize: 10.5,
                              color: c,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            pokemon.capitalizedName,
                            style: smBold.copyWith(
                              fontSize: 15,
                              color: bgDark,
                              height: 1.25,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          _typeRow(c, resolvedTypes),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bayangan lembut di "kaki" artwork
            Positioned(
              top: artSize * 0.86,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: artSize * 0.55,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: RadialGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.12),
                        Colors.black.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Artwork menyembul
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Hero(
                  tag: 'pokemon_${pokemon.id}',
                  child: _PokemonImage(
                    url: pokemon.imageUrl,
                    loaderColor: c,
                    size: artSize,
                    errorSize: 36,
                  ),
                ),
              ),
            ),

            // Tombol love
            if (onFavoriteToggle != null)
              Positioned(
                top: gridPopOut + 2,
                right: 2,
                child: HeartToggle(
                  isActive: isFavorite,
                  onChanged: onFavoriteToggle!,
                ),
              ),
          ],
        );
      },
    );
  }

  // ==========================================================================
  // STYLE 2: LIST (panjang, artwork menyembul di kanan)
  // ==========================================================================
  Widget _buildList(Color c, List<String>? resolvedTypes) {
    const popOut = 12.0;
    return SizedBox(
      height: 118 + popOut,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: popOut,
            child: Container(
              decoration: _bodyDecoration(c, radius: 22).copyWith(
                gradient: LinearGradient(
                  colors: [
                    Color.alphaBlend(c.withValues(alpha: 0.14), bgLight),
                    Color.alphaBlend(c.withValues(alpha: 0.04), bgLight),
                  ],
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned(
                    right: -24,
                    top: -18,
                    child: PokeballWatermark(
                      size: 150,
                      color: c.withValues(alpha: 0.12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 130, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pokemon.formattedId,
                          style: xxsBold.copyWith(
                            fontSize: 11,
                            color: c,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          pokemon.capitalizedName,
                          style: mdBold.copyWith(color: bgDark, fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        _typeRow(c, resolvedTypes, gap: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Artwork menyembul di kanan atas
          Positioned(
            right: 14,
            top: 0,
            bottom: 6,
            child: Hero(
              tag: 'pokemon_${pokemon.id}',
              child: _PokemonImage(
                url: pokemon.imageUrl,
                loaderColor: c,
                size: 112,
                errorSize: 40,
              ),
            ),
          ),

          if (onFavoriteToggle != null)
            Positioned(
              top: popOut + 2,
              right: 2,
              child: HeartToggle(
                isActive: isFavorite,
                size: 16,
                background: bgLight.withValues(alpha: 0.9),
                onChanged: onFavoriteToggle!,
              ),
            ),
        ],
      ),
    );
  }
}

/// Badge tipe Pokémon dengan ikon SVG elemen (assets/images/element/).
class PokemonTypeBadge extends StatelessWidget {
  const PokemonTypeBadge({super.key, required this.type, this.compact = false});

  final String type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = PokemonTypeColors.getColor(type);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 7,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/element/${type.toLowerCase()}.svg',
            width: 11,
            height: 11,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(width: 4),
          Text(
            type,
            style: xxsBold.copyWith(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

/// Garis luar Pokéball tipis untuk dekorasi latar.
class PokeballWatermark extends StatelessWidget {
  const PokeballWatermark({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PokeballPainter(color)),
    );
  }
}

class _PokeballPainter extends CustomPainter {
  _PokeballPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.07;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - stroke / 2;
    final innerRadius = size.width * 0.15;

    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, innerRadius, paint);
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx - innerRadius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + innerRadius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PokeballPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _PokemonImage extends StatelessWidget {
  const _PokemonImage({
    required this.url,
    required this.loaderColor,
    required this.errorSize,
    this.size,
  });

  final String? url;
  final Color loaderColor;
  final double errorSize;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url ?? '',
      width: size,
      height: size,
      fit: BoxFit.contain,
      fadeInDuration: AppMotion.medium,
      placeholder: (_, __) => Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: loaderColor),
        ),
      ),
      errorWidget: (_, __, ___) => Icon(
        Icons.catching_pokemon,
        size: errorSize,
        color: black400,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: xxsBold.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}

/// Toggle kecil Grid ↔ List (pill 2 tombol) — pasangan [PokemonCard].
class PokemonViewToggle extends StatelessWidget {
  const PokemonViewToggle({
    super.key,
    required this.isGrid,
    required this.onChanged,
    this.activeColor = primaryColor,
  });

  final bool isGrid;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: black100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderNeutral.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _item(
            icon: Icons.grid_view_rounded,
            tooltip: 'Grid',
            selected: isGrid,
            onTap: () => onChanged(true),
          ),
          const SizedBox(width: 2),
          _item(
            icon: Icons.view_agenda_rounded,
            tooltip: 'List',
            selected: !isGrid,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String tooltip,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (selected) return;
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: AppMotion.medium,
          curve: AppMotion.standard,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? bgLight : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: AnimatedScale(
            scale: selected ? 1.0 : 0.88,
            duration: AppMotion.medium,
            curve: Curves.easeOutBack,
            child: Icon(
              icon,
              size: 16,
              color: selected ? activeColor : black400,
            ),
          ),
        ),
      ),
    );
  }
}
