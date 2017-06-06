import 'dart:io';
import 'package:rpc/rpc.dart';

final ApiServer _apiServer = new ApiServer();

main() async {
  _apiServer.addApi(new Dynamite());

  HttpServer server = await HttpServer.bind('127.0.0.1', 8080);
  server.listen(_apiServer.httpRequestHandler);
}

@ApiClass(version: 'v1')
class Dynamite {

  // http://localhost:8080/dynamite/v1/world/2/3
  @ApiMethod(method: 'GET', path: 'world/{x}/{y}')
  Terrain getWorldInfo(String x, String y) {

    return new Terrain()..name = "grass"
        ..x = x
        ..y = y;
  }

}

class Terrain {
  String name;
  String x, y;
}