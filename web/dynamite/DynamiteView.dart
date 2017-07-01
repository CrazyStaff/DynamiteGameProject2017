import 'dart:html';
import 'model/DynamiteGame.dart';
import 'DynamiteGameController.dart';

class DynamiteView {

  final game = querySelector("#gameField");
  HtmlElement get startButton => querySelector('#mStart');
  HtmlElement get arrowUp => querySelector('#mUp');
  HtmlElement get arrowDown => querySelector('#mDown');
  HtmlElement get arrowLeft => querySelector('#mLeft');
  HtmlElement get arrowRight => querySelector('#mRight');
  HtmlElement get arrowDynamite => querySelector('#mDynamite');
  //HtmlElement get tooltip => querySelector('#output');
  HtmlElement get score => querySelector('#scores div');
  HtmlElement get lvl => querySelector('#lvl');
  HtmlElement get life => querySelector('#life');
  HtmlElement get leftTime => querySelector("#leftTime");
  HtmlElement get overviewLevel => querySelector('#level');
  HtmlElement get overviewAccept => querySelector('#level_accept');

  /*
    Update the gamefield
   */
  void update(String gameField) {
    game.innerHtml = gameField;
  }

  /*
    Update the level count of the player
   */
  void updateLevel(int currentLevel) {
    lvl.innerHtml = "$currentLevel";
  }

  /*
      Update the life of the player
   */
  void updateLife(String currentLife) {
    life.innerHtml = currentLife;
  }

  /*
      Update the left time of the level
   */
  void updateLeftTime(int leftTimeOfLevel) {
    leftTime.innerHtml = _convertTimeView(leftTimeOfLevel);
  }

  void setLeftTimeVisibility(bool visible) {
    if(visible) {
      _showElement(leftTime);
    } else {
      _hideElement(leftTime);
    }
  }

  /*
     Change the view format of the left time
   */
  String _convertTimeView(int leftTime) {
    int min = (leftTime / 60).toInt();
    int sec = leftTime % 60;

    String minutes = (min < 10 ? "0$min" : min);
    String seconds = (sec < 10 ? "0$sec" : sec);
    return "$minutes:$seconds";
  }

  /*
      Update the score of the player
   */
  void updateScore(double scorePercentage) {
    score.setAttribute("style", "width: $scorePercentage%;");
  }

  void generateField(DynamiteGame model) { // TODO use only model.getHTML
    final field = model.getGameField;
    String table = "<table>";
    for (int row = 0; row < field.length; row++) {
      table += "<tr>";
      for (int col = 0; col < field[row].length; col++) {
        final pos = "field_${row}_${col}";
        table += "<td id='$pos' ></td>";
      }
      table += "</tr>";
    }
    table += "</table>";

    game.innerHtml = table;
  }

  /*
    Make the level description overview visible
   */
  void showLevelOverview(Map<String, String> levelState) {
    levelState.forEach((key, value){
        if(value.isEmpty) {
          querySelector("#$key").setAttribute("style", "visibility: hidden;");
        } else {
          querySelector("#$key").setAttribute("style", "visibility: visible;");
        }

        if(key == "level_accept") {
          // button´s content is controlled over attribute 'value' and not over innerHTML
          querySelector("#$key").setAttribute("value", value);
        } else {
          querySelector("#$key").innerHtml = value;
        }
    });

    _showElement(overviewLevel);
  }

  /*
      Hide the level description overview
   */
  void hideLevelOverview() {
    _hideElement(overviewLevel);
  }

  /*
    Don´t show the html element in the view
   */
  void _hideElement(HtmlElement element) {
    element.setAttribute("style", "visibility: hidden;");
    element.setAttribute("style", "display: none;");
  }

  /*
    Show the html element in the view
   */
  void _showElement(HtmlElement element) {
    element.setAttribute("style", "visibility: visible;");
  }
}