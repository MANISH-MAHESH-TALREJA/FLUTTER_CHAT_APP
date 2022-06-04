import 'package:flutter/material.dart';
import 'package:my_flutter_web_chat_app/screen/landing/landing_view_model.dart';
import 'package:my_flutter_web_chat_app/utils/app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_web_chat_app/utils/color_res.dart';
import 'package:my_flutter_web_chat_app/utils/common_widgets.dart';
import 'package:my_flutter_web_chat_app/utils/styles.dart';

class LandingScreen extends StatelessWidget {
  final LandingViewModel model = LandingViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AssetsRes.whatsAppIcon,
              height: 50.h,
            ),
            verticalSpaceSmall,
            Text(
              "Planty Connect",
              style: AppTextStyle(
                fontSize: 28,
                color: ColorRes.green,
                weight: FontWeight.bold,
              ),
            ),
            verticalSpaceMassive,
            EvolveButton(title: AppRes.sign_in, onTap: model.loginClick),
            verticalSpaceMedium,
            EvolveButton(title: AppRes.sign_up, onTap: model.registerClick),
          ],
        ),
      ),
    );
  }
}
