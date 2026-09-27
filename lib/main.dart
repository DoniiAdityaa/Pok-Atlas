import 'package:flutter/material.dart';
import 'package:pokeatlas/ui/shared_widget/main_navigation.dart';
import 'package:pokeatlas/ui/theme.dart';

void main() {
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
      home: const MainNavigation(),
    );
  }
}
