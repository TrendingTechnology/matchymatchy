import 'package:squazzle/data/data.dart';

class HomePageViewListRepo {
  final DbProvider dbProvider;
  final SharedPrefsProvider prefsProvider;
  final ApiProvider apiProvider;

  HomePageViewListRepo(this.dbProvider, this.prefsProvider, this.apiProvider) {
    newActiveMatches = dbProvider.newActiveMatches();
    newPastMatches = dbProvider.newPastMatches();
  }

  Future<List<ActiveMatch>> getActiveMatches() async =>
      await dbProvider.getActiveMatches();

  Future<List<PastMatch>> getPastMatches() async =>
      await dbProvider.getPastMatches();

  Stream<List<ActiveMatch>> newActiveMatches;

  Stream<List<PastMatch>> newPastMatches;
}