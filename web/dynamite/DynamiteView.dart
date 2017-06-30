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
  void updateLevel(String currentLevel) {
    lvl.innerHtml = currentLevel;
  }

  /*
      Update the life of the player
   */
  void updateLife(String currentLife) {
    life.innerHtml = currentLife;
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
        //final assignment = field[row][col];
        final pos = "field_${row}_${col}";
        table += "<td id='$pos' ></td>"; //  class='$assignment'
      }
      table += "</tr>";
    }
    table += "</table>";

    game.innerHtml = table;

    // Saves all generated TD elements in field to
    // avoid time intensive querySelector calls in update().
    // Thanks to Johannes Gosch, SoSe 2015.
    /*fields = new List<List<HtmlElement>>(field.length);
    for (int row = 0; row < field.length; row++) {
      fields[row] = [];
      for (int col = 0; col < field[row].length; col++) {
        fields[row].add(game.querySelector("#field_${row}_${col}"));
      }
    }*/
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

   overviewLevel.setAttribute("style", "visibility: visible;");
  }

  /*
      Hide the level description overview
   */
  void hideLevelOverview() {
    overviewLevel.setAttribute("style", "visibility: hidden;");
    overviewLevel.setAttribute("style", "display: none;");
  }
}