// import 'package:flutter/material.dart';
// import 'package:pdf_render/pdf_render_widgets.dart';

// // ignore: must_be_immutable
// class PdfViewerCustom extends StatefulWidget {
//   String newurl;
//   PdfViewerCustom({@required newurl});
//   @override
//   _PdfViewerCustomState createState() => _PdfViewerCustomState();
// }

// class _PdfViewerCustomState extends State<PdfViewerCustom> {
//   final controller = PdfViewerController();

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PdfViewer.openAsset(
//         widget.newurl,
//         viewerController: controller,
//         onError: (err) => print(err),
//         params: PdfViewerParams(
//           padding: 10,
//           minScale: 1.0,
//         ),
//       ),
//     );
//   }
// }
