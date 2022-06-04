import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_flutter_web_chat_app/screen/group/new_group/select_member/select_members_view_model.dart';
import 'package:my_flutter_web_chat_app/screen/group/new_group/select_member/widgets/user_card.dart';
import 'package:my_flutter_web_chat_app/utils/app.dart';
import 'package:my_flutter_web_chat_app/utils/color_res.dart';
import 'package:my_flutter_web_chat_app/utils/styles.dart';
import 'package:stacked/stacked.dart';

class SelectMembers extends StatelessWidget {
  final bool isGroup;

  SelectMembers(this.isGroup);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SelectMembersViewModel>.reactive(
      onModelReady: (model) async {
        model.init(isGroup);
      },
      viewModelBuilder: () => SelectMembersViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorRes.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Platform.isIOS
                    ? Icons.arrow_back_ios_rounded
                    : Icons.arrow_back_rounded,
                color: ColorRes.dimGray,
              ),
              onPressed: () => Get.back(),
            ),
            title: isGroup
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppRes.newGroup,
                  style: AppTextStyle(
                    color: ColorRes.dimGray,
                    weight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  AppRes.add_participants,
                  style: AppTextStyle(
                    color: ColorRes.dimGray,
                    fontSize: 14,
                  ),
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppRes.new_personal_chat,
                  style: AppTextStyle(
                    color: ColorRes.dimGray,
                    weight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  AppRes.select_person,
                  style: AppTextStyle(
                    color: ColorRes.dimGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          body: model.isBusy
              ? Center(
            child: Platform.isIOS
                ? CupertinoActivityIndicator()
                : CircularProgressIndicator(),
          )
              : ListView.builder(
            itemCount: model.users.length,
            itemBuilder: (context, index) {
              return UserCard(
                user: model.users[index],
                onTap: model.selectUserClick,
                isSelected:
                model.isSelected(model.users[index]),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: model.nextClick,
            child: Icon(
              Icons.navigate_next_rounded,
              color: ColorRes.white,
            ),
            backgroundColor: ColorRes.green,
          ),
        );
      },
    );
  }
}
