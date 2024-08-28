import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/loading.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Otp extends StatefulWidget {
  String? title;
  String? verID;
  String? phone;
  String? email;
  String? name;
  String? password;
  Otp({
    Key? key,
    this.title,
    this.verID,
    this.phone,
    this.email,
    this.name,
    this.password,
  }) : super(key: key);

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  //controllers
  TextEditingController _verificationCodeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  List<FocusNode> _otpFocusNodes = List.generate(6, (index) => FocusNode());

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    _otpControllers.forEach((controller) => controller.dispose());
    _otpFocusNodes.forEach((node) => node.dispose());
    super.dispose();
  }

  onTapResend() async {
    var resendCodeResponse = await AuthRepository().sendSMS(widget.phone);

    if (resendCodeResponse == "success") {
      ToastComponent.showDialog(resendCodeResponse!,
          gravity: Toast.center, duration: Toast.lengthLong);
    } else {
      ToastComponent.showDialog(resendCodeResponse!,
          gravity: Toast.center, duration: Toast.lengthLong);
    }
  }

  onPressConfirm() async {
    String code = _otpControllers.map((controller) => controller.text).join();
    Loading.show(context);

    if (code == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.enter_verification_code,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    var verifiedResponse =
        await AuthRepository().verifySMSCode(code, widget.phone!);

    if (verifiedResponse != "success") {
      Loading.close();
      ToastComponent.showDialog("Code not valid. Please try again.",
          gravity: Toast.center, duration: Toast.lengthLong);
      throw Exception(verifiedResponse);
    }

    print("verifiedResponse: $verifiedResponse");

    var signupResponse = await AuthRepository().getSignupResponse(
        widget.name!, widget.email, widget.password!, widget.phone!);

    if (signupResponse.result == false) {
      var message = "";
      signupResponse.message.forEach((value) {
        message += value + "\n";
      });

      ToastComponent.showDialog("Registered Successfully",
          gravity: Toast.center, duration: 3);
    } else {
      ToastComponent.showDialog(signupResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      AuthHelper().setUserData(signupResponse);

      final FirebaseMessaging _fcm = FirebaseMessaging.instance;
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

      if (fcmToken != null) {
        debugPrint("fcmToken: $fcmToken");
        await ProfileRepository().getDeviceTokenUpdateResponse(fcmToken);
      }

      Loading.close();

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Login();
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    final _screen_width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Text(
                    "Verification Code",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: MyTheme.accent_color),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Enter the 6-digit code sent to ${widget.phone}",
                    style: TextStyle(fontSize: 16, color: MyTheme.font_grey),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      6,
                      (index) => SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _otpFocusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: TextStyle(fontSize: 24),
                          decoration: InputDecoration(
                            counterText: "",
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: MyTheme.light_grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: MyTheme.accent_color),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.length == 1 && index < 5) {
                              _otpFocusNodes[index + 1].requestFocus();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: onPressConfirm,
                    child: Text(
                      AppLocalizations.of(context)!.confirm_ucf,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyTheme.accent_color,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: onTapResend,
                      child: Text(
                        AppLocalizations.of(context)!.resend_code_ucf,
                        style: TextStyle(
                            color: MyTheme.accent_color, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
