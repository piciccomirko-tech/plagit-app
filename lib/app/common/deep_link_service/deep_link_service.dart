import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';

import '../../routes/app_pages.dart';
import '../local_storage/storage_helper.dart';

class DeepLinkService extends GetxService {
  final Rx<String?> _currentLink = Rx<String?>(null);
  String? get currentLink => _currentLink.value;
  late final AppLinks _appLinks;

  // Store pending deep link data
  String? _pendingPath;
  dynamic _pendingArguments;
  bool _isInitialized = false;

  // Property to check if there's a pending deep link
  bool get hasPendingDeepLink => _pendingPath != null;

  static const String appDomain = "www.plagit.com";

  void markInitialized() {
    _isInitialized = true;
    _processPendingDeepLink();
  }

  void _processPendingDeepLink() {
    if (_isInitialized && _pendingPath != null) {
      // Add a small delay to ensure home screen is shown first
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.toNamed(_pendingPath!, arguments: _pendingArguments);
        _pendingPath = null;
        _pendingArguments = null;
      });
    }
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    _appLinks = AppLinks();
    await _initUniLinks();
    _initStreamUniLinks();
  }

  Future<void> _initUniLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleDeepLink(initialUri);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting initial deep link: $e');
      }
    }
  }

  void _initStreamUniLinks() {
    _appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri != null) {
        await _handleDeepLink(uri);
      }
    }, onError: (err) {
      if (kDebugMode) {
        print('Error in deep link stream: $err');
      }
    });
  }

  Future<void> _handleDeepLink(Uri uri) async {
    try {
      _currentLink.value = uri.toString();
      if (kDebugMode) {
        print('Handling deep link: $uri');
      }

      // Validate the domain
      if (uri.host != appDomain) {
        if (kDebugMode) {
          print('Invalid domain: ${uri.host}');
        }
        return;
      }

      // String path = uri.path.replaceFirst('/', '');
      String path = uri.pathSegments[0];

      // Handle different paths
      switch (path) {
        case 'notifications':
          _navigateOrStore(Routes.notifications);
          break;

        case 'social-post_details':
          final postId = uri.queryParameters['id'];
          if (postId != null && postId.isNotEmpty) {
            if (StorageHelper.hasToken && StorageHelper.getToken.isNotEmpty) {
              _navigateOrStore("/social-post_details",
                  arguments: postId.toString());
            } else {
              _navigateOrStore(Routes.loginRegisterHints);
            }
          } else {
            if (kDebugMode) {
              print("Invalid postId in deep link");
            }
          }
          break;

        // case 'employee-details':
        //   String postId = uri.queryParameters['id'].toString();
        //   if (postId.isNotEmpty) {
        //     if (StorageHelper.hasToken && StorageHelper.getToken.isNotEmpty) {
        //       _navigateOrStore(Routes.employeeDetails,
        //           arguments: {'employeeId': postId.toString()});
        //     } else {
        //       _navigateOrStore(Routes.loginRegisterHints);
        //     }
        //   } else {
        //     print("Invalid postId in deep link");
        //   }
        //   break;

        // case 'individual-social_feeds':
        //   String postId = uri.queryParameters['id'].toString();
        //   if (postId.isNotEmpty) {
        //     if (StorageHelper.hasToken && StorageHelper.getToken.isNotEmpty) {
        //       _navigateOrStore(Routes.appLinkIndividualSocialFeeds,
        //           arguments: postId.toString());
        //     } else {
        //       _navigateOrStore(Routes.loginRegisterHints);
        //     }
        //   } else {
        //     print("Invalid postId in deep link");
        //   }
        //   break;

        case 'profile':
          String postId = uri.pathSegments.last;
          if (kDebugMode) {
            print('DeepLinkService._handleDeepLink$postId');
          }
          if (postId.isNotEmpty) {
            if (kDebugMode) {
              print('DeepLinkService._handleDeepLink$postId');
            }
            if (StorageHelper.hasToken && StorageHelper.getToken.isNotEmpty) {
              _navigateOrStore(Routes.userProfile,
                  arguments: postId.toString());
            } else {
              _navigateOrStore(Routes.loginRegisterHints);
            }
          } else {
            if (kDebugMode) {
              print("Invalid postId in deep link");
            }
          }
          break;

        default:
          if (kDebugMode) {
            print('Unhandled path: $path');
          }
          _navigateOrStore('/');
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling deep link: $e');
      }
    }
  }

  void _navigateOrStore(String path, {dynamic arguments}) {
    if (_isInitialized) {
      Get.toNamed(path, arguments: arguments);
    } else {
      _pendingPath = path;
      _pendingArguments = arguments;
    }
  }

  // Generate links
  static String generateAppLink(String path,
      [Map<String, String>? parameters]) {
    final Uri uri = Uri.https(appDomain, path, parameters);
    return uri.toString();
  }
}
