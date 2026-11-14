import '../entities/quest_entity.dart';

abstract class QuestRepository {
  List<Quest> getAllQuests();
  Quest? getQuestById(String id);
  int getTotalQuestsCount();
  int getAvailableQuestsCount();
  int getInProgressQuestsCount();
  int getCompletedQuestsCount();
  bool get isMockDataSource;
  String get dataSourceLabel;
}
