import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_flutter_web_chat_app/model/group_model.dart';
import 'package:my_flutter_web_chat_app/model/user_model.dart';
import 'package:my_flutter_web_chat_app/screen/person/chat_screen/chat_screen.dart'
    as Person;
import 'package:my_flutter_web_chat_app/screen/group/chat_screen/chat_screen.dart'
    as Group;
import 'package:my_flutter_web_chat_app/screen/home/home_screen.dart';
import 'package:my_flutter_web_chat_app/screen/landing/landing_screen.dart';
import 'package:my_flutter_web_chat_app/service/auth_service/auth_service.dart';
import 'package:my_flutter_web_chat_app/service/provider/image_upload_provider.dart';
import 'package:my_flutter_web_chat_app/service/provider/user_provider.dart';
import 'package:my_flutter_web_chat_app/utils/app.dart';
import 'package:my_flutter_web_chat_app/utils/app_state.dart';
import 'package:my_flutter_web_chat_app/utils/debug.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await firebaseMessaging();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
  ));

  // set development mode true or false
  Debug.isDevelopment = true;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      builder: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
          ],
          child: GetMaterialApp(
            title: 'Planty Connect',
            theme: ThemeData(
              fontFamily: 'Nunito',
              cupertinoOverrideTheme: CupertinoThemeData(
                brightness: Brightness.dark,
              ),
            ),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return MediaQuery(
                child: child,
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              );
            },
            home:
                firebaseAuth.currentUser != null ? HomeScreen() : LandingScreen(),
          ),
        );
      },
    );
  }
}

/// firebase messaging integration
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
AndroidNotificationChannel channel;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

Future<void> firebaseMessaging() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    print("onSelectNotification Called");
    if (payload != null) {
      final newPay = jsonDecode(payload);
      if (newPay['isGroup'] == "true") {
        GroupModel groupModel =
            await groupService.getGroupModel(newPay['roomId']);
        Get.offAll(() => new Group.ChatScreen(groupModel, false));
      } else {
        UserModel userModel = await userService.getUserModel(newPay['id']);
        Get.offAll(
            () => new Person.ChatScreen(userModel, false, newPay['roomId']));
      }
    }
  });

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("onMessage Called");
    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;
    Map<String, dynamic> payload = message.data;
    if (appState.currentActiveRoom != message.data['roomId']) {
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: 'launch_background',
              ),
            ),
            payload: jsonEncode(payload));
      }
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print("onMessageOpenedApp Called ");
    await Firebase.initializeApp();
    if (message.data['isGroup'] == "true") {
      appState.currentActiveRoom = message.data['roomId'];
      GroupModel groupModel =
          await groupService.getGroupModel(message.data['roomId']);
      Get.to(() => Group.ChatScreen(groupModel, false));
    } else {
      UserModel userModel = await userService.getUserModel(message.data['id']);
      Get.to(() => Person.ChatScreen(userModel, false, message.data['roomId']));
    }
  });

  FirebaseMessaging.instance
      .getInitialMessage()
      .then((RemoteMessage message) async {
    print("getInitialMessage Called ");
    if (message != null) {
      await Firebase.initializeApp();
      if (message.data['isGroup'] == "true") {
        GroupModel groupModel =
            await groupService.getGroupModel(message.data['roomId']);
        Get.to(() => Group.ChatScreen(groupModel, false));
      } else {
        UserModel userModel =
            await userService.getUserModel(message.data['id']);
        Get.to(
            () => Person.ChatScreen(userModel, false, message.data['roomId']));
      }
    }
  });
}

Future onDidReceiveLocalNotification(
  int id,
  String title,
  String body,
  String payload,
) async {
  print("iOS notification $title $body $payload");
}
