import "package:flutter/foundation.dart";

import '../entities/quest_entity.dart';

abstract class QuestRepository extends ChangeNotifier {
  List<Quest> getAllQuests();
  Quest? getQuestById(String id);
  int getTotalQuestsCount();
  int getAvailableQuestsCount();
  int getInProgressQuestsCount();
  int getCompletedQuestsCount();
  bool get isMockDataSource;
  String get dataSourceLabel;
}

abstract interface class QuestProgressWriter {
  void updateProgress(String questId, int completedSeconds);
}
