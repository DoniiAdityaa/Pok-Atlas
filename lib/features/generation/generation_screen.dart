import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../ui/color.dart';
import '../../ui/typography.dart';
import 'model/generation_model.dart';
import 'region_detail_screen.dart';
import 'widgets/generation_card.dart';

class GenerationScreen extends StatefulWidget {
  const GenerationScreen({super.key});

  @override
  State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen> {
  final List<GenerationModel> _generations = GenerationData.allGenerations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. App Bar Header
            SliverToBoxAdapter(child: _buildHeader(context)),

            // 2. Summary Badge Bar
            SliverToBoxAdapter(child: _buildSummaryBar()),

            // 3. List Kartu 9 Generasi Pokémon
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final gen = _generations[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: GenerationCard(
                        generation: gen,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RegionDetailScreen(generation: gen),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: _generations.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Header dengan tombol kembali & Pokéball icon
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Kembali Lingkaran
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(22),
              splashColor: primaryColor50,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderNeutral.withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: bgDark,
                ),
              ),
            ),
          ),

          // Judul Tengah
          Column(
            children: [
              Text(
                'Generation Atlas',
                style: mBold.copyWith(
                  color: textNeutralPrimary,
                  fontSize: 18,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '9 Eras of the Pokémon World',
                style: xxsRegular.copyWith(color: black500, fontSize: 11),
              ),
            ],
          ),

          // Sisi Kanan: Spacer penyeimbang (44px) agar judul tetap presisi di tengah
          const SizedBox(width: 44, height: 44),
        ],
      ),
    );
  }

  /// 2. Bar info ringkas total region & total spesies (Responsive & bebas overflow)
  Widget _buildSummaryBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderNeutral, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 13,
                  color: black500,
                ),
                const SizedBox(width: 6),
                Text(
                  '9 Regions',
                  style: xsBold.copyWith(color: textNeutralPrimary),
                ),
                const SizedBox(width: 4),
                Text(
                  '(1996–Present)',
                  style: xxsRegular.copyWith(color: black500, fontSize: 10),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '1,025 Species',
                style: xxsBold.copyWith(
                  color: primaryColor,
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}