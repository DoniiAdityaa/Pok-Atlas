import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokeatlas/config/global_error_handler.dart';
import 'package:pokeatlas/config/service_locator.dart';
import 'package:pokeatlas/features/compare/cubit/compare_cubit.dart';
import 'package:pokeatlas/features/detail/cubit/detail_cubit.dart';
import 'package:pokeatlas/features/home/cubit/home_cubit.dart';
import 'package:pokeatlas/features/pokemon_type/cubit/pokemon_type_cubit.dart';
import 'package:pokeatlas/ui/color.dart';
import 'package:pokeatlas/ui/shared_widget/splash_screen.dart';
import 'package:pokeatlas/ui/theme.dart';

void main() {
  GlobalErrorHandler.init(() async {
    await setUpLocator();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Tipe asli tiap Pokémon (warna kartu & badge tipe)
        BlocProvider(
          create: (_) => serviceLocator<PokemonTypeCubit>()..loadTypeIndex(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<HomeCubit>()..getPokemonList(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<DetailCubit>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<CompareCubit>(),
        ),
      ],
      child: BlocListener<PokemonTypeCubit, PokemonTypeState>(
        listener: (context, state) {
          if (state is PokemonTypeLoaded) {
            PokemonTypeColors.applyTypeIndex(state.index);
          }
        },
        child: MaterialApp(
          title: 'Monstra',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
