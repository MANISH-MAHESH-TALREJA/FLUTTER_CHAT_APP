import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_flutter_web_chat_app/model/user_model.dart';
import 'package:my_flutter_web_chat_app/screen/forgot_password/forgot_password_screen.dart';
import 'package:my_flutter_web_chat_app/screen/home/home_screen.dart';
import 'package:my_flutter_web_chat_app/screen/register/sign_up_screen.dart';
import 'package:my_flutter_web_chat_app/utils/app.dart';
import 'package:stacked/stacked.dart';

class SignInViewModel extends BaseViewModel {
  void init() async {}

  final formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void submitButtonTap() async {
    Get.focusScope.unfocus();
    if (formKey.currentState.validate()) {
      setBusy(true);
      final fcmToken = await messagingService.getFcmToken();
      try {
        await authService.signIn(
          UserModel(
            email: emailController.text.trim(),
            fcmToken: fcmToken,
          )..password = passwordController.text,
        );
        Get.offAll(() => HomeScreen());
      } catch (e) {
        setBusy(false);
      }
    }
  }

  String emailValidation(String value) {
    if (value.isEmpty)
      return AppRes.please_enter_email;
    else if (!isEmail(value))
      return AppRes.please_enter_valid_email;
    else
      return null;
  }

  String passwordValidation(String value) {
    if (value.isEmpty)
      return AppRes.please_enter_password;
    else if (value.length < 6)
      return AppRes.please_enter_min_6_characters;
    else
      return null;
  }

  void signUpClick() {
    Get.off(() => SignUpScreen());
  }

  void forgotPasswordClick() {
    Get.to(() => ForgotPasswordScreen());
  }
}
