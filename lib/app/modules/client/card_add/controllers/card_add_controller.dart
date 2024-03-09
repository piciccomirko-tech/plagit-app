import 'package:dartz/dartz.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/client/card_add/models/session_id_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../common/utils/exports.dart';

class CardAddController extends GetxController {
  late WebViewController webViewController;

  final ApiHelper _apiHelper = Get.find();
  RxBool isLoading = true.obs;
  RxBool sessionIdLoading = true.obs;

  BuildContext? context;
  String fromWhere = '';

  @override
  void onInit() {
    fromWhere = Get.arguments[1];
    _getSessionId();
    super.onInit();
  }

  @override
  void onClose() {
    webViewController.clearCache();
    webViewController.clearLocalStorage();
    super.onClose();
  }

  void _getSessionId() {
    sessionIdLoading.value = true;
    _apiHelper.getSessionId(email: Get.arguments[0]).then((Either<CustomError, SessionIdResponseModel> responseData) {
      sessionIdLoading.value = false;
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (SessionIdResponseModel r) {
        if (r.status == "success" && r.statusCode == 201 && r.details != null) {
          loadWebView(sessionId: r.details?.id ?? "");
        }
      });
    });
  }

  void loadWebView({required String sessionId}) {
    String url = "https://mh-payment.netlify.app/card-verify?sessionId=$sessionId";
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) async {
          },
          onPageFinished: (String value) {
            isLoading.value = false;
          },
          onWebResourceError: (WebResourceError error) {
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void onCloseTapped() {
    if (fromWhere == "signUp") {
      Get.offAllNamed(Routes.login);
    } else {
      Get.offAllNamed(Routes.clientHome);
    }
  }
}
