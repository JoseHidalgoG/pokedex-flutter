import 'dart:math';
import 'dart:ui';

const _black = Color(0xFF000000);
const _white = Color(0xFFFFFFFF);

double contrastRatioBetween(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = max(firstLuminance, secondLuminance);
  final darker = min(firstLuminance, secondLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}

Color readableTextColorOn(Color background) {
  final onBlack = contrastRatioBetween(_black, background);
  final onWhite = contrastRatioBetween(_white, background);
  return onBlack >= onWhite ? _black : _white;
}
