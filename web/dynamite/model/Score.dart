import 'Entity.dart';
import 'blocks/DestroyableBlock.dart';
import 'dart:collection';
import 'items/Portal.dart';
import 'monster/Monster.dart';
import 'pathfinding/FieldNode.dart';

class Score {
  Map<String, int> _entityScore;

  int _currentScore;
  int _maxScore;

  Score() {
    _entityScore = new Map<String, int>();
    _currentScore = 0;
    _maxScore = 0;
  }

  void initScore(String entity, int score) {
    _entityScore.putIfAbsent(entity, () => score);
  }

  double calculateScoreInPercentage() {
    if(_maxScore == 0) return 100.0; // 100 percent reached

    return (_currentScore / _maxScore) * 100;
  }

  void updateScore(Entity removedEntity) {
    switch(removedEntity.type) {
      case DestroyableBlock.ENTITY_TYPE:
        _currentScore += _entityScore[DestroyableBlock.ENTITY_TYPE];
        break;
      case Monster.ENTITY_TYPE: // TODO other monsters => specialization classses too
        _currentScore += _entityScore[Monster.ENTITY_TYPE];
        break;
    }
  }

  void calculateMaxScore(List<List<FieldNode>> gameField) {
    // Add unique portal
    //_maxScore += updateScoreMap[Portal.ENTITY_TYPE];

    for (List<FieldNode> allPositions in gameField) {
      for (FieldNode field in allPositions) {
        for (Entity entity in field.getEntities) {
          switch(entity.type) {
            case DestroyableBlock.ENTITY_TYPE:
              _maxScore += _entityScore[DestroyableBlock.ENTITY_TYPE];
              break;
            case Monster.ENTITY_TYPE: // TODO other monsters => specialization classes too
              _maxScore += _entityScore[Monster.ENTITY_TYPE];
              break;
          }
        }
      }
    }
  }
}