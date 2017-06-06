// Copyright (c) 2017, Johan. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.


import 'dart:html' hide Node;
import 'dart:convert';
import 'TerrainType.dart';
import 'GameField.dart';
import 'Node.dart';
import 'Constants.dart';

 GameField gameField;

void main() {
  DivElement field = querySelector("#gameField");
  field.setInnerHtml(createGameField());
  field.onClick.listen(doAction);

  loadJSONFile();
}

TerrainType convertToTerrainType(String terrain) {
    switch(terrain) {
      case "E": return TerrainType.EMPTY_FIELD;
      case "B": return TerrainType.BLOCK;
      case "D": return TerrainType.DESTROYABLE_BLOCK;
      case "S": return TerrainType.START_PLAYER; // TODO: remove
      case "T": return TerrainType.TARGET_PLAYER; // TODO: remove
      default: // TODO: log error not found terrain
    }
}

  String createGameField() {
    String data = "<table>";
    for (int y = 0; y < Constants.GAME_FIELD_HEIGHT; y++) {
      data += "<tr>";
      for (int x = 0; x < Constants.GAME_FIELD_WIDTH; x++) {
        data += '<td id="field_${y}_${x}"></td>';
      }
      data += "</tr>";
    }
    return data + "</table>";
  }

  void doAction(MouseEvent event) {
    if (querySelector('#output').text == "changed") {
      querySelector('#output').text = "yeah";
    } else {
      querySelector('#output').text = "changed";
    }
  }

  void loadJSONFile() {
    var url = "levels.json"; // http://127.0.0.1:63342/TestDart/web/
    HttpRequest.getString(url).then(showGameField).catchError(catchError);
  }

  void catchError(Error error) {
    // TODO log file not found
  }

  void showGameField(String response) {
    convertJsonToDart(response);
    gameField.render();
    window.requestAnimationFrame(gameField.updateGame);
  }

  void convertJsonToDart(String jsonData) {
    Map parsedMap = JSON.decode(jsonData);

    int fieldWidth = int.parse(parsedMap["level_1"]["field_width"]);
    int fieldHeight = int.parse(parsedMap["level_1"]["field_height"]);
    int fieldSize = fieldWidth*fieldHeight;
    List blocks = parsedMap["level_1"]["blocks"];

    gameField = new GameField(fieldWidth, fieldHeight);

    for (int idElement = 0; idElement < fieldSize; idElement++) {
      int xPos = idElement % fieldWidth;
      int yPos = (idElement / fieldHeight).toInt();

      Node node = new Node(idElement, xPos, yPos, convertToTerrainType(blocks[idElement]));
      gameField.addNode(node);
    }
  }
