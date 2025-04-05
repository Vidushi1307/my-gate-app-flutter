import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/image_paths.dart' as image_paths;

class UserPreferences {
  static final _defaultImage = AssetImage(image_paths.dummy_person);

  static const myUser = User(
    imagePath:
        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png',
    profileImage: NetworkImage('https://i.imgflip.com/1myuho.jpg'),
    name: 'Loading...',
    email: 'Loading...',
    phone: 'Loading...',
    degree: 'Loading...',
    department: 'Loading...',
    year_of_entry: 'Loading...',
    gender: 'Loading...',
    isDarkMode: true,
  );

  static const myGuardUser = GuardUser(
    imagePath:
        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png',
    name: 'Loading...',
    email: 'Loading...',
    location: 'Loading...',
    isDarkMode: true,
  );

  static const myAuthorityUser = AuthorityUser(
    imagePath:
        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png',
    name: 'Loading...r',
    email: 'Loading...',
    designation: 'Loading...',
    isDarkMode: true,
  );

  static const myAdminUser = AdminUser(
    imagePath:
        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png',
    name: 'Loading...',
    email: 'Loading...',
    isDarkMode: true,
  );
  
  static ImageProvider _getFallbackImageProvider(String url) {
    return _FallbackNetworkImage(
      url,
      fallback: _defaultImage,
    );
  }
}

class _FallbackNetworkImage extends ImageProvider<_FallbackNetworkImage> {
  final String url;
  final ImageProvider fallback;

  _FallbackNetworkImage(this.url, {required this.fallback});

  @override
  ImageStream resolve(ImageConfiguration configuration) {
    final ImageStream stream = ImageStream();

    // First try loading network image
    final NetworkImage networkImage = NetworkImage(url);
    final listener = ImageStreamListener(
      (image, synchronousCall) {
        stream.setCompleter(OneFrameImageStreamCompleter(
          SynchronousFuture<ImageInfo>(image)));
      },
      onError: (exception, stackTrace) {
        // If network fails, load fallback
        fallback.resolve(configuration).addListener(
          ImageStreamListener(
            (image, synchronousCall) {
              stream.setCompleter(OneFrameImageStreamCompleter(
                SynchronousFuture<ImageInfo>(image)));
            },
          ),
        );
      },
    );

    networkImage.resolve(configuration).addListener(listener);
    return stream;
  }

  @override
  Future<_FallbackNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_FallbackNetworkImage>(this);
  }
}
