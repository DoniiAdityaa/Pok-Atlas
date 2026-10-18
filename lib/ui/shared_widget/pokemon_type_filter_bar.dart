import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../color.dart';
import '../pokemon_type_data.dart';
import '../typography.dart';

/// Shared component untuk baris filter elemen tipe Pokémon (All, Fire, Water, Grass, dll.)
/// Konsisten 1:1 antara HomeScreen, Compare Pokémon, dan layar katalog lainnya.
class PokemonTypeFilterBar extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onSelected;
  final bool showTitle;
  final String title;
  final double height;
  final EdgeInsetsGeometry padding;
  final double itemSpacing;
  final bool enableHaptic;

  const PokemonTypeFilterBar({
    super.key,
    required this.selectedType,
    required this.onSelected,
    this.showTitle = false,
    this.title = 'Filter by Element',
    this.height = 38.0,
    this.padding = EdgeInsets.zero,
    this.itemSpacing = 8.0,
    this.enableHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    final listWidget = SizedBox(
      height: height,
      child: ListView.separated(
        padding: padding,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: pokemonTypeList.length,
        separatorBuilder: (context, index) => SizedBox(width: itemSpacing),
        itemBuilder: (context, index) {
          final typeItem = pokemonTypeList[index];
          final isSelected =
              selectedType.toLowerCase() == typeItem.name.toLowerCase();

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (enableHaptic) {
                    HapticFeedback.lightImpact();
                  }
                  onSelected(typeItem.name);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? typeItem.color : bgLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? typeItem.color : borderNeutral,
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: typeItem.color.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ikon Elemen Resmi (SVG / Icon Fallback)
                      if (typeItem.iconAsset != null)
                        SvgPicture.asset(
                          typeItem.iconAsset!,
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(
                            isSelected ? black00 : typeItem.color,
                            BlendMode.srcIn,
                          ),
                        )
                      else
                        Icon(
                          typeItem.fallbackIcon ?? Icons.catching_pokemon,
                          size: 14,
                          color: isSelected ? black00 : typeItem.color,
                        ),
                      const SizedBox(width: 6),

                      // Nama Elemen
                      Text(
                        typeItem.name,
                        style: (isSelected ? xsBold : xsMedium).copyWith(
                          fontSize: 12.5,
                          color: isSelected ? black00 : black700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    if (!showTitle) {
      return listWidget;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            title,
            style: mdBold.copyWith(color: bgDark),
          ),
        ),
        const SizedBox(height: 10),
        listWidget,
      ],
    );
  }
}
