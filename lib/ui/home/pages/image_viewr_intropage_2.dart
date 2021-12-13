import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/models/response/profile/profile_response.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewerPage2 extends StatelessWidget {
  final List<Images> imageList;
  final currentIndex;
  ImageViewerPage2(this.imageList, this.currentIndex);


  @override
  Widget build(BuildContext context) {
    PageController _controller = PageController(initialPage: currentIndex);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.6),
        body: Stack(
          children: [
            PhotoViewGallery.builder(
              itemCount: imageList.length,

              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(
                    imageList[index].fileName,
                  ),


                  // Contained = the smallest possible size to fit one dimension of the screen
                  minScale: PhotoViewComputedScale.contained,
                  // Covered = the smallest possible size to fit the whole screen
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
              scrollPhysics: BouncingScrollPhysics(),
              pageController: _controller,
              // Set the background color to the "classic white"
              backgroundDecoration: BoxDecoration(
                color: Colors.black12.withOpacity(0.6),
              ),
            ),
            Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close, color: Colors.white, size: 30,),
                )
            )
          ],
        ),
      ),
    );
  }
}