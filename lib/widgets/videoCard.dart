import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';

class VideoCard extends StatefulWidget {
  final PlatformFile? video;
  final Function()? onPressed;
  const VideoCard({Key? key, this.video, this.onPressed}) : super(key: key);

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.pink.shade100,
              width: 1.0,
            )),
        child: ListTile(
          leading: Icon(
            Icons.video_camera_back_rounded,
            color: Colors.pink.shade100,
          ),
          title: Text(
            widget.video!.name,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text("Size: " + filesize(widget.video!.size)),
          trailing: IconButton(
              onPressed: widget.onPressed,
              icon: const Icon(
                Icons.clear,
                color: Colors.red,
              )),
        ),
      ),
    );
  }
}
