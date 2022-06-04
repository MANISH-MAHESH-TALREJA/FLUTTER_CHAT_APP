import 'package:flutter/widgets.dart';
import 'package:my_flutter_web_chat_app/model/user_model.dart';
import 'package:my_flutter_web_chat_app/service/user_service/user_service.dart';
import 'package:my_flutter_web_chat_app/utils/app_state.dart';

class UserProvider with ChangeNotifier {
  UserModel _user;
  UserService _userService = UserService();

  UserModel get getUser => _user;

  Future<void> refreshUser() async {
    UserModel user =  _userService.getUserModel(appState.currentUser.uid) as UserModel;
    _user = user;
    notifyListeners();
  }
}
