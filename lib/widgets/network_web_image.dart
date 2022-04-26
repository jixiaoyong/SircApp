import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

/*
* @description: try to solve the image load error when network image is used in web
* which detail is in the following link: https://docs.flutter.dev/development/platform-integration/web-images#cross-origin-resource-sharing-cors
*
* for now, please use the following code to solve the problem:
* run for debugging
* flutter run -d chrome --web-renderer html
* 
* production release
* flutter build web --web-renderer html --release
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/22
*/
class NetworkWebImage extends StatelessWidget {
  final Size? size;
  final String url;
  final BoxFit? fit;

  NetworkWebImage(this.url, {this.size, this.fit});

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      url,
      width: size?.width,
      height: size?.height,
      fit: fit,
      cache: true,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return SizedBox(
              width: size?.width,
              height: size?.height,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.blue.withOpacity(0.6),
                ),
              ),
            );
          case LoadState.completed:
            return ExtendedRawImage(
              image: state.extendedImageInfo?.image,
              width: size?.width,
              height: size?.height,
              fit: fit,
            );
          case LoadState.failed:
            return const Center(
              child: Text('Failed to load image'),
            );
          default:
            return Container();
        }
      },
    );

    // wait for a better solution
    // if (kIsWeb) {
    //   // this soulution is not good, when there are many images in the same page,
    //   // it will cause a lot of error. so we should use a better solution.
    //
    //   // https://github.com/flutter/flutter/issues/41563
    //   // ignore: undefined_prefixed_name
    //   ui.platformViewRegistry.registerViewFactory(
    //     url,
    //     (int _) => ImageElement()
    //       ..src = url
    //       ..crossOrigin = 'Anonymous',
    //   );
    //   return SizedBox(
    //     width: size?.width,
    //     height: size?.height,
    //     child: HtmlElementView(
    //       viewType: url,
    //     ),
    //   );
    // } else {
    //   return Image.network(
    //     url,
    //     width: size?.width,
    //     height: size?.height,
    //     fit: fit,
    //   );
    // }
  }
}
