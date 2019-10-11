import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:connectivity/connectivity.dart';

import 'package:squazzle/data/api/mess_event_bus.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class HomeMatchListBloc
    extends BlocEventStateBase<HomeMatchListEvent, HomeMatchListState> {
  final HomeMatchListRepo _repo;
  final MessagingEventBus _messEventBus;
  StreamSubscription _connectivitySubs, _challengeSubs, _winnerSubs;

  final _connChangeSub = BehaviorSubject<bool>();
  Stream<bool> get connChange => _connChangeSub.stream;

  HomeMatchListBloc(this._repo, this._messEventBus)
      : super(initialState: HomeMatchListState.fetching());

  void setup() async {
    ConnectivityResult curr = await Connectivity().checkConnectivity();
    bool prev = curr == ConnectivityResult.none ? false : true;
    _connChangeSub.add(prev);
    _connectivitySubs = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none && prev) {
        _connChangeSub.add(false);
        prev = false;
      }
      if (result != ConnectivityResult.none && !prev) {
        _connChangeSub.add(true);
        prev = true;
      }
    });
  }

  @override
  Stream<HomeMatchListState> eventHandler(
      HomeMatchListEvent event, HomeMatchListState currentState) async* {
    switch (event.type) {
      case HomeMatchListEventType.start:
        listenToMessages();
        emitEvent(
            HomeMatchListEvent(type: HomeMatchListEventType.updateMatches));
        break;
      case HomeMatchListEventType.updateMatches:
        yield HomeMatchListState(type: HomeMatchListStateType.fetching);
        try {
          await _repo.updateMatches();
          List<ActiveMatch> activeMatches = await _repo.getActiveMatches();
          List<PastMatch> pastMatches = await _repo.getPastMatches();
          if (activeMatches.isNotEmpty || pastMatches.isNotEmpty) {
            yield HomeMatchListState(
                type: HomeMatchListStateType.init,
                activeMatches: activeMatches.isNotEmpty ? activeMatches : [],
                pastMatches: pastMatches.isNotEmpty ? pastMatches : []);
          } else {
            yield HomeMatchListState(type: HomeMatchListStateType.empty);
          }
        } catch (e) {
          yield HomeMatchListState(
              type: HomeMatchListStateType.error,
              message: 'Error fetching matches information');
          print(e);
        }
        break;
      default:
    }
  }

  void listenToMessages() {
    if (_challengeSubs == null && _winnerSubs == null) {
      _challengeSubs =
          _messEventBus.on<ChallengeMessage>().listen((mess) async {
        print('pageviewlist challenge');
        emitEvent(
            HomeMatchListEvent(type: HomeMatchListEventType.updateMatches));
      });
      _winnerSubs = _messEventBus.on<WinnerMessage>().listen((mess) async {
        print('pageviewlist winner');
        emitEvent(
            HomeMatchListEvent(type: HomeMatchListEventType.updateMatches));
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubs.cancel();
    _challengeSubs.cancel();
    _winnerSubs.cancel();
    super.dispose();
  }
}