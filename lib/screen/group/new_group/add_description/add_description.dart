import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_flutter_web_chat_app/model/user_model.dart';
import 'package:my_flutter_web_chat_app/screen/group/new_group/add_description/add_description_view_model.dart';
import 'package:my_flutter_web_chat_app/screen/group/new_group/add_description/widgets/description_area.dart';
import 'package:my_flutter_web_chat_app/screen/group/new_group/add_description/widgets/user_card.dart';
import 'package:my_flutter_web_chat_app/utils/app.dart';
import 'package:my_flutter_web_chat_app/utils/color_res.dart';
import 'package:my_flutter_web_chat_app/utils/styles.dart';
import 'package:stacked/stacked.dart';

class AddDescription extends StatelessWidget {
  final List<UserModel> members;

  AddDescription(this.members);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddDescriptionViewModel>.reactive(
      onModelReady: (model) async {
        model.init(members);
      },
      viewModelBuilder: () => AddDescriptionViewModel(),
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
            title: Column(
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
                  AppRes.add_description,
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
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      DescriptionArea(
                        title: model.title,
                        description: model.description,
                        image: model.image,
                        imagePick: model.imagePick,
                        formKey: model.formKey,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          verticalSpaceMedium,
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              "${AppRes.participants}: ${model.members.length}",
                              style: AppTextStyle(
                                color: ColorRes.dimGray,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          verticalSpaceTiny,
                          GridView.builder(
                            itemCount: model.members.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return UserCard(
                                user: model.members[index],
                              );
                            },
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: model.doneClick,
            child: Icon(
              Icons.done,
              color: ColorRes.white,
            ),
            backgroundColor: ColorRes.green,
          ),
        );
      },
    );
  }
}
