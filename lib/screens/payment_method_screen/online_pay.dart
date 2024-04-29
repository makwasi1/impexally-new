import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/payment_repository.dart';
import 'package:active_ecommerce_flutter/screens/order_list.dart';
import 'package:active_ecommerce_flutter/screens/package/packages.dart';
import 'package:active_ecommerce_flutter/screens/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:toast/toast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OnlinePay extends StatefulWidget {
  String? title;
  double? amount;
  String payment_type;
  String? payment_method_key;
  var package_id;
  OnlinePay(
      {Key? key,
      this.amount = 0.00,
      this.title = "Pay With Instamojo",
      this.payment_type = "",
      this.package_id = "0",
      this.payment_method_key = ""})
      : super(key: key);

  @override
  _OnlinePayState createState() => _OnlinePayState();
}

class _OnlinePayState extends State<OnlinePay> {
  int? _combined_order_id = 0;
  bool _initial_url_fetched = false;

  WebViewController _webViewController = WebViewController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.payment_type == "cart_payment") {
      createOrder();
    } else {
      pay(Uri.parse(
          "${AppConfig.BASE_URL}/online-pay/init?payment_type=${widget.payment_type}&combined_order_id=${_combined_order_id}&wallet_amount=${widget.amount}&payment_option=${widget.payment_method_key}"));
    }
  }

  createOrder() async {
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponse(widget.payment_method_key);

    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }
    _combined_order_id = orderCreateResponse.combined_order_id;
    pay(Uri.parse(
        "${AppConfig.BASE_URL}/online-pay/init?payment_type=${widget.payment_type}&combined_order_id=${_combined_order_id}&wallet_amount=${widget.amount}&payment_option=${widget.payment_method_key}"));
  }

  pay(url) {
    print(url);
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          // onPageStarted: (controller) {
          //   _webViewController.loadRequest(Uri.parse(_initial_url));
          // },
          onWebResourceError: (error) {},
          onPageStarted: (page) {
            print(page);
          },
          onPageFinished: (page) {
            print(page);
            if (page.contains("/online-pay/done")) {
              if (widget.payment_type == "cart_payment") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrderList(
                              from_checkout: true,
                            )));
              } else if (widget.payment_type == "wallet_payment") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Wallet(
                              from_recharge: true,
                            )));
              } else if (widget.payment_type == "customer_package_payment") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UpdatePackage(
                              goHome: true,
                            )));
              }
            }
            if (page.contains("/online-pay/failed")) {
              getData();
              Navigator.pop(context);
            }
          },
        ),
      )
      ..loadRequest(url, headers: {
        "Authorization": "Bearer ${access_token.$}",
        "Content-Type": "application/json",
        "App-Language": app_language.$!,
        "Accept": "application/json",
        "System-Key": AppConfig.system_key
      });
    _initial_url_fetched = true;
    setState(() {});
  }

  void getData() {
    _webViewController
        .runJavaScriptReturningResult("document.body.innerText")
        .then((data) {
      // var decodedJSON = jsonDecode(data);
      var responseJSON = jsonDecode(data as String);

      if (responseJSON.runtimeType == String) {
        responseJSON = jsonDecode(responseJSON);
      }
      ToastContext().init(context);
      Toast.show(
        responseJSON["message"],
        backgroundColor: MyTheme.white,
        textStyle: TextStyle(
            color: MyTheme.font_grey,
            fontSize: 14,
            fontWeight: FontWeight.w500),
        border: Border.all(color: MyTheme.medium_grey),
        backgroundRadius: 8,
        duration: 3,
        gravity: Toast.center,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildBody(),
      ),
    );
  }

/*
  void getData() {
    print('called.........');
    String? payment_details = '';

    _webViewController
        .runJavaScriptReturningResult("document.body.innerText")
        .then((data) {
      // var decodedJSON = jsonDecode(data);
      var responseJSON = jsonDecode(data as String);
      if (responseJSON.runtimeType == String) {
        responseJSON = jsonDecode(responseJSON);
      }
      //print(responseJSON.toString());
      if (responseJSON["result"] == false) {
        Toast.show(responseJSON["message"],
            duration: Toast.lengthLong, gravity: Toast.center);

        Navigator.pop(context);
      } else if (responseJSON["result"] == true) {
        print("a");
        payment_details = responseJSON['payment_details'];
        onPaymentSuccess(payment_details);
      }
    });
  }*/
/*
  onPaymentSuccess(payment_details) async {
    print("b");

    var razorpayPaymentSuccessResponse = await PaymentRepository()
        .getRazorpayPaymentSuccessResponse(widget.payment_type, widget.amount,
        _combined_order_id, payment_details);

    if (razorpayPaymentSuccessResponse.result == false) {
      print("c");
      Toast.show(razorpayPaymentSuccessResponse.message!,
          duration: Toast.lengthLong, gravity: Toast.center);
      Navigator.pop(context);
      return;
    }

    Toast.show(razorpayPaymentSuccessResponse.message!,
        duration: Toast.lengthLong, gravity: Toast.center);
    if (widget.payment_type == "cart_payment") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return OrderList(from_checkout: true);
      }));

      /*OneContext().push(MaterialPageRoute(builder: (_) {
        return OrderList(from_checkout: true);
      }));*/
    } else if (widget.payment_type == "wallet_payment") {
      print("d");
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Wallet(from_recharge: true);
      }));
    }
  }
*/
  buildBody() {
    if (_initial_url_fetched == false &&
        _combined_order_id == 0 &&
        widget.payment_type == "cart_payment") {
      return Container(
        child: Center(
          child: Text(AppLocalizations.of(context)!.creating_order),
        ),
      );
    } else {
      return SizedBox.expand(
        child: Container(
          child: WebViewWidget(
            controller: _webViewController,
          ),
        ),
      );
    }
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        widget.title!,
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
