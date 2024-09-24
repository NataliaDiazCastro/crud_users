import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/pages/home_page.dart';
import 'package:qr_reader/providers/ui_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.deepPurple;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UiProvider()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Crud Users',
          initialRoute: 'home',
          routes: {'home': (_) => const HomePage()},
          theme: ThemeData(
              primaryColor: primaryColor,
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: primaryColor),
              appBarTheme: const AppBarTheme(backgroundColor: primaryColor),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  selectedItemColor: primaryColor))),
    );
  }
}
