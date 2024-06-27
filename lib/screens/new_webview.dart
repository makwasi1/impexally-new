import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WebView with File Upload')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri.uri(Uri(path: "https://www.w3schools.com/howto/howto_html_file_upload_button.asp"))),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        androidOnPermissionRequest: (controller, origin, resources) async {
          await _handleFileUpload();
          return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
        },
        onNavigationResponse: (controller, navigationResponse) async {
          await _handleFileUpload();
          return NavigationResponseAction.ALLOW;
        },
      ),
    );
  }

  Future<void> _handleFileUpload() async {
    final permissionStatus = await Permission.photos.request();
    if (permissionStatus.isGranted) {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final filePath = pickedFile.path;
        // You need to implement the upload logic to the server or process it within the app
      }
    } else {
      // Handle permission denied
    }
  }
}