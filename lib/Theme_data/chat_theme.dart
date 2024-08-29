import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class Chat_Module_Theme {
  final TextTheme textTheme;

  const Chat_Module_Theme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4282474385),
      surfaceTint: Color(4282474385),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4292273151),
      onPrimaryContainer: Color(4278197054),
      secondary: Color(4282343312),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4292207615),
      onSecondaryContainer: Color(4278197052),
      tertiary: Color(4285551989),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294629629),
      onTertiaryContainer: Color(4280816430),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294834175),
      onSurface: Color(4280097568),
      onSurfaceVariant: Color(4282664782),
      outline: Color(4285822847),
      outlineVariant: Color(4291086032),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281478965),
      inversePrimary: Color(4289382399),
      primaryFixed: Color(4292273151),
      onPrimaryFixed: Color(4278197054),
      primaryFixedDim: Color(4289382399),
      onPrimaryFixedVariant: Color(4280829815),
      secondaryFixed: Color(4292207615),
      onSecondaryFixed: Color(4278197052),
      secondaryFixedDim: Color(4289251583),
      onSecondaryFixedVariant: Color(4280633207),
      tertiaryFixed: Color(4294629629),
      onTertiaryFixed: Color(4280816430),
      tertiaryFixedDim: Color(4292721888),
      onTertiaryFixedVariant: Color(4283907676),
      surfaceDim: Color(4292794592),
      surfaceBright: Color(4294834175),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294505210),
      surfaceContainer: Color(4294110452),
      surfaceContainerHigh: Color(4293715694),
      surfaceContainerHighest: Color(4293321193),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4280501107),
      surfaceTint: Color(4282474385),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4283987368),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4280304499),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4283790760),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4283578968),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4287064972),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      surface: Color(4294834175),
      onSurface: Color(4280097568),
      onSurfaceVariant: Color(4282401610),
      outline: Color(4284243815),
      outlineVariant: Color(4286085763),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281478965),
      inversePrimary: Color(4289382399),
      primaryFixed: Color(4283987368),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4282277006),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4283790760),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4282146190),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4287064972),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4285354866),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292794592),
      surfaceBright: Color(4294834175),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294505210),
      surfaceContainer: Color(4294110452),
      surfaceContainerHigh: Color(4293715694),
      surfaceContainerHighest: Color(4293321193),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278198602),
      surfaceTint: Color(4282474385),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4280501107),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4278198856),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4280304499),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4281342517),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4283578968),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      surface: Color(4294834175),
      onSurface: Color(4278190080),
      onSurfaceVariant: Color(4280362027),
      outline: Color(4282401610),
      outlineVariant: Color(4282401610),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281478965),
      inversePrimary: Color(4293258495),
      primaryFixed: Color(4280501107),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4278463579),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4280304499),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4278201435),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4283578968),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4282065984),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292794592),
      surfaceBright: Color(4294834175),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294505210),
      surfaceContainer: Color(4294110452),
      surfaceContainerHigh: Color(4293715694),
      surfaceContainerHighest: Color(4293321193),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4289382399),
      surfaceTint: Color(4289382399),
      onPrimary: Color(4278857823),
      primaryContainer: Color(4280829815),
      onPrimaryContainer: Color(4292273151),
      secondary: Color(4289251583),
      onSecondary: Color(4278530143),
      secondaryContainer: Color(4280633207),
      onSecondaryContainer: Color(4292207615),
      tertiary: Color(4292721888),
      onTertiary: Color(4282329156),
      tertiaryContainer: Color(4283907676),
      onTertiaryContainer: Color(4294629629),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279505432),
      onSurface: Color(4293321193),
      onSurfaceVariant: Color(4291086032),
      outline: Color(4287533209),
      outlineVariant: Color(4282664782),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293321193),
      inversePrimary: Color(4282474385),
      primaryFixed: Color(4292273151),
      onPrimaryFixed: Color(4278197054),
      primaryFixedDim: Color(4289382399),
      onPrimaryFixedVariant: Color(4280829815),
      secondaryFixed: Color(4292207615),
      onSecondaryFixed: Color(4278197052),
      secondaryFixedDim: Color(4289251583),
      onSecondaryFixedVariant: Color(4280633207),
      tertiaryFixed: Color(4294629629),
      onTertiaryFixed: Color(4280816430),
      tertiaryFixedDim: Color(4292721888),
      onTertiaryFixedVariant: Color(4283907676),
      surfaceDim: Color(4279505432),
      surfaceBright: Color(4282071102),
      surfaceContainerLowest: Color(4279176467),
      surfaceContainerLow: Color(4280097568),
      surfaceContainer: Color(4280360740),
      surfaceContainerHigh: Color(4281018671),
      surfaceContainerHighest: Color(4281742394),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4289842175),
      surfaceTint: Color(4289382399),
      onPrimary: Color(4278195764),
      primaryContainer: Color(4285829575),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4289711359),
      onSecondary: Color(4278195763),
      secondaryContainer: Color(4285698758),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4292985061),
      onTertiary: Color(4280487465),
      tertiaryContainer: Color(4288972713),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      surface: Color(4279505432),
      onSurface: Color(4294965759),
      onSurfaceVariant: Color(4291349204),
      outline: Color(4288717740),
      outlineVariant: Color(4286612364),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293321193),
      inversePrimary: Color(4280895608),
      primaryFixed: Color(4292273151),
      onPrimaryFixed: Color(4278194475),
      primaryFixedDim: Color(4289382399),
      onPrimaryFixedVariant: Color(4279449189),
      secondaryFixed: Color(4292207615),
      onSecondaryFixed: Color(4278194473),
      secondaryFixedDim: Color(4289251583),
      onSecondaryFixedVariant: Color(4279187045),
      tertiaryFixed: Color(4294629629),
      onTertiaryFixed: Color(4280092707),
      tertiaryFixedDim: Color(4292721888),
      onTertiaryFixedVariant: Color(4282723914),
      surfaceDim: Color(4279505432),
      surfaceBright: Color(4282071102),
      surfaceContainerLowest: Color(4279176467),
      surfaceContainerLow: Color(4280097568),
      surfaceContainer: Color(4280360740),
      surfaceContainerHigh: Color(4281018671),
      surfaceContainerHighest: Color(4281742394),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4294703871),
      surfaceTint: Color(4289382399),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4289842175),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294703871),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4289711359),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294965754),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4292985061),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      surface: Color(4279505432),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4294703871),
      outline: Color(4291349204),
      outlineVariant: Color(4291349204),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293321193),
      inversePrimary: Color(4278200665),
      primaryFixed: Color(4292732927),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4289842175),
      onPrimaryFixedVariant: Color(4278195764),
      secondaryFixed: Color(4292667391),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4289711359),
      onSecondaryFixedVariant: Color(4278195763),
      tertiaryFixed: Color(4294761983),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4292985061),
      onTertiaryFixedVariant: Color(4280487465),
      surfaceDim: Color(4279505432),
      surfaceBright: Color(4282071102),
      surfaceContainerLowest: Color(4279176467),
      surfaceContainerLow: Color(4280097568),
      surfaceContainer: Color(4280360740),
      surfaceContainerHigh: Color(4281018671),
      surfaceContainerHighest: Color(4281742394),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.background,
        canvasColor: colorScheme.surface,
      );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}

TextTheme createTextTheme(
    BuildContext context, String bodyFontString, String displayFontString) {
  TextTheme baseTextTheme = Theme.of(context).textTheme;
  TextTheme bodyTextTheme =
      GoogleFonts.getTextTheme(bodyFontString, baseTextTheme);
  TextTheme displayTextTheme =
      GoogleFonts.getTextTheme(displayFontString, baseTextTheme);
  TextTheme textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme;
}
