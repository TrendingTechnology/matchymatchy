import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';

abstract class GameRepo {

  Observable<Game> getRandomGame();

  Observable<GameField> getGameField(int id);

  Observable<TargetField> getTargetField(int id);

  Observable<GameField> applyMove(GameField gameField, Move move);

  Observable<bool> checkIfCorrect(GameField gameField, TargetField targetField);

}