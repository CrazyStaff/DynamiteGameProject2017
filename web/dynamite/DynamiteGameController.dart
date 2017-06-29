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
  DynamiteGame game;
  final view = new DynamiteView();

  DynamiteGameController()  {
    game = new DynamiteGame();
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
          game.gameStatus = GameState.RUNNING;
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
      game.maxLvl = configs["maxLvl"];
      gameSpeed = new Duration(milliseconds: configs["gameSpeed"]);
      game.startLvl = configs["startLvl"];
      game.startLife = configs["startLeben"];
      game.setInitLife();
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
      game.levelDescription = parsedMap["discription"];

      print("Lvl geladen. ${game.currentLevel}");
      game.initLevel(blocks, fieldWidth, fieldHeight);

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
      GameState currentGameState = game.moveAllEntites(new DateTime.now().millisecondsSinceEpoch);
      switch(currentGameState) {
        case GameState.RUNNING:
          view.update(game.getHTML());
          view.updateScore(game.getScorePercentage());
          break;
        case GameState.PAUSED: break;
        default:
          _showLevelOverview();
    }
  }

  /*
    Show an overview between level states
   */
  void _showLevelOverview() {
    view.showLevelOverview(game.getScoreHTML());
    view.overviewAccept.onClick.listen((_) => _finishedOverview()); // listen on nextButton
  }

  void _finishedOverview() {
    view.hideLevelOverview();

    switch(game.getStatus()) {
      case GameState.WIN:
        nextLvl();
        break;
      case GameState.LOOSE:
        retry();
        break;
      case GameState.MAX_LEVEL_REACHED:
        retry();
        break;
      default:
    }
  }

  void retry(){
    game.gameStatus = GameState.RUNNING;
    Future.wait([_loadLevel()
    ]).then(_initGame);
  }

  void nextLvl() {
    game.gameStatus = GameState.RUNNING;
    game.increaseLevel();
      Future.wait([_loadLevel()
      ]).then(_initGame);
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
    game.placeDynamite();
  }
}