// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:tamam_business/util/images.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double height;
  final double width;
  final BoxFit? fit;
  final String? placeholder;
  final bool isNotification;
  const CustomImageWidget({super.key, required this.image, this.height = 8, this.width = 9, this.fit, this.placeholder, this.isNotification = false});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image, height: height, width: width, fit: fit,
      placeholder: (context, url) => Image.asset(isNotification ? Images.notificationPlaceholder : Images.placeholder, height: height, width: width, fit: fit),
      errorWidget: (context, url, error) => Image.asset(isNotification ? Images.notificationPlaceholder : Images.placeholder, height: height, width: width, fit: fit),
    );
  }
}
