import 'package:flutter/material.dart';
import 'package:native_qr/native_qr.dart';
import 'package:flutter/foundation.dart';
class QRCodeReaderWidget extends StatefulWidget {
  @override
  _QRCodeReaderWidgetState createState() => _QRCodeReaderWidgetState();
}

class _QRCodeReaderWidgetState extends State<QRCodeReaderWidget> {
  final _nativeQr = NativeQr();
  String? qrString;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple QR Code Reader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  var result = await _nativeQr.get();
                  setState(() {
                    qrString = result;
                  });
                } catch (err) {
                  setState(() {
                    qrString = err.toString();
                  });
                }
              },
              child: const Text("Scan"),
            ),
            SizedBox(height: 20),
            Text(qrString ?? "No data"),
          ],
        ),
      ),
    );
  }
}