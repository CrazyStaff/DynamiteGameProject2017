import 'DynamiteView.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'model/DynamiteGame.dart';

const configFile = "data/config/config.json";
const configLevel = "data/level/level"; //

class DynamiteGameController {

  Timer gameTrigger;
  static Duration gameSpeed;
  static int maxLvl = 0;
  static DynamiteGame game = new DynamiteGame(1, 1);
  final view = new DynamiteView();
  static int lvl = 1;

  DynamiteGameController()  {
   /*view.generateField(game);*/
    print("LOAD FILES");
    Future.wait([ _loadConfigs(),
      _loadLevel()
    ]).then(_initGame);
  }

  void _initGame(List<bool> result)  {
    print("initGame");
    for(bool r in result) {
      if(r == false) {
        // TODO some resources could'nt load properly
        return;
      }
    }
    view.generateField(game);
    // New game is started by user
    view.startButton.onClick.listen((_) {
      //if (gameTrigger != null) gameTrigger.cancel();

      switch(view.startButton.getAttribute("value")) {
        case "Start Game":
          view.startButton.setAttribute("value", "Pause Game");
          gameTrigger = new Timer.periodic(gameSpeed, (_) => _moveEntities());
          break;
        case "Pause Game":
          view.startButton.setAttribute("value", "Continue Game");
          gameTrigger.cancel();
          pauseGame();
          break;
        case "Continue Game":
          view.startButton.setAttribute("value", "Pause Game");
          continueGame();
          gameTrigger = new Timer.periodic(gameSpeed, (_) => _moveEntities());
          break;
      }



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

    // listen on smartphone arrows
    view.arrowUp.onClick.listen((_) => up());
    view.arrowRight.onClick.listen((_) => right());
    view.arrowDown.onClick.listen((_) => down());
    view.arrowLeft.onClick.listen((_) => left());
    view.arrowDynamite.onClick.listen((_) => placeDynamite());
    view.tooltip.innerHtml = "";
  }

  /*
      Load all game configs from server
   */
  Future<bool> _loadConfigs() async {
    HttpRequest.getString(configFile).then((json) {
      final configs = JSON.decode(json);
      maxLvl = configs["maxLvl"];
      gameSpeed = new Duration(milliseconds: configs["gameSpeed"]);
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
    HttpRequest.getString(configLevel + lvl.toString() + ".json").then((json) {
      Map parsedMap = JSON.decode(json);

      int fieldWidth = int.parse(parsedMap["level"]["field_width"]);
      int fieldHeight = int.parse(parsedMap["level"]["field_height"]);
      List blocks = parsedMap["level"]["blocks"];
      game = new DynamiteGame(fieldWidth, fieldHeight);
      game.initLevel(blocks, fieldWidth, fieldHeight);
      view.update(game.getHTML());
    });
    print("Lvl Geladen");
  }

  void _moveEntities() {
      if (DynamiteGame.gameStatus == 1) {
        game.moveAllEntites(new DateTime.now().millisecondsSinceEpoch);
        view.update(game.getHTML());
      }else if (DynamiteGame.gameStatus == 2){
        nextLvl();
      }else if (DynamiteGame.gameStatus == 0){
        retry();
      }else { //Verloren oder so
        noMoreLvl();
      }
  }

  void retry(){
    DynamiteGame.gameStatus = 1;
    Future.wait([_loadLevel()
    ]).then(_initGame);
  }

  void nextLvl() {
    DynamiteGame.gameStatus = 1;
    lvl+=1;
    if (lvl > maxLvl){
      view.update("<h1 id='gewonnen'>GEWONNEN!</h1>");
      DynamiteGame.gameStatus = 3;
    }else {
      Future.wait([_loadLevel()
      ]).then(_initGame);
    }
  }

  void noMoreLvl(){

  }

  void up() {
    print("Move player right");
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

  void continueGame() {
    game.continueGame();
  }

  void placeDynamite() {
    game.placeDynamite();
  }
}