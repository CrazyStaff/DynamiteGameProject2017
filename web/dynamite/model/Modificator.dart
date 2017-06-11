import 'Entity.dart';
import 'Position.dart';

class Modificator {
  List<List<List<Entity>>> _addEntities;
  List<List<List<Entity>>> _removeEntities;

   Modificator._construct(int fieldWidth, int fieldHeight) {
     _generateEmptyGameField(_addEntities, fieldWidth, fieldHeight);
     _generateEmptyGameField(_removeEntities, fieldWidth, fieldHeight);
   }

   static Modificator buildModificator(List<List<List<Entity>>> gameField) {
     int fieldWidth = gameField[0].length;
     int fieldHeight = gameField.length;

      return new Modificator._construct(fieldWidth, fieldHeight);
   }

   void addRemovable(Entity entity, Position position) { // TODO abfangen von ungültigen Positionswerten
      _removeEntities[position.getX][position.getY].add(entity);
   }

  void addAddable(Entity entity, Position position) { // TODO abfangen von ungültigen Positionswerten
      _addEntities[position.getX][position.getY].add(entity);
  }

  void executeChangesTo(List<List<List<Entity>>> field) { // TODO rename
    _executeChangesFromList(_addEntities, field);
    _executeChangesFromList(_removeEntities, field);
  }

  void _executeChangesFromList(List<List<List<Entity>>> changedEntities, List<List<List<Entity>>> field) { // TODO renameS
    int fieldWidth = field[0].length;
    int fieldHeight = field.length;

     for (int height = 0; height < fieldHeight; height++) {
      for (int width = 0; width < fieldWidth; width++) {
        List<Entity> currentField = changedEntities[width][height];

        for(Entity entity in currentField) {
          //field[height][width].remove(entity);
        }
      }
    }
  }


  void _generateEmptyGameField(List<List<List<Entity>>> gameField, int fieldWidth, int fieldHeight) {
    gameField = new Iterable.generate(fieldWidth, (row) {
      return new Iterable.generate(fieldHeight, (col) => new List<Entity>()).toList();
    }).toList();
  }
}