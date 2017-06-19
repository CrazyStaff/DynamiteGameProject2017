import 'Entity.dart';
import 'Position.dart';
import 'pathfinding/FieldNode.dart';

class Modificator {
  List<List<FieldNode>> _addEntities;
  List<List<FieldNode>> _removeEntities;

  get getRemovedEntities => _removeEntities;

  Modificator._construct(int fieldWidth, int fieldHeight) {
    _addEntities = _generateEmptyGameField(fieldWidth, fieldHeight);
    _removeEntities = _generateEmptyGameField(fieldWidth, fieldHeight);
  }

  static Modificator buildModificator(List<List< FieldNode >> gameField) {
    int fieldWidth = gameField.length;
    int fieldHeight = gameField[0].length;

    return new Modificator._construct(fieldWidth, fieldHeight);
  }

  void addRemovable(Entity entity, Position position) {
   if(!_proofIfPositionIsValid(position)) return;

    List<Entity> entityField = _removeEntities[position.getX][position.getY].getEntities;
    entityField.add(entity);
  }

  void addAddable(Entity entity, Position position) {
    if(!_proofIfPositionIsValid(position)) return;

    List<Entity> entityField = _addEntities[position.getX][position.getY].getEntities;
    entityField.add(entity);
  }

  bool _proofIfPositionIsValid(Position position) {
    int fieldWidth = _addEntities.length;
    int fieldHeight = _addEntities[0].length;
    if(position.getX >= 0 && position.getX < fieldWidth && position.getY >= 0 && position.getY < fieldHeight) {
      return true;
    }
    return false;
  }

  void executeChangesTo(List<List<FieldNode>> field) { // TODO rename
    _executeAddChangesToList(_addEntities, field);
    _executeRemoveChangesToList(_removeEntities, field);
  }

  void _executeAddChangesToList(List<List<FieldNode>> changedEntities, List<List<FieldNode>> listToModify) { // TODO renameS
    int fieldWidth = listToModify.length;
    int fieldHeight = listToModify[0].length;

    for (int width = 0; width < fieldWidth; width++) {
      for (int height = 0; height < fieldHeight; height++) {
        List<Entity> currentField = changedEntities[width][height].getEntities;

        for(Entity entity in currentField) {
          listToModify[width][height].getEntities.add(entity);
        }
      }
    }
  }

  void _executeRemoveChangesToList(List<List< FieldNode >> changedEntities, List<List< FieldNode >> listToModify) { // TODO renameS
    int fieldWidth = listToModify.length;
    int fieldHeight = listToModify[0].length;

    for (int width = 0; width < fieldHeight; width++) {
      for (int height = 0; height < fieldHeight; height++) {
        List<Entity> currentField = changedEntities[width][height].getEntities;

        for(Entity entity in currentField) {
          listToModify[width][height].getEntities.remove(entity);
        }
      }
    }
  }

  List<List< FieldNode >> _generateEmptyGameField(int fieldWidth, int fieldHeight) {
    return new Iterable.generate(fieldWidth, (row) {
      return new Iterable.generate(fieldHeight, (col) => new FieldNode(new Position(row, col)))
          .toList();
    }).toList();
  }
}