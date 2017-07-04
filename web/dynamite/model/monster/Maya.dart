import '../Modificator.dart';
import '../Position.dart';
import '../Team.dart';
import '../blocks/Dynamite.dart';
import '../pathfinding/FieldNode.dart';
import 'Fastelle.dart';
import 'dart:math';

/*
    The monster Maya drops Dynamite like the player in random time intervals
 */
class Maya extends Fastelle {

  // The entity type identifies the monster as maya
  static const ENTITY_TYPE = "MAYA";

  final int EXPLOSION_RANGE = 2;

  Maya(Position position) : super(position) {
      this.type = ENTITY_TYPE;

      this.viewDirection = DEFAULT_VIEW_DIRECTION;
      setViewDirection();
  }

  /*
      Drops dynamite in random time intervals
      This dynamite harms only entities which are not in team MONSTERS
  */
  @override
  Modificator action(List<List<FieldNode>> _gameField, int time) {
    super.action(_gameField, time);

    if(time - lastActionTime > 1000) {
      Random random = new Random.secure();
      if(random.nextInt(3) == 0) { // 33 % chance for creating Dynamite
        Modificator mod = Modificator.buildModificator(_gameField);

        Dynamite dynamiteOfMonster = new Dynamite(
            position.clone(), EXPLOSION_RANGE);
        List<Team> doNotHarmTeamsByFire = new List<Team>();
        doNotHarmTeamsByFire.add(Team.MONSTERS);
        doNotHarmTeamsByFire.add(Team.OTHER);
        dynamiteOfMonster.doNotHarmThisTeamsByFire(doNotHarmTeamsByFire); // not harmfull
        mod.addAddable(dynamiteOfMonster, position.clone());

        return mod;
      }
      updateLastActionTime();
    }

    return null;
  }
}