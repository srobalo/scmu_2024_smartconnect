import 'package:flutter/material.dart';
import 'package:native_qr/native_qr.dart';
import 'package:flutter/foundation.dart';
import 'package:scmu_2024_smartconnect/defaults/default_values.dart';

import '../utils/notification_toast.dart';

class QRCodeReaderWidget extends StatefulWidget {
  const QRCodeReaderWidget({super.key});

  @override
  _QRCodeReaderWidgetState createState() => _QRCodeReaderWidgetState();
}

class _QRCodeReaderWidgetState extends State<QRCodeReaderWidget> {
  final _nativeQr = NativeQr();
  String? qrString;

  void toProcessInformation(String qrData) {
    if (qrData.isNotEmpty && !qrData.contains("null")) {
      if(qrData.length == 20) {
        // Process the QR code information here
        // check user existence in the system and associate user
        NotificationToast.showToast(context, 'User Identification: ${qrData}', durationSeconds: 3);
      }else if(qrData.length > 20) {
        NotificationToast.showToast(context, 'Invalid UserId, data received: ${qrData}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  var result = await _nativeQr.get();
                  setState(() {
                    qrString = result;
                    toProcessInformation(qrString!);
                  });
                } catch (err) {
                  setState(() {
                    qrString = err.toString();
                  });
                }
              },
              child: const Text("Scan QRCode"),
            ),
            Center(
              child: SizedBox(
                width: 200,
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        qrString == null
                            ? "Scan another user's QR code to connect them to your private SHASM network."
                            : qrString!.contains("null")
                            ? "Didn't manage to obtain information, try again to associate other users to your SHASM network."
                            : qrString!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: backgroundColorTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}