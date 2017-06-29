import 'DynamiteView.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'model/DynamiteGame.dart';
import 'model/GameState.dart';
import 'model/Movement.dart';

const configFile = "data/config/config.json";
const configLevel = "data/level/level";

class DynamiteGameController {

  Timer gameTrigger;
  static Duration gameSpeed;
  static int maxLvl = 0;
  DynamiteGame game;
  final view = new DynamiteView();
  //static int lvl = 1;
  static int startLvl = 0;
  static int startLife = 3;
  String levelBeschreibung = "";

  DynamiteGameController()  {
    game = new DynamiteGame(1, 1, 1);
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

      switch (view.startButton.getAttribute("class")) {
        case "init":
          view.startButton.setAttribute("value", "❚❚");
          view.startButton.setAttribute("class", "running");
          DynamiteGame.gameStatus = GameState.RUNNING;
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
      switch (ev.keyCode) {
        case KeyCode.LEFT:
          _movePlayer(left);
          break;
        case KeyCode.RIGHT:
          _movePlayer(right);
          break;
        case KeyCode.UP:
          _movePlayer(up);
          break;
        case KeyCode.DOWN:
          _movePlayer(down);
          break;
        case KeyCode.SPACE:
          placeDynamite();
          break;
      }
    });

      // listen on smartphone arrows
      view.arrowUp.onClick.listen((_) => _movePlayer(up));
      view.arrowRight.onClick.listen((_) => _movePlayer(right));
      view.arrowDown.onClick.listen((_) => _movePlayer(down));
      view.arrowLeft.onClick.listen((_) => _movePlayer(left));
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
      startLife = configs["startLeben"];
      DynamiteGame.life = startLife;
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
    HttpRequest.getString(configLevel + game.currentLevel.toString() + ".json").then((json) {
      Map parsedMap = JSON.decode(json);

      int fieldWidth = int.parse(parsedMap["level"]["field_width"]);
      int fieldHeight = int.parse(parsedMap["level"]["field_height"]);
      List blocks = parsedMap["level"]["blocks"];
      levelBeschreibung = parsedMap["discription"];

      print("Lvl geladen. ${game.currentLevel}");

      game = new DynamiteGame(fieldWidth, fieldHeight, game.currentLevel);
      game.initLevel(blocks, fieldWidth, fieldHeight);
      if(game.currentLevel == 1) {
        DynamiteGame.gameStatus = GameState.PAUSED;
      }

      view.update(game.getHTML());

      if(!parsedMap.containsKey("exp_monster") &&
         !parsedMap.containsKey("exp_destroyable_block")) {
        throw new Exception("Level ${game.currentLevel} should have an EXP section");
      }
      int expMonster = int.parse(parsedMap["exp_monster"]);
      int expDestroyableBlock = int.parse(parsedMap["exp_destroyable_block"]);

      game.initScore(expMonster, expDestroyableBlock);

      view.updateScore(game.getScorePercentage());
    });
  }

  void _moveEntities() {
    if (DynamiteGame.gameStatus == GameState.RUNNING) {
      game.moveAllEntites(new DateTime.now().millisecondsSinceEpoch);
      view.update(game.getHTML());
      view.updateScore(game.getScorePercentage());
    } else {
      if(DynamiteGame.gameStatus != GameState.PAUSED) {
        if (DynamiteGame.life >= 1 && DynamiteGame.gameStatus == GameState.LOOSE) {
          _finishedOverview();
        } else {
          view.showLevelOverview(game.getScoreHTML());
          view.overviewAccept.onClick.listen((_) => _finishedOverview()); // listen on nextButton
        }
      }
    }

  }
  void _finishedOverview() {
    view.hideLevelOverview();

    if (DynamiteGame.gameStatus == GameState.WIN){
      nextLvl();
    } else if (DynamiteGame.gameStatus == GameState.LOOSE){
      DynamiteGame.life--;
      DynamiteGame.DYNAMITE_RADIUS = 1;
      if (DynamiteGame.life < 1){
        DynamiteGame.life = startLife;
        if (game.currentLevel > startLvl) {
          game.currentLevel = startLvl;
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
    game.currentLevel+=1;
    if (game.currentLevel > maxLvl){
      view.update("<h1 id='gewonnen'>GEWONNEN!</h1>");
      DynamiteGame.gameStatus = GameState.MAX_LEVEL_REACHED;
    }else {
      Future.wait([_loadLevel()
      ]).then(_initGame);
    }
  }

  void noMoreLvl(){

  }

  /*
     Proofs if the game is running before trying to move the player
   */
  void _movePlayer(Function moveFunc) {
    if(DynamiteGame.gameStatus == GameState.RUNNING) {
      moveFunc();
    }
  }

  void up() {
    game.setNextMovePlayer(Movement.UP);
  }

  void down() {
    game.setNextMovePlayer(Movement.DOWN);
  }

  void left() {
    game.setNextMovePlayer(Movement.LEFT);
  }

  void right() {
    game.setNextMovePlayer(Movement.RIGHT);
  }

  void pauseGame() {
    game.pauseGame();
  }

  void continueGame() {
    game.continueGame();
  }

  void placeDynamite() {
    if(DynamiteGame.gameStatus == GameState.RUNNING) {
      game.placeDynamite();
    }
  }
}