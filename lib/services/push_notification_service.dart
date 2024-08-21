import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/screens/order_details.dart';
import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:one_context/one_context.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';

final FirebaseMessaging _fcm = FirebaseMessaging.instance;

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  '0', // id
  'High Importance Notifications', // title
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class PushNotificationService {
  Future initialise() async {
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    String? fcmToken = await _fcm.getToken();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    if (fcmToken != null) {
      debugPrint("fcmToken: $fcmToken");
    
          await ProfileRepository().getDeviceTokenUpdateResponse(fcmToken);
    }

    FirebaseMessaging.onMessage.listen((event) async {
      //print("onLaunch: " + event.toString());
      _showMessage(event);
      //(Map<String, dynamic> message) async => _showMessage(message);

      RemoteNotification? notification = event.notification;

      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      var initializationSettingsAndroid = AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // <- default icon name is @mipmap/ic_launcher

      var iosInitializationSetting = DarwinInitializationSettings();

      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: iosInitializationSetting);

      flutterLocalNotificationsPlugin.initialize(initializationSettings);

      const iosNotificatonDetail = DarwinNotificationDetails();

      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        channel.id,
        channel.name,
        playSound: true,
        importance: Importance.max,
        priority: Priority.high,
      );

      var not = NotificationDetails(
          android: androidPlatformChannelSpecifics, iOS: iosNotificatonDetail);

      await flutterLocalNotificationsPlugin.show(
          notification.hashCode, notification!.title!, notification.body, not);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onResume: $message");
      (Map<String, dynamic> message) async => _serialiseAndNavigate(message);
    });
  }

  void _showMessage(RemoteMessage message) {
    //print("onMessage: $message");

    OneContext().showDialog(
      // barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: ListTile(
          title: Text(message.notification!.title!),
          subtitle: Text(message.notification!.body!),
        ),
        actions: <Widget>[
          Btn.basic(
            child: Text('close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Btn.basic(
            child: Text('GO'),
            onPressed: () {
              if (is_logged_in.$ == false) {
                ToastComponent.showDialog("You are not logged in",
                    gravity: Toast.top, duration: Toast.lengthLong);
                return;
              }
              //print(message);
              Navigator.of(context).pop();
              if (message.data['item_type'] == 'order') {
                OneContext().push(MaterialPageRoute(builder: (_) {
                  return OrderDetails(
                      id: int.parse(message.data['item_type_id']),
                      from_notification: true);
                }));
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showNotification(String code) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );

    
      const iosNotificatonDetail = DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosNotificatonDetail,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Password Reset Code',
      ' $code',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void _serialiseAndNavigate(Map<String, dynamic> message) {
    print(message.toString());
    if (is_logged_in.$ == false) {
      OneContext().showDialog(
          // barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: new Text("You are not logged in"),
                content: new Text("Please log in"),
                actions: <Widget>[
                  Btn.basic(
                    child: Text('close'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Btn.basic(
                      child: Text('Login'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        OneContext().push(MaterialPageRoute(builder: (_) {
                          return Login();
                        }));
                      }),
                ],
              ));
      return;
    }
    if (message['data']['item_type'] == 'order') {
      OneContext().push(MaterialPageRoute(builder: (_) {
        return OrderDetails(
            id: int.parse(message['data']['item_type_id']),
            from_notification: true);
      }));
    } // If there's no view it'll just open the app on the first view    }
  }
}
