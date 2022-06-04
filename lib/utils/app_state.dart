import 'package:my_flutter_web_chat_app/model/user_model.dart';

class AppState {
  static final AppState _singleton = AppState._internal();

  factory AppState() {
    return _singleton;
  }

  AppState._internal();

  UserModel currentUser;

  String currentActiveRoom;
}

AppState appState = AppState();
