import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppEstilos {
  // --- TEMA PRINCIPAL DE LA APLICACIÓN USANDO FLEXCOLORSCHEME ---
  // FlexColorScheme facilita la creación de temas consistentes y atractivos.
  // Puedes cambiar `scheme: FlexScheme.mandyRed` por cualquier otro de los esquemas predefinidos.
  static ThemeData get temaClaro => FlexThemeData.light(
    scheme: FlexScheme.ebonyClay,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 7,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      blendOnColors: false,
      useMaterial3Typography: true,
      useM2StyleDividerInM3: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true, // Habilitar Material 3
    swapLegacyOnMaterial3: true,
    // Aquí integramos Google Fonts con el tema.
    // `GoogleFonts.latoTextTheme()` aplicará la fuente "Lato" a todos los textos.
    // Puedes cambiar "lato" por la fuente que prefieras.
    textTheme: GoogleFonts.nunitoSansTextTheme(),
  );

  static ThemeData get temaOscuro => FlexThemeData.dark(
    scheme: FlexScheme.ebonyClay,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 13,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      useMaterial3Typography: true,
      useM2StyleDividerInM3: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3:
    true,
    textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
  );

  // --- ESTILOS ESPECÍFICOS PARA WIDGETS ---

  // Estilo para el CurvedNavigationBar
  static const Color curvedNavBarColor = FlexColor.ebonyClayLightPrimary;
  static const Color curvedNavBarButtonBackgroundColor = FlexColor.ebonyClayLightTertiary;
  static const Color curvedNavBarIconColor = Colors.white;

  // Estilo para el GoogleNavBar
  static final Color gNavBarBackgroundColor = FlexColor.ebonyClayLightPrimary;
  static final Color gNavBarTabBackgroundColor = FlexColor.ebonyClayLightTertiary.withOpacity(0.9);
  static const Color gNavBarActiveColor = Colors.white;
  static const Color gNavBarInactiveColor = Colors.white; // Íconos inactivos en blanco
}
