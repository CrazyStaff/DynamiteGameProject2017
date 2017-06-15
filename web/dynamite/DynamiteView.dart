import 'dart:html';
import 'model/DynamiteGame.dart';

class DynamiteView {

  final game = querySelector("#gameField");
  HtmlElement get startButton => querySelector('#startButton');
  HtmlElement get arrowUp => querySelector('#arrowUp');
  HtmlElement get arrowDown => querySelector('#arrowDown');
  HtmlElement get arrowLeft => querySelector('#arrowLeft');
  HtmlElement get arrowRight => querySelector('#arrowRight');
  HtmlElement get arrowDynamite => querySelector('#arrowDynamite');
  HtmlElement get tooltip => querySelector('#output');

  void update(String gameField) { //
    game.innerHtml = gameField; // TODO: generate in view
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
}