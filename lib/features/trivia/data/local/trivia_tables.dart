import 'package:drift/drift.dart';

@DataClassName('TriviaResultRow')
@TableIndex(name: 'trivia_results_by_score', columns: {#score})
class TriviaResultsTable extends Table {
  @override
  String get tableName => 'trivia_results';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get score => integer()();
  IntColumn get correctAnswers => integer()();
  IntColumn get totalQuestions => integer()();
  IntColumn get durationMs => integer()();
  DateTimeColumn get playedAt => dateTime()();
}

@DataClassName('TriviaAnswerRow')
class TriviaAnswersTable extends Table {
  @override
  String get tableName => 'trivia_answers';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get resultId => integer().references(
    TriviaResultsTable,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get pokemonId => integer()();
  BoolColumn get correct => boolean()();
  IntColumn get responseMs => integer()();
}

@DataClassName('AchievementRow')
class AchievementsTable extends Table {
  @override
  String get tableName => 'achievements';

  TextColumn get key => text()();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
