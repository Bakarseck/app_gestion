import 'package:app_gestion/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'theme/colors.dart';

const MaterialColor kSenelecBlue = MaterialColor(0xFF3B3BBE, <int, Color>{
  50: Color(0xFFE3E3F7),
  100: Color(0xFFB9B9E9),
  200: Color(0xFF8B8BD9),
  300: Color(0xFF5D5DC9),
  400: Color(0xFF3B3BBE), // Primary
  500: Color(0xFF3535A8),
  600: Color(0xFF2E2E92),
  700: Color(0xFF26267A),
  800: Color(0xFF1E1E62),
  900: Color(0xFF15154A),
});

const Color kSenelecViolet = Color(0xFF8B2BBE);
const Color kSenelecPink = Color(0xFFFF3B7B);
const Color kSenelecOrange = Color(0xFFFF7B3B);
const Color kSenelecYellow = Color(0xFFFFD23B);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Senelec',
      theme: ThemeData(
        primarySwatch: kSenelecBlue,
        colorScheme: ColorScheme(
          primary: kSenelecBlue,
          onPrimary: Colors.white,
          secondary: kSenelecViolet,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          background: kSenelecYellow.withOpacity(0.05),
          onBackground: Colors.black,
          error: kSenelecPink,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: kSenelecBlue,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            backgroundColor: kSenelecViolet,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
