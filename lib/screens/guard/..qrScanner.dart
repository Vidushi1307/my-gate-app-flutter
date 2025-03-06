// import 'package:flutter/material.dart';
// import 'package:qrscan/qrscan.dart' as scanner;

// class MyNewPage extends StatefulWidget {
//   @override
//   _MyNewPageState createState() => _MyNewPageState();
// }

// class _MyNewPageState extends State<MyNewPage> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My New Page'),
//       ),
//       body: QRView(
//         key: qrKey,
//         onQRViewCreated: _onQRViewCreated,
//       ),
//     );
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       // Do something with the scan data
//       print(scanData);
//     });
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }

