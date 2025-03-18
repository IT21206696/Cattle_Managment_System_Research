import 'package:flutter/material.dart';

Color primary = const Color(0xFF3F4851);

class Styles {
  static Color primaryColor = primary;
  static Color primaryAccent = const Color(0xFF2C2A2A);
  static Color secondaryColor = const Color(0xFF145D34);
  static Color secondaryAccent = const Color(0xFF4B8277);
  static Color bgColor = const Color(0xFF1D9ED3);
  static Color warningColor = const Color(0xFFF0932B);
  static Color dangerColor = const Color(0xFFEB4D4B);
  static Color successColor = const Color(0xFF228B00);
  static Color successColor2 = const Color(0xFF4CB170);
  static Color infoColor = const Color(0xFF0687CC);
  // static Color fontColor = const Color(0xFF10161C);
  static Color fontLight = const Color(0xFFD4D4D4);
  static Color fontDark = const Color(0xFF171719);
  static Color fontHighlight = const Color(0xFF94B7B1);
  static Color fontHighlight2 = const Color(0xFF94B7B1);
  static Color shadowColor = const Color(0xFF20252B);

//   Font Styles
  static TextStyle defaultLightFont = TextStyle(fontSize: 14, color: fontLight);
  static TextStyle defaultDarkFont = TextStyle(fontSize: 14, color: fontLight);
  static TextStyle titleLightFont =
      TextStyle(fontSize: 18, color: fontLight, fontWeight: FontWeight.bold);
  static TextStyle titleDarkFont =
      TextStyle(fontSize: 18, color: fontDark, fontWeight: FontWeight.bold);
  static TextStyle subTitleLightFont =
      TextStyle(fontSize: 16, color: fontLight, fontWeight: FontWeight.w300);
  static TextStyle subTitleDarkFont =
      TextStyle(fontSize: 16, color: fontDark, fontWeight: FontWeight.w300);
}
