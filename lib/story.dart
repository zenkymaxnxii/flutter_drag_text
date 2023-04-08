import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'input_text_overlay.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({super.key, required this.imageFile});
  final XFile imageFile;

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  bool toolBarVisible = true;
  bool textVisible = false;
  bool deleteVisible = false;
  List<Offset> offsetText = [];
  List<String> text = [];
  GlobalKey deleteWidgetKey = GlobalKey();
  Offset recycleBinPos = Offset.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_getWidgetInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _backBtn(context),
            _previewImages(widget.imageFile),
            _toolBar(),
          ],
        ),
      ),
    );
  }

  Positioned _toolBar() {
    return Positioned(
        top: 0,
        right: 0,
        child: Visibility(
          visible: toolBarVisible,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _action(
                title: "Nhãn dán",
                iconData: Icons.face_unlock_rounded,
                action: () {
                  print("object");
                },
              ),
              _action(
                title: "Văn bản",
                iconData: Icons.font_download_outlined,
                action: () {
                  _showInputOverlay(context);
                },
              ),
              _action(
                title: "Nhạc",
                iconData: Icons.library_music_outlined,
                action: () {
                  print("object");
                },
              ),
              _action(
                title: "Hiệu ứng",
                iconData: Icons.contrast_sharp,
                action: () {
                  print("object");
                },
              ),
              _action(
                title: "Vẽ",
                iconData: Icons.palette_outlined,
                action: () {
                  print("object");
                },
              ),
              _action(
                title: "Gắn thẻ",
                iconData: Icons.tag,
                action: () {
                  print("object");
                },
              ),
            ],
          ),
        ));
  }

  Widget _action(
      {required String title,
      required IconData iconData,
      required Function action}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          toolBarVisible = false;
        });
        action();
      },
      child: Container(
        padding: const EdgeInsets.only(top: 20, right: 20),
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(
            offset: Offset(-15, 10),
            color: Colors.black38,
            blurRadius: 20,
          ),
        ]),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 5,
            ),
            Icon(
              iconData,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void _showInputOverlay(BuildContext context) {
    Navigator.of(context).push(InputTextOverlay(callBack: (text) {
      setState(() {
        toolBarVisible = true;
      });
      if (text.isNotEmpty) {
        setState(() {
          this.text.add(text);
          offsetText.add(Offset(20, MediaQuery.of(context).size.height / 4));
          textVisible = true;
        });
      }
    }));
  }

  Widget _previewImages(XFile imageFile) {
    return Positioned(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Center(
                  child: Semantics(
                    label: 'image_picker_example_picked_image',
                    child: kIsWeb
                        ? Image.network(imageFile.path)
                        : Image.file(File(imageFile.path)),
                  ),
                ),
                _recycleBin(),
                if (textVisible)
                  ...List.generate(
                    text.length,
                    (index) => Positioned(
                      left: offsetText[index].dx,
                      top: offsetText[index].dy,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          offsetText[index] = Offset(
                              offsetText[index].dx + details.delta.dx,
                              offsetText[index].dy + details.delta.dy);
                          print("Text position ${details.globalPosition}");
                          print("RecycleBin position ${recycleBinPos}");
                          setState(() {
                            deleteVisible = true;
                          });
                        },
                        onPanEnd: (details) {
                          setState(() {
                            deleteVisible = false;
                          });
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.width * 0.6,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                text[index],
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("Đăng"),
            ),
          )
        ],
      ),
    );
  }

  Positioned _recycleBin() {
    return Positioned(
      bottom: 0,
      child: Visibility(
        visible: deleteVisible,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              key: deleteWidgetKey,
              padding: const EdgeInsets.all(8.0),
              child: const Icon(
                Icons.delete,
                color: Colors.grey,
                size: 35,
              ),
            ),
            const Text(
              "Kéo vào đây để xoá",
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }

  void _getWidgetInfo(_) {
    final RenderBox renderBox =
        deleteWidgetKey.currentContext?.findRenderObject() as RenderBox;
    deleteWidgetKey.currentContext?.size;
    recycleBinPos = renderBox.localToGlobal(Offset.zero);
  }

  Positioned _backBtn(BuildContext context) {
    return Positioned(
        child: GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(
            offset: Offset(-15, 10),
            color: Colors.black38,
            blurRadius: 20,
          ),
        ]),
        child: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
      ),
    ));
  }
}
