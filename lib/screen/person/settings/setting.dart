import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_flutter_web_chat_app/screen/person/settings/setting_view_model.dart';
import 'package:my_flutter_web_chat_app/utils/app.dart';
import 'package:my_flutter_web_chat_app/utils/app_state.dart';
import 'package:my_flutter_web_chat_app/utils/color_res.dart';
import 'package:my_flutter_web_chat_app/utils/styles.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

class SettingDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SettingViewModel>.reactive(
      onModelReady: (model) async {
        model.init();
      },
      builder: (context, model, child) {
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (_, __) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 200.h,
                  floating: false,
                  pinned: true,
                  flexibleSpace: LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints constraints) {
                      model.isExpanded =
                          constraints.biggest.height != 80;
                      return FlexibleSpaceBar(
                        background: model.imageLoader
                            ? Center(
                          child: Platform.isIOS
                              ? CupertinoActivityIndicator()
                              : CircularProgressIndicator(),
                        )
                            : InkWell(
                          onTap: model.imageClick,
                          child: appState.currentUser
                              .profilePicture ==
                              null
                              ? Icon(
                            Icons.group,
                            color: ColorRes.dimGray,
                          )
                              : FadeInImage(
                            image: NetworkImage(appState
                                .currentUser
                                .profilePicture),
                            fit: BoxFit.cover,
                            placeholder: AssetImage(
                                AssetsRes.profileImage),
                          ),
                        ),
                      );
                    },
                  ),
                  backgroundColor: ColorRes.white,
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
                ),
              ];
            },
            body: SingleChildScrollView(
              child: Column(
                children: [
                  verticalSpaceSmall,
                  Container(
                    color: ColorRes.white,
                    width: Get.width,
                    padding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                appState.currentUser.name,
                                style: AppTextStyle(
                                  fontSize: 18,
                                  color: ColorRes.black,
                                ),
                              ),
                              Text(
                                "This is not your username or pin. This name \nwill be visible to your contacts.",
                                style: AppTextStyle(
                                  fontSize: 14,
                                  color: ColorRes.dimGray
                                      .withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: model.editTap,
                          child: Icon(
                            Icons.edit,
                            color: ColorRes.green,
                            size: 25,
                          ),
                        )
                      ],
                    ),
                  ),
                  verticalSpaceSmall,
                  InkWell(
                    onTap: model.logoutTap,
                    child: Container(
                      color: ColorRes.white,
                      width: Get.width,
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      child: Row(
                        children: [
                          Icon(
                            Icons.exit_to_app_rounded,
                            color: ColorRes.green,
                            size: 25,
                          ),
                          horizontalSpaceMedium,
                          Text(
                            "Log Out",
                            style: AppTextStyle(
                              fontSize: 18,
                              color: ColorRes.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      viewModelBuilder: () => SettingViewModel(),
    );
  }
}
