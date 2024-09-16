import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GetRiders extends StatefulWidget {
  const GetRiders({Key? key}) : super(key: key);

  @override
  _GetRidersState createState() => _GetRidersState();
}

class _GetRidersState extends State<GetRiders> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()..loadRequest(Uri.parse("https://app.impexally.com/riders-info"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Riders'),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
