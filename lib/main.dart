import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokeatlas/config/service_locator.dart';
import 'package:pokeatlas/features/home/cubit/home_cubit.dart';
import 'package:pokeatlas/ui/shared_widget/splash_screen.dart';
import 'package:pokeatlas/ui/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setUpLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<HomeCubit>()..getPokemonList(),
        ),
        // Nanti bisa tambah Cubit lain di sini (ExploreCubit, FavoriteCubit, dll)
      ],
      child: MaterialApp(
        title: 'PokéAtlas',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
