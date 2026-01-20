import 'package:flutter/material.dart';

// --- Color Palette ---
// Light Mode
const kLightBackground = Color(0xFFE8F5E9); // Light Green background
const kLightSurface = Color(0xFFF1F8F4); // Very light green for cards/surfaces
const kLightAppBar = Color(0xFFF1F8F4);
const kLightBottomNav = Color(0xFFF1F8F4);
const kLightPrimaryText = Color(0xFF1C1C1C); // Charcoal Black
const kLightSecondaryText = Color(0xFF6E6E6E); // Warm Gray
const kLightDisabledText = Color(0xFFAFAFAF); // Light Gray
const kLightPrimaryIcon = Color(0xFF36A76C); // Logo Green primary
const kLightSecondaryIcon = Color(0xFF8E8E8E); // Gray
const kLightDivider = Color(0xFFE0E0E0); // Soft Gray
const kLightAccent = Color(0xFFF5C16C); // Gold / Amber
const kLightBookmark = Color(0xFFC9A24D); // Bookmark/Favorite

// Dark Mode
const kDarkBackground = Color(0xFF0B1F17); // Deep Night Green
const kDarkSurface = Color(0xFF142B22); // Cards, surfaces
const kDarkAppBar = Color(0xFF0B1F17);
const kDarkBottomNav = Color(0xFF0B1F17);
const kDarkPrimaryText = Color(0xFFF3F3F3); // Soft Ivory
const kDarkSecondaryText = Color(0xFFC4C4C4); // Muted Gold Gray
const kDarkDisabledText = Color(0xFF7A7A7A); // Dark Gray
const kDarkPrimaryIcon = Color(0xFF36A76C); // Logo Green
const kDarkSecondaryIcon = Color(0xFF9E9E9E); // Gray
const kDarkDivider = Color(0xFF2F3E38); // Dark Gray
const kDarkAccent = Color(0xFFF5C16C); // Amber
const kDarkBookmark = Color(0xFFC9A24D); // Bookmark/Favorite

// --- Light Theme ---
final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: kLightBackground,
  primaryColor: kLightPrimaryIcon,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: kLightPrimaryIcon,
    onPrimary: Colors.white,
    secondary: kLightAccent,
    onSecondary: Colors.white,
    background: kLightBackground,
    onBackground: kLightPrimaryText,
    surface: kLightSurface,
    onSurface: kLightPrimaryText,
    error: Colors.red,
    onError: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kLightAppBar,
    elevation: 0,
    iconTheme: IconThemeData(color: kLightPrimaryIcon),
    titleTextStyle: TextStyle(
      color: kLightPrimaryText,
      fontWeight: FontWeight.bold,
      fontSize: 22,
      fontFamily: 'Montserrat',
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: kLightBottomNav,
    selectedItemColor: kLightPrimaryIcon,
    unselectedItemColor: kLightSecondaryIcon,
    selectedIconTheme: IconThemeData(color: kLightPrimaryIcon),
    unselectedIconTheme: IconThemeData(color: kLightSecondaryIcon),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
  iconTheme: const IconThemeData(color: kLightPrimaryIcon),
  dividerColor: kLightDivider,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontFamily: 'Montserrat', color: kLightPrimaryText),
    displayMedium: TextStyle(fontFamily: 'Montserrat', color: kLightPrimaryText),
    displaySmall: TextStyle(fontFamily: 'Montserrat', color: kLightPrimaryText),
    headlineLarge: TextStyle(fontFamily: 'Montserrat', color: kLightPrimaryText),
    headlineMedium: TextStyle(fontFamily: 'Montserrat', color: kLightPrimaryText),
    headlineSmall: TextStyle(fontFamily: 'Montserrat', color: kLightPrimaryText),
    titleLarge: TextStyle(fontFamily: 'Montserrat', color: kLightPrimaryText),
    titleMedium: TextStyle(fontFamily: 'Montserrat', color: kLightPrimaryText),
    titleSmall: TextStyle(fontFamily: 'Montserrat', color: kLightSecondaryText),
    bodyLarge: TextStyle(fontFamily: 'Montserrat', color: kLightPrimaryText),
    bodyMedium: TextStyle(fontFamily: 'Montserrat', color: kLightSecondaryText),
    bodySmall: TextStyle(fontFamily: 'Montserrat', color: kLightDisabledText),
    labelLarge: TextStyle(fontFamily: 'Montserrat', color: kLightPrimaryText),
    labelMedium: TextStyle(fontFamily: 'Montserrat', color: kLightSecondaryText),
    labelSmall: TextStyle(fontFamily: 'Montserrat', color: kLightDisabledText),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kLightPrimaryIcon,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kLightBookmark,
      side: const BorderSide(color: kLightBookmark, width: 2),
      textStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: kLightAccent,
      textStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ),
  dividerTheme: const DividerThemeData(color: kLightDivider, thickness: 1),
  highlightColor: kLightPrimaryIcon.withOpacity(0.15),
  splashColor: kLightPrimaryIcon.withOpacity(0.10),
  disabledColor: kLightDisabledText,
  cardColor: kLightSurface,
  hintColor: kLightSecondaryText,
  extensions: <ThemeExtension<dynamic>>[
    const AlAtharCustomColors(
      bookmark: kLightBookmark,
      selected: kLightAccent,
    ),
  ],
);

