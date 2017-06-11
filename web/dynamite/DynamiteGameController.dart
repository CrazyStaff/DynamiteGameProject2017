import 'DynamiteView.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'model/DynamiteGame.dart';

const configFile = "data/config/config.json";
const configLevel = "data/level/level1.json"; //

class DynamiteGameController {

  Timer gameTrigger;
  final gameSpeed = const Duration(milliseconds: 30);// milliseconds: 30); // TODO: read from constants file

  var game = new DynamiteGame(10, 7); // TODO read from level file 'fieldWidth' and 'fieldHeight'
  final view = new DynamiteView();

  DynamiteGameController()  {
    view.generateField(game);

    print("LOAD FILES");
    Future.wait([
      _loadConfigs(),
      _loadLevel()
    ]).then(_initGame);
  }

  void _initGame(List<bool> result)  {
    for(bool r in result) {
      if(r == false) {
        // TODO some resources could'nt load properly
        return;
      }
    }

    // New game is started by user
    view.startButton.onClick.listen((_) {
      if (gameTrigger != null) gameTrigger.cancel();

      gameTrigger = new Timer.periodic(gameSpeed, (_) => _moveEntities());

      // game.start(); // TODO?? !!!!!!!!!!!!!!!!!
       view.update(game.getHTML());
    });

    // move player
    window.onKeyDown.listen((KeyboardEvent ev) {
       if (game.isGameStopped) return;
      switch (ev.keyCode) {
        case KeyCode.LEFT:  left(); break;
        case KeyCode.RIGHT: right(); break;
        case KeyCode.UP: up(); break;
        case KeyCode.DOWN: down(); break;
        case KeyCode.SPACE: placeDynamite(); break;
      }
    });
  }

  /*
      Load all game configs from server
   */
  Future<bool> _loadConfigs() async {
    HttpRequest.getString(configFile).then((json) {
      final configs = JSON.decode(json);

      // TODO set all constants to variables
      // gameSpeed = configs["gameSpeed"];
      return true;
    }).catchError((error) => {
      // return false; // TODO return false
    });
  }

  /*
      Load first level
      TODO load next levels later too
   */
  Future<bool> _loadLevel() async {
    HttpRequest.getString(configLevel).then((json) {
      Map parsedMap = JSON.decode(json);

      int fieldWidth = int.parse(parsedMap["level"]["field_width"]);
      int fieldHeight = int.parse(parsedMap["level"]["field_height"]);
      List blocks = parsedMap["level"]["blocks"];

      game.initLevel(blocks, fieldWidth, fieldHeight);
      view.update(game.getHTML());
    });
  }

  void _moveEntities() {
      // TODO zeig alles an
      game.moveAllEntites(new DateTime.now().millisecondsSinceEpoch);
      view.update(game.getHTML());
  }

  void _newGame() {

  }

  void up() {
    print("Move player up");
    game.setNextMovePlayer(0, -1);
  }

  void down() {
    print("Move player down");
    game.setNextMovePlayer(0, 1);
  }

  void left() {
    print("Move player left");
    game.setNextMovePlayer(-1, 0);
  }

  void right() {
    print("Move player right");
    game.setNextMovePlayer(1, 0);
  }

  void pauseGame() {
    game.pauseGame();
  }

  void placeDynamite() {
    game.placeDynamite();
  }
}