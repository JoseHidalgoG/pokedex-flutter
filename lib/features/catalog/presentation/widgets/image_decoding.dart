import 'package:flutter/widgets.dart';

int decodedPixelsFor(BuildContext context, double logicalSize) {
  return (logicalSize * MediaQuery.devicePixelRatioOf(context)).round();
}
