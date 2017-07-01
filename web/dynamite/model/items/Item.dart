import '../Entity.dart';
import '../Position.dart';

/*
    This is the abstract class of all items
 */
abstract class Item extends Entity {
  Item(String type, Position position) : super(type, position);
}