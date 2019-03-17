import 'package:rxdart/rxdart.dart';
import 'dart:math';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class SingleBloc extends GameBloc {
  final SingleRepo repo;
  var ran = Random();
  GameField _gameField;
  TargetField _targetField;

  Stream<bool> get correct => correctSubject.stream;
  Stream<int> get moveNumber => moveNumberSubject.stream;

  @override GameField get gameField => _gameField;
  @override set gameField(GameField gameField) => _gameField = gameField;
  @override TargetField get targetField => _targetField;
  @override set targetField(TargetField targetField) => _targetField = targetField;

  SingleBloc(this.repo) : super(repo);

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {
      SquazzleState result;
      int t = ran.nextInt(1000)+1;

      
      //repo.getRandomGame
      //set gamefield
      //set targetfield
      //yield result

      await repo.getGameField(t)
      .handleError((e) => result = SquazzleState.error('error retrieving gamefield from db'))
      .listen((field) {
        gameField = field;
      }).asFuture();
      await repo.getTargetField(t)
      .handleError((e) => result = SquazzleState.error('error retrieving targetfield from db'))
      .listen((target) {
        targetField = target;
        result = SquazzleState.init();
      }).asFuture();
      yield result;
    }
    if (event.type == SquazzleEventType.error) {
      yield SquazzleState(type: SquazzleStateType.error, message: "Error retrieving data.");
    }
  }

  @override
  void dispose() {
    correctSubject.close();
    moveNumberSubject.close();
    super.dispose();
  }
}