// --- Dark Theme ---
final ThemeData darkAppTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kDarkBackground,
  primaryColor: kDarkPrimaryIcon,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: kDarkPrimaryIcon,
    onPrimary: Colors.white,
    secondary: kDarkAccent,
    onSecondary: Colors.white,
    background: kDarkBackground,
    onBackground: kDarkPrimaryText,
    surface: kDarkSurface,
    onSurface: kDarkPrimaryText,
    error: Colors.red,
    onError: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kDarkAppBar,
    elevation: 0,
    iconTheme: IconThemeData(color: kDarkPrimaryIcon),
    titleTextStyle: TextStyle(
      color: kDarkPrimaryText,
      fontWeight: FontWeight.bold,
      fontSize: 22,
      fontFamily: 'Montserrat',
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: kDarkBottomNav,
    selectedItemColor: kDarkPrimaryIcon,
    unselectedItemColor: kDarkSecondaryIcon,
    selectedIconTheme: IconThemeData(color: kDarkPrimaryIcon),
    unselectedIconTheme: IconThemeData(color: kDarkSecondaryIcon),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
  iconTheme: const IconThemeData(color: kDarkPrimaryIcon),
  dividerColor: kDarkDivider,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontFamily: 'Montserrat', color: kDarkPrimaryText),
    displayMedium: TextStyle(fontFamily: 'Montserrat', color: kDarkPrimaryText),
    displaySmall: TextStyle(fontFamily: 'Montserrat', color: kDarkPrimaryText),
    headlineLarge: TextStyle(fontFamily: 'Montserrat', color: kDarkPrimaryText),
    headlineMedium: TextStyle(fontFamily: 'Montserrat', color: kDarkPrimaryText),
    headlineSmall: TextStyle(fontFamily: 'Montserrat', color: kDarkPrimaryText),
    titleLarge: TextStyle(fontFamily: 'Montserrat', color: kDarkPrimaryText),
    titleMedium: TextStyle(fontFamily: 'Montserrat', color: kDarkPrimaryText),
    titleSmall: TextStyle(fontFamily: 'Montserrat', color: kDarkSecondaryText),
    bodyLarge: TextStyle(fontFamily: 'Montserrat', color: kDarkPrimaryText),
    bodyMedium: TextStyle(fontFamily: 'Montserrat', color: kDarkSecondaryText),
    bodySmall: TextStyle(fontFamily: 'Montserrat', color: kDarkDisabledText),
    labelLarge: TextStyle(fontFamily: 'Montserrat', color: kDarkPrimaryText),
    labelMedium: TextStyle(fontFamily: 'Montserrat', color: kDarkSecondaryText),
    labelSmall: TextStyle(fontFamily: 'Montserrat', color: kDarkDisabledText),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kDarkPrimaryIcon,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kDarkBookmark,
      side: const BorderSide(color: kDarkBookmark, width: 2),
      textStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: kDarkAccent,
      textStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ),
  dividerTheme: const DividerThemeData(color: kDarkDivider, thickness: 1),
  highlightColor: kDarkPrimaryIcon.withOpacity(0.15),
  splashColor: kDarkPrimaryIcon.withOpacity(0.10),
  disabledColor: kDarkDisabledText,
  cardColor: kDarkSurface,
  hintColor: kDarkSecondaryText,
  extensions: <ThemeExtension<dynamic>>[
    const AlAtharCustomColors(
      bookmark: kDarkBookmark,
      selected: kDarkAccent,
    ),
  ],
);

// --- Custom Theme Extension for Bookmarks/Selected ---
class AlAtharCustomColors extends ThemeExtension<AlAtharCustomColors> {
  final Color? bookmark;
  final Color? selected;
  const AlAtharCustomColors({this.bookmark, this.selected});

  @override
  AlAtharCustomColors copyWith({Color? bookmark, Color? selected}) {
    return AlAtharCustomColors(
      bookmark: bookmark ?? this.bookmark,
      selected: selected ?? this.selected,
    );
  }

  @override
  AlAtharCustomColors lerp(ThemeExtension<AlAtharCustomColors>? other, double t) {
    if (other is! AlAtharCustomColors) return this;
    return AlAtharCustomColors(
      bookmark: Color.lerp(bookmark, other.bookmark, t),
      selected: Color.lerp(selected, other.selected, t),
    );
  }
}
