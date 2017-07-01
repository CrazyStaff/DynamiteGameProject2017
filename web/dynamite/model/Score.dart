import 'Entity.dart';
import 'blocks/DestroyableBlock.dart';
import 'dart:collection';
import 'items/Portal.dart';
import 'monster/Monster.dart';
import 'pathfinding/FieldNode.dart';

/*
    The score shows the progress of the level
    After f.e. a monster or a block got destroyed
    the player gets some exp for this
 */
class Score {
  Map<String, int> _entityScore;

  int _currentScore;
  int _maxScore;

  Score() {
    resetScore();
  }

  /*
      Resets the score for the next level
   */
  void resetScore() {
    _entityScore = new Map<String, int>();
    _currentScore = 0;
    _maxScore = 0;
  }

  /*
      Initialize the score for the current level
   */
  void initScore(String entity, int score) {
    _entityScore.putIfAbsent(entity, () => score);
  }

  /*
      Calculate the current scroe of the level
   */
  double calculateScoreInPercentage() {
    if(_maxScore == 0) return 100.0;

    return (_currentScore / _maxScore) * 100;
  }

  /*
      Updates the score based on the given entity 'removeEntity'
   */
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

  /*
      Calculates the max score for the current level
   */
  void calculateMaxScore(List<List<FieldNode>> gameField) {
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