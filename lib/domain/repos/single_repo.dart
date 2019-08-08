import 'game_repo.dart';
import 'package:squazzle/data/data.dart';

/// SingleBloc's repository.
class SingleRepo extends GameRepo {
  SingleRepo(LogicProvider logicProvider, DbProvider dbProvider,
      SharedPrefsProvider prefsProvider)
      : super(
            logicProvider: logicProvider,
            dbProvider: dbProvider,
            prefsProvider: prefsProvider);

  @override
  Future<bool> moveDone(GameField gameField, TargetField targetField) =>
      logicProvider.checkIfCorrect(gameField, targetField);

  Future<Match> getMatch(int id) =>
      prefsProvider.restoreMoves().then((_) => dbProvider.getMatch(id));
}
