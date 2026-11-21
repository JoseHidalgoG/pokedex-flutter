enum EvolutionTimeOfDay { day, night, dusk }

sealed class EvolutionTrigger {
  const EvolutionTrigger();
}

final class LevelTrigger extends EvolutionTrigger {
  const LevelTrigger(this.level, {this.timeOfDay});

  final int level;
  final EvolutionTimeOfDay? timeOfDay;

  @override
  bool operator ==(Object other) =>
      other is LevelTrigger &&
      other.level == level &&
      other.timeOfDay == timeOfDay;

  @override
  int get hashCode => Object.hash(LevelTrigger, level, timeOfDay);

  @override
  String toString() => 'LevelTrigger($level, timeOfDay: $timeOfDay)';
}

final class ItemTrigger extends EvolutionTrigger {
  const ItemTrigger(this.item);

  final String item;

  @override
  bool operator ==(Object other) => other is ItemTrigger && other.item == item;

  @override
  int get hashCode => Object.hash(ItemTrigger, item);

  @override
  String toString() => 'ItemTrigger($item)';
}

final class TradeTrigger extends EvolutionTrigger {
  const TradeTrigger({this.heldItem});

  final String? heldItem;

  @override
  bool operator ==(Object other) =>
      other is TradeTrigger && other.heldItem == heldItem;

  @override
  int get hashCode => Object.hash(TradeTrigger, heldItem);

  @override
  String toString() => 'TradeTrigger(heldItem: $heldItem)';
}

final class FriendshipTrigger extends EvolutionTrigger {
  const FriendshipTrigger({this.timeOfDay, this.knownMoveType});

  final EvolutionTimeOfDay? timeOfDay;
  final String? knownMoveType;

  @override
  bool operator ==(Object other) =>
      other is FriendshipTrigger &&
      other.timeOfDay == timeOfDay &&
      other.knownMoveType == knownMoveType;

  @override
  int get hashCode => Object.hash(FriendshipTrigger, timeOfDay, knownMoveType);

  @override
  String toString() =>
      'FriendshipTrigger(timeOfDay: $timeOfDay, knownMoveType: $knownMoveType)';
}

final class TimeOfDayTrigger extends EvolutionTrigger {
  const TimeOfDayTrigger(this.timeOfDay, {this.heldItem});

  final EvolutionTimeOfDay timeOfDay;
  final String? heldItem;

  @override
  bool operator ==(Object other) =>
      other is TimeOfDayTrigger &&
      other.timeOfDay == timeOfDay &&
      other.heldItem == heldItem;

  @override
  int get hashCode => Object.hash(TimeOfDayTrigger, timeOfDay, heldItem);

  @override
  String toString() => 'TimeOfDayTrigger($timeOfDay, heldItem: $heldItem)';
}

final class OtherTrigger extends EvolutionTrigger {
  const OtherTrigger(this.method);

  final String? method;

  @override
  bool operator ==(Object other) =>
      other is OtherTrigger && other.method == method;

  @override
  int get hashCode => Object.hash(OtherTrigger, method);

  @override
  String toString() => 'OtherTrigger($method)';
}

class EvolutionNode {
  const EvolutionNode({
    required this.speciesId,
    required this.speciesName,
    this.trigger,
    this.evolutions = const [],
  });

  final int speciesId;
  final String speciesName;
  final EvolutionTrigger? trigger;
  final List<EvolutionNode> evolutions;

  bool get evolves => evolutions.isNotEmpty;
}

typedef ChainSpecies = ({int id, String name});

typedef EvolutionStep = ({
  int fromSpeciesId,
  int toSpeciesId,
  EvolutionTrigger trigger,
});

EvolutionNode? evolutionTreeOf({
  required List<ChainSpecies> species,
  required List<EvolutionStep> steps,
}) {
  final namesById = {for (final member in species) member.id: member.name};
  final stepsFrom = <int, List<EvolutionStep>>{};
  final evolvedIds = <int>{};
  for (final step in steps) {
    if (namesById.containsKey(step.toSpeciesId) &&
        evolvedIds.add(step.toSpeciesId)) {
      stepsFrom.putIfAbsent(step.fromSpeciesId, () => []).add(step);
    }
  }
  final baseIds = [
    for (final member in species)
      if (!evolvedIds.contains(member.id)) member.id,
  ]..sort();
  final baseId = baseIds.firstOrNull;
  if (baseId == null) {
    return null;
  }

  EvolutionNode nodeOf(int speciesId, {EvolutionTrigger? trigger}) {
    final nextSteps = [
      ...?stepsFrom[speciesId],
    ]..sort((first, second) => first.toSpeciesId.compareTo(second.toSpeciesId));
    return EvolutionNode(
      speciesId: speciesId,
      speciesName: namesById[speciesId]!,
      trigger: trigger,
      evolutions: [
        for (final step in nextSteps)
          nodeOf(step.toSpeciesId, trigger: step.trigger),
      ],
    );
  }

  return nodeOf(baseId);
}
