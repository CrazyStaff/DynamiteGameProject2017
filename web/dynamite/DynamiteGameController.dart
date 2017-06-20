import 'DynamiteView.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'model/DynamiteGame.dart';
import 'model/GameState.dart';

const configFile = "data/config/config.json";
const configLevel = "data/level/level";

class DynamiteGameController {

  Timer gameTrigger;
  static Duration gameSpeed;
  static int maxLvl = 0;
  static DynamiteGame game = new DynamiteGame(1, 1);
  final view = new DynamiteView();
  static int lvl = 1;
  static int startLvl = 0;
  static int startLeben = 3;

  DynamiteGameController()  {
   /*view.generateField(game);*/
    print("LOAD FILES");
    Future.wait([ _loadConfigs(),
      _loadLevel()
    ]).then(_initGame);
  }

  void _initGame(List<bool> result) {
    print("initGame");
    for (bool r in result) {
      if (r == false) {
        // TODO some resources could'nt load properly
        return;
      }
    }
    view.generateField(game);
    // New game is started by user
    view.startButton.onClick.listen((_) {
      //if (gameTrigger != null) gameTrigger.cancel();

      switch (view.startButton.getAttribute("class")) {
        case "init":
          view.startButton.setAttribute("value", "❚❚");
          view.startButton.setAttribute("class", "running");
          gameTrigger = new Timer.periodic(gameSpeed, (_) => _moveEntities());
          break;
        case "running":
          view.startButton.setAttribute("value", "▶");
          view.startButton.setAttribute("class", "paused");
          gameTrigger.cancel();
          pauseGame();
          break;
        case "paused":
          view.startButton.setAttribute("value", "❚❚");
          view.startButton.setAttribute("class", "running");
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
        case KeyCode.LEFT:
          left();
          break;
        case KeyCode.RIGHT:
          right();
          break;
        case KeyCode.UP:
          up();
          break;
        case KeyCode.DOWN:
          down();
          break;
        case KeyCode.SPACE:
          placeDynamite();
          break;
      }
    });

      // listen on smartphone arrows
      view.arrowUp.onClick.listen((_) => up());
      view.arrowRight.onClick.listen((_) => right());
      view.arrowDown.onClick.listen((_) => down());
      view.arrowLeft.onClick.listen((_) => left());
      view.arrowDynamite.onClick.listen((_) => placeDynamite());
     // view.tooltip.innerHtml = "";
  }

  /*
      Load all game configs from server
   */
  Future<bool> _loadConfigs() async {
    HttpRequest.getString(configFile).then((json) {
      final configs = JSON.decode(json);
      maxLvl = configs["maxLvl"];
      gameSpeed = new Duration(milliseconds: configs["gameSpeed"]);
      startLvl = configs["startLvl"];
      startLeben = configs["startLeben"];
      DynamiteGame.leben = startLeben;
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

      if(!parsedMap.containsKey("exp_monster") &&
         !parsedMap.containsKey("exp_destroyable_block")) {
        throw new Exception("Level $lvl should have an EXP section");
      }
      int expMonster = int.parse(parsedMap["exp_monster"]);
      int expDestroyableBlock = int.parse(parsedMap["exp_destroyable_block"]);

      game.initScore(expMonster, expDestroyableBlock);

      view.updateScore(game.getScorePercentage());
    });
    print("Lvl Geladen");
  }

  void _moveEntities() {
      if (DynamiteGame.gameStatus == GameState.RUNNING) {
        game.moveAllEntites(new DateTime.now().millisecondsSinceEpoch);
        view.update(game.getHTML());
        view.updateScore(game.getScorePercentage());
      }else if (DynamiteGame.gameStatus == GameState.WIN){
        nextLvl();
      }else if (DynamiteGame.gameStatus == GameState.LOOSE){
        DynamiteGame.leben--;
        DynamiteGame.DYNAMITE_RADIUS = 1;
        if (DynamiteGame.leben < 1){
          DynamiteGame.leben = startLeben;
          if (lvl > startLvl) {
            lvl = startLvl;
          }
        }
        retry();
      }else { //Verloren oder so
        noMoreLvl();
      }
  }

  void retry(){
    DynamiteGame.gameStatus = GameState.RUNNING;
    Future.wait([_loadLevel()
    ]).then(_initGame);
  }

  void nextLvl() {
    DynamiteGame.gameStatus = GameState.RUNNING;
    lvl+=1;
    if (lvl > maxLvl){
      view.update("<h1 id='gewonnen'>GEWONNEN!</h1>");
      DynamiteGame.gameStatus = GameState.MAX_LEVEL_REACHED;
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