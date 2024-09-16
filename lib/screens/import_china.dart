import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ImportFromChinaWebView extends StatefulWidget {
  final String url;
  const ImportFromChinaWebView({Key? key, required this.url}) : super(key: key);

  @override
  _ImportFromChinaWebViewState createState() => _ImportFromChinaWebViewState();
}

class _ImportFromChinaWebViewState extends State<ImportFromChinaWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import From China'),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
