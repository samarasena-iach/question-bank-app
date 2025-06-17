import 'package:flutter/material.dart';
import '../models/question.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

class ContentRenderer extends StatelessWidget {
  final List<ContentBlock> contentBlocks;
  final bool zoomable;

  ContentRenderer({
    Key? key,
    required this.contentBlocks,
    this.zoomable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentBlocks.map((block) {
        switch (block.type) {
          case ContentType.text:
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: zoomable
                  ? Container(
                      constraints: BoxConstraints(minHeight: 50),
                      child: InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 5.0,
                        child: Text(
                          block.value,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  : Text(block.value),
            );

          case ContentType.code:
            final codeBox = Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Text(
                block.value,
                style: TextStyle(fontFamily: 'Courier', fontSize: 14),
              ),
            );

            return zoomable
                ? InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 5.0,
                    child: codeBox,
                  )
                : codeBox;

          case ContentType.image:
            final file = File(block.value);
            if (!file.existsSync()) {
              return Text('Image not found: ${block.value}');
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: zoomable
                  ? Container(
                      height: 300,
                      child: ClipRect(
                        child: PhotoView(
                          imageProvider: FileImage(file),
                          backgroundDecoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    )
                  : Image.file(file),
            );

          default:
            return SizedBox.shrink();
        }
      }).toList(),
    );
  }
}
