import 'package:flutter/widgets.dart';

const detailTwoPaneMinWidth = 840.0;
const detailSidePanelWidth = 360.0;
const detailSidePanelArtworkSize = 200.0;
const _bodyFontSize = 14.0;
const _largeTextScale = 1.3;

bool showsDetailInTwoPanes(double availableWidth) {
  return availableWidth >= detailTwoPaneMinWidth;
}

bool usesLargeTextLayout(BuildContext context) {
  return MediaQuery.textScalerOf(context).scale(_bodyFontSize) >
      _bodyFontSize * _largeTextScale;
}

class MinimumHeightBox extends StatelessWidget {
  const MinimumHeightBox({
    super.key,
    required this.minHeight,
    required this.child,
  });

  final double minHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight >= minHeight) {
          return child;
        }
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            minHeight: minHeight,
            maxHeight: minHeight,
            child: child,
          ),
        );
      },
    );
  }
}
