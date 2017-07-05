import 'dart:html';
import 'model/DynamiteGame.dart';
import 'dart:math';
import 'DynamiteGameController.dart';

class DynamiteView {

  final game = querySelector("#gameField");
  final gameElement = querySelector("#gameField td");
  HtmlElement get startButton => querySelector('#mStart');
  HtmlElement get arrowUp => querySelector('#mUp');
  HtmlElement get arrowDown => querySelector('#mDown');
  HtmlElement get arrowLeft => querySelector('#mLeft');
  HtmlElement get arrowRight => querySelector('#mRight');
  HtmlElement get arrowDynamite => querySelector('#mDynamite');
  HtmlElement get score => querySelector('#scores div');
  HtmlElement get lvl => querySelector('#lvl');
  HtmlElement get lvlType => querySelector("#lvlType");
  HtmlElement get life => querySelector('#life');
  HtmlElement get dynamites => querySelector('#dynamites');
  HtmlElement get maxDynamites => querySelector('#maxDynamites');
  HtmlElement get leftTime => querySelector("#leftTime");
  HtmlElement get overviewLevel => querySelector('#level');
  HtmlElement get overviewAccept => querySelector('#level_accept');
  HtmlElement get contentGame => querySelector("#contentGame");

  /*
      Trust all elements and attributes to be updated in the view
   */
  final TrustedNodeValidator trustedValidator = new TrustedNodeValidator();

  /*
        Stores the determined field size so that there
        isn´t needed a refreshing of DynamiteGame every time
   */
  double _lastFieldSize = 0.0;

  /*
      Update the game field
   */
  void update(String gameField) {
    game.setInnerHtml(gameField, validator: trustedValidator);
  }

  /*
      Calculates the maximum field size which is possible
      Returns -1 when field size didn´t change to the last calculation
   */
  double calculateMaxFieldSize(int fieldWidth, int fieldHeight) {
    HtmlElement gameEle = querySelector("#gameField td");

    if(gameEle != null) {
      double fieldSizePossibleWidth = num.parse((contentGame.clientWidth / fieldWidth).toStringAsFixed(4)).toDouble();
      double fieldSizePossibleHeight = num.parse((contentGame.clientHeight / fieldHeight).toStringAsFixed(4)).toDouble();
      double maxFieldSize = min(fieldSizePossibleWidth, fieldSizePossibleHeight);

      /*
          For a greater experience in the view
      */
      if(maxFieldSize >= 100) {
        maxFieldSize = 100.0;
      } else if(maxFieldSize <= 25.0) {
        maxFieldSize = 25.0;
      }

      /*
         Prevention of browsers wrong pixel calculation in table rows
      */
      maxFieldSize-= 0.1;




      if (maxFieldSize != _lastFieldSize) {
        _lastFieldSize = maxFieldSize;
        print("MaxWidth: ${(contentGame.clientWidth / fieldWidth)};"
            "width:${contentGame.clientWidth} Height: ${contentGame.clientHeight}; fH: $fieldHeight MaxHeight: ${(contentGame.clientHeight / fieldHeight)}");
        return maxFieldSize;
      }
    }
    return -1.0;
  }

  /*
  gameEle.setAttribute(
            "style", "width=${maxFieldSize}px; height=${maxFieldSize}px;");

            print("${contentGame.clientWidth} : ${contentGame.clientHeight}");
   */

  /*
      Update the level type
   */
  void updateLevelType(String type) {
    lvlType.innerHtml = type;
  }

  /*
      Update the current level count
   */
  void updateLevel(String currentLevel) {
    lvl.innerHtml = currentLevel;
  }

  /*
      Update the life of the player
   */
  void updateLife(int currentLife) {
    life.innerHtml = "$currentLife";
  }

  /*
    Update remaining dynamites the player can place and his maximum number of dynamites in the HtmlElements
  */
  void updateDynamiteInfo(int dynamites, int maxDynamites) {
    this.dynamites.innerHtml = "$dynamites";
    this.maxDynamites.innerHtml = "$maxDynamites";
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

    String minutes = (min < 10 ? "0$min" : "$min");
    String seconds = (sec < 10 ? "0$sec" : "$sec");
    return "$minutes:$seconds";
  }

  /*
      Update the score of the player
   */
  void updateScore(double scorePercentage) {
    score.setAttribute("style", "width: $scorePercentage%;");
  }

  void generateField(DynamiteGame model) {
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
          // Button´s content is controlled over attribute 'value' and not over innerHTML
          querySelector("#$key").setAttribute("value", value);
        } else {
          querySelector("#$key").innerHtml = value;
        }
    });

    _showElement(overviewLevel);
  }

  /*
      Proofs if the overview is shown
   */
  bool isOverviewShown() {
    if(overviewLevel.getAttribute("style") == "visibility: visible;") {
      return true;
    }
    return false;
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
/*
    Class is used to trust all elements and attributes
    to be manipulated in the DOM-Tree
 */
class TrustedNodeValidator implements NodeValidator {
    bool allowsElement(Element element) => true;
    bool allowsAttribute(element, attributeName, value) => true;
}