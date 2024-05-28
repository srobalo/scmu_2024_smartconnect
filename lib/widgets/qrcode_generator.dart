import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeGeneratorWidget extends StatelessWidget {
  final String text;

  const QRCodeGeneratorWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildQRCode();
  }

  Widget _buildQRCode() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(4.0), // Padding inside the container
            child: QrImageView(
              data: text,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
        ],
      ),
    );
  }
}
