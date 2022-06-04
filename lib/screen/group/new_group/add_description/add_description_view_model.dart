import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_flutter_web_chat_app/model/group_model.dart';
import 'package:my_flutter_web_chat_app/model/send_notification_model.dart';
import 'package:my_flutter_web_chat_app/model/user_model.dart';
import 'package:my_flutter_web_chat_app/screen/home/home_screen.dart';
import 'package:my_flutter_web_chat_app/utils/app.dart';
import 'package:my_flutter_web_chat_app/utils/app_state.dart';
import 'package:my_flutter_web_chat_app/utils/exception.dart';
import 'package:stacked/stacked.dart';

class AddDescriptionViewModel extends BaseViewModel {
  List<UserModel> members;

  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  File image;

  final ImagePicker picker = ImagePicker();

  init(List<UserModel> users) async {
    setBusy(true);
    this.members = users;
    setBusy(false);
  }

  void doneClick() async {
    Get.focusScope.unfocus();
    if (formKey.currentState.validate()) {
      setBusy(true);

      GroupModel groupModel = GroupModel()..members = [];

      groupModel.name = title.text.trim();
      groupModel.description = description.text.trim();

      List<String> membersId = [];

      members.forEach((element) {
        groupModel.members.add(GroupMember(
          memberId: element.uid,
          isAdmin: false,
        ));
        membersId.add(element.uid);
      });

      membersId.add(appState.currentUser.uid);

      groupModel.members.insert(
          0,
          GroupMember(
            memberId: appState.currentUser.uid,
            isAdmin: true,
          ));

      if (image == null) {
        groupModel.groupImage = null;
      } else {
        String imageUrl = await storageService.uploadGroupIcon(image);
        if (imageUrl == null) {
          groupModel.groupImage = null;
        } else {
          groupModel.groupImage = imageUrl;
        }
      }

      groupModel.createdAt = DateTime.now();
      groupModel.createdBy = appState.currentUser.uid;

      try {
        DocumentReference groupData =
            await groupService.createGroup(groupModel);
        Map<String, dynamic> data = {
          "isGroup": true,
          "id": groupData.id,
          "membersId": membersId,
          "lastMessage": "Tap here",
          "lastMessageTime": DateTime.now(),
          'typing_id': null,
        };
        membersId.forEach((element) {
          data['${element}_newMessage'] = 1;
        });

        List<String> tokenList = members.map((e) => e.fcmToken).toList();
        tokenList.removeWhere((element) => (element == appState.currentUser.fcmToken));

        await chatRoomService.createChatRoom(data);
        membersId.remove(appState.currentUser.uid);
        messagingService.sendNotification(
          SendNotificationModel(
            fcmTokens: tokenList,
            roomId: groupData.id,
            id: groupData.id,
            body: "Tap here to chat",
            title:
                "${appState.currentUser.name} create a group ${groupModel.name}",
            isGroup: true,
          ),
        );
        Get.offAll(() => HomeScreen());
      } catch (e) {}
      setBusy(false);
    }
  }

  void imagePick() async {
    Get.focusScope.unfocus();
    try {
      // ignore: deprecated_member_use
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        image = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      handleException(e);
    }
  }
}
