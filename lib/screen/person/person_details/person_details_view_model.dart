import 'package:get/get.dart';
import 'package:my_flutter_web_chat_app/model/user_model.dart';
import 'package:my_flutter_web_chat_app/utils/app.dart';
import 'package:my_flutter_web_chat_app/utils/app_state.dart';
import 'package:stacked/stacked.dart';

class PersonDetailsViewModel extends BaseViewModel {
  bool isExpanded = true;
  UserModel userModel;
  String roomId;

  init(UserModel userModel, String roomId) async {
    this.userModel = userModel;
    this.roomId = roomId;
  }

  void blockTap() {
    Get.back();
    chatRoomService.updateLastMessage({
      "blockBy": appState.currentUser.uid,
    }, roomId);
  }

  void unBlockTap() {
    Get.back();
    chatRoomService.updateLastMessage({
      "blockBy": null,
    }, roomId);
  }
}
