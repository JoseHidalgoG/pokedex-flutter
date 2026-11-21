const abilityEffectMaxLength = 160;

const _ellipsis = '…';

final _trailingPunctuation = RegExp(r'[\s,;:.]+$');

String trimmedEffect(String text, {int maxLength = abilityEffectMaxLength}) {
  final effect = text.trim();
  if (effect.length <= maxLength) {
    return effect;
  }
  final lastSpace = effect.substring(0, maxLength).lastIndexOf(' ');
  final kept = lastSpace > 0
      ? effect.substring(0, lastSpace)
      : effect.substring(0, maxLength - _ellipsis.length);
  return '${kept.replaceFirst(_trailingPunctuation, '')}$_ellipsis';
}
