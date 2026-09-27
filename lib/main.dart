import 'package:flutter/material.dart';
import 'package:pokeatlas/ui/shared_widget/main_navigation.dart';
import 'package:pokeatlas/config/service_locator.dart';
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
    return MaterialApp(
      title: 'PokéAtlas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/main': (context) => const MainNavigation(),
      },
    );
  }
}
