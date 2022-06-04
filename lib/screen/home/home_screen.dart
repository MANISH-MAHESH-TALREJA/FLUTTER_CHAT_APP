import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_web_chat_app/model/group_model.dart';
import 'package:my_flutter_web_chat_app/model/room_model.dart';
import 'package:my_flutter_web_chat_app/model/user_model.dart';
import 'package:my_flutter_web_chat_app/screen/home/home_view_model.dart';
import 'package:my_flutter_web_chat_app/screen/home/widgets/group_card.dart';
import 'package:my_flutter_web_chat_app/screen/home/widgets/user_card.dart';
import 'package:my_flutter_web_chat_app/utils/app.dart';
import 'package:my_flutter_web_chat_app/utils/app_state.dart';
import 'package:my_flutter_web_chat_app/utils/color_res.dart';
import 'package:my_flutter_web_chat_app/utils/styles.dart';
import 'package:stacked/stacked.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      onModelReady: (model) async {
        model.init();
      },
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, model, child) {
        return appState.currentUser == null
            ? Container(
                child: Center(child: CircularProgressIndicator()),
              )
            : WillPopScope(
          onWillPop: () {
            showConfirmationDialog(
                  () {
                SystemNavigator.pop();
              },
              'Are you sure you want to exit ?',
            );
            return null;
          },
          child: Scaffold(
            backgroundColor: ColorRes.background,
            appBar: AppBar(
              backgroundColor: ColorRes.background,
              elevation: 0,
              title: Text(
                AppRes.appName,
                style: AppTextStyle(
                  color: ColorRes.black,
                  weight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == "create_group") {
                      model.createGroupClick();
                    } else {
                      model.personalChatClick();
                    }
                  },
                  child: Icon(
                    Icons.add_circle_outline,
                    color: ColorRes.black,
                  ),
                  itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'create_group',
                      child: Text(AppRes.create_group),
                    ),
                    const PopupMenuItem<String>(
                      value: 'create_user',
                      child: Text(AppRes.create_personal_chat),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: model.gotoSettingPage,
                  icon: Icon(
                    Icons.more_vert_outlined,
                    color: ColorRes.black,
                  ),
                ),
              ],
            ),
            body: model.isBusy
                ? Center(
              child: Platform.isIOS
                  ? CupertinoActivityIndicator()
                  : CircularProgressIndicator(),
            )
                : StreamBuilder<QuerySnapshot>(
              stream: chatRoomService.streamRooms(),
              builder: (context, roomSnapshot) {
                if (roomSnapshot.hasData) {
                  if (roomSnapshot.data.docs.isEmpty) {
                    return Center(
                      child: Text(
                          AppRes.no_user_or_group_found),
                    );
                  } else {
                    return ListView.builder(
                      itemCount:
                      roomSnapshot.data.docs.length,
                      itemBuilder: (BuildContext context,
                          int index) {
                        RoomModel roomModel =
                        RoomModel.fromMap(roomSnapshot
                            .data.docs[index]
                            .data());
                        if (roomModel.isGroup) {
                          return StreamBuilder<
                              DocumentSnapshot>(
                            stream: groupService
                                .getGroupStream(
                                roomModel.id),
                            builder:
                                (context, groupSnap) {
                              if (groupSnap
                                  .connectionState ==
                                  ConnectionState
                                      .active &&
                                  groupSnap.hasData) {
                                roomModel.groupModel =
                                    GroupModel.fromMap(
                                        groupSnap.data
                                            .data(),
                                        groupSnap
                                            .data.id);
                                return GroupCard(
                                  roomModel,
                                  model.groupClick,
                                  newBadge: roomSnapshot
                                      .data.docs[index]
                                      .get(
                                      "${appState.currentUser.uid}_newMessage"),
                                );
                              } else {
                                return Container();
                              }
                            },
                          );
                        } else {
                          return StreamBuilder<
                              DocumentSnapshot>(
                            stream: userService
                                .getRoomUserStream(
                                roomModel.membersId),
                            builder:
                                (context, personSnap) {
                              if (personSnap
                                  .connectionState ==
                                  ConnectionState
                                      .active &&
                                  personSnap.hasData) {
                                roomModel.userModel =
                                    UserModel.fromMap(
                                        personSnap.data
                                            .data());
                                return UserCard(
                                  roomModel,
                                  model.onUserCardTap,
                                  typing: roomSnapshot
                                      .data.docs[index]
                                      .get(
                                      "${personSnap.data.id}_typing"),
                                  newBadge: roomSnapshot
                                      .data.docs[index]
                                      .get(
                                      "${appState.currentUser.uid}_newMessage"),
                                );
                              } else {
                                return Container();
                              }
                            },
                          );
                        }
                      },
                    );
                  }
                } else {
                  return Center(
                    child: Platform.isIOS
                        ? CupertinoActivityIndicator()
                        : CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